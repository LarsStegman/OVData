\i database-scripts/connect.sql;

COPY timing_link FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');
