\i database-scripts/connect.sql;

COPY organizational_unit_relations FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');
