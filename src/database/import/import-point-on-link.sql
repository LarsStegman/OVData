\i database-scripts/connect.sql;

COPY point_on_link FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');
