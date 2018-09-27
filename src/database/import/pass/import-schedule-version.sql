\i database-scripts/connect.sql;

COPY pass_schedule_version FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');
