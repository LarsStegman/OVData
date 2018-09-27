\i database-scripts/connect.sql;

COPY pass_public_journey_pass FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');
