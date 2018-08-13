\i database-scripts/connect.sql;

CREATE TABLE temp_locations AS TABLE locations;
ALTER TABLE temp_locations
ADD COLUMN location_x DECIMAL,
ADD COLUMN location_y DECIMAL,
DROP COLUMN physical_location;

COPY temp_locations FROM :data
WITH (FORMAT CSV,
HEADER TRUE,
DELIMITER '|',
NULL '');


UPDATE temp_locations SET description=NULL WHERE description = 'Onbekend';

INSERT INTO locations
  SELECT data_owner_code,
         point_code,
         valid_from,
         ST_TRANSFORM(
           ST_SETSRID(ST_MAKEPOINT(location_x, location_y), 28992),
           4326),
         description FROM temp_locations;

DROP TABLE temp_locations;
