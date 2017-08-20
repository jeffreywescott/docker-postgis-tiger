#!/bin/bash

set -e

echo "dropping any existing nation data ..."

drop_script="/tmp/drop-nation.sql"
echo "SELECT drop_nation_tables_generate_script();" | psql -tA -o "${drop_script}"
cat "${drop_script}" | psql -tA

echo "downloading and creating nation data ..."

load_script="/tmp/load-nation.sh"
echo "SELECT loader_generate_nation_script('sh');" | psql -tA -o "${load_script}"

echo "set -e" | cat - "${load_script}" > /tmp/scratch.tmp && mv /tmp/scratch.tmp "${load_script}"
/bin/sed -i "s/^export PGHOST=.*$/export PGHOST=/g" "${load_script}"
/bin/sed -i "s/^export PGUSER=.*$/export PGUSER=${POSTGRES_USER}/g" "${load_script}"
/bin/sed -i "s/^export PGDATABASE=.*$/export PGDATABASE=${POSTGRES_DB}/g" "${load_script}"
/bin/sed -i "s/^export PGPASSWORD=.*$/export PGPASSWORD=${POSTGRES_PASSWORD}/g" "${load_script}"

/bin/sh "${load_script}"

echo "... done!"
