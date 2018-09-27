\i database-scripts/connect.sql;

COPY destination FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');
