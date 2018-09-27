\i database-scripts/connect.sql;

COPY time_demand_group FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');