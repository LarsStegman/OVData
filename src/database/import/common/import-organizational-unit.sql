\i database-scripts/connect.sql;

COPY organizational_unit FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');
