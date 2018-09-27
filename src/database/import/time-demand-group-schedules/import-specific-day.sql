\i database-scripts/connect.sql;

COPY specific_day FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');