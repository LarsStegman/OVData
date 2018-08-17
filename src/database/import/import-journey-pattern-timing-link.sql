\i database-scripts/connect.sql;

COPY journey_pattern_timing_link FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');