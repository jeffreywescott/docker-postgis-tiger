#!/bin/bash

function die {
  echo $1 exit 1
  exit 1
}

function drop_state {
  state="$1"
  drop_script="/tmp/drop-states.sql"
  echo "dropping any existing state data for ${state} ..."
  echo "SELECT drop_state_tables_generate_script('${state}');" | psql -tA -o "${drop_script}"
  cat "${drop_script}" | psql -tA
}

set -e

test -z "$1" && die "You must pass a list of uppercase state abbreviations, e.g.: '$0 CA NY'"
states="$*"
states_list="'$(echo "${states}" | sed "s/\ /','/g")'"

for state in "${states}"; do
  drop_state "${state}"
done

echo "downloading and creating state data for: ${states}"

load_script="/tmp/load-states.sh"
echo "SELECT loader_generate_script(ARRAY[${states_list}], 'sh');" | psql -tA -o "${load_script}"
echo "set -e" | cat - "${load_script}" > /tmp/scratch.tmp && mv /tmp/scratch.tmp "${load_script}"

/bin/sed -i "s/^export PGUSER=.*$/export PGUSER=${POSTGRES_USER}/g" "${load_script}"
/bin/sed -i "s/^export PGDATABASE=.*$/export PGDATABASE=${POSTGRES_DB}/g" "${load_script}"
/bin/sed -i "s/^export PGPASSWORD=.*$/export PGPASSWORD=${POSTGRES_PASSWORD}/g" "${load_script}"
/bin/sed -i "s/^export PGPASSWORD=.*$/export PGPASSWORD=${POSTGRES_PASSWORD}/g" "${load_script}"

# fixes: https://trac.osgeo.org/postgis/ticket/3698
/bin/sed -i "s/_tabblock\./_tabblock10./g" "${load_script}"

/bin/sh "${load_script}"

echo "installing missing indexes and optimizing ..."

psql -tA <<EOSQL
  SELECT install_missing_indexes();
  vacuum analyze verbose tiger.addr;
  vacuum analyze verbose tiger.county;
  vacuum analyze verbose tiger.cousub;
  vacuum analyze verbose tiger.edges;
  vacuum analyze verbose tiger.faces;
  vacuum analyze verbose tiger.featnames;
  vacuum analyze verbose tiger.place;
  vacuum analyze verbose tiger.state;
EOSQL

echo "... done!"
