\i database-scripts/connect.sql;

COPY time_demand_group_run_time FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');