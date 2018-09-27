\i database-scripts/connect.sql;

COPY timetable_version FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');