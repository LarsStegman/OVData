\i database-scripts/connect.sql;

COPY period_group_validity FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');