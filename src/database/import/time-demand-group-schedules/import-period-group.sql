\i database-scripts/connect.sql;

COPY period_group FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');