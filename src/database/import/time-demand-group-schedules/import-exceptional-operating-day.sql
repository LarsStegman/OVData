\i database-scripts/connect.sql;

COPY exceptional_operating_day FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');