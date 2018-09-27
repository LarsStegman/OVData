\i database-scripts/connect.sql;

COPY pass_operating_day FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');
