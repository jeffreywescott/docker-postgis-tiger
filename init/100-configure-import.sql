-- Fixes: https://trac.osgeo.org/postgis/ticket/3698
UPDATE loader_lookuptables
SET    load = true
,      post_load_process = '${psql} -c "ALTER TABLE ${staging_schema}.${state_abbrev}_${lookup_name} RENAME geoid10 TO tabblock_id;  SELECT loader_load_staged_data(lower(''${state_abbrev}_${table_name}''), lower(''${state_abbrev}_${lookup_name}'')); "
${psql} -c "ALTER TABLE ${data_schema}.${state_abbrev}_${lookup_name} ADD CONSTRAINT chk_statefp CHECK (statefp = ''${state_fips}'');"
${psql} -c "CREATE INDEX ${data_schema}_${state_abbrev}_${lookup_name}_the_geom_gist ON ${data_schema}.${state_abbrev}_${lookup_name} USING gist(the_geom);"
${psql} -c "vacuum analyze ${data_schema}.${state_abbrev}_${lookup_name};"'
,      columns_exclude = '{gid, uatyp10, uatype, suffix1ce}'
WHERE  lookup_name = 'tabblock'
;
