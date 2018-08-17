\i database-scripts/connect.sql;

COPY link FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');
