\i database-scripts/connect.sql;

COPY public_journey FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');