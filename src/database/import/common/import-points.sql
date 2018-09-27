\i database-scripts/connect.sql;

CREATE TABLE temp_points AS TABLE point;
ALTER TABLE temp_points
ADD COLUMN location_x DECIMAL,
ADD COLUMN location_y DECIMAL,
DROP COLUMN physical_location;

COPY temp_points FROM :data
WITH (FORMAT CSV,
HEADER TRUE,
DELIMITER '|',
NULL '');


UPDATE temp_points SET description=NULL WHERE description = 'Onbekend';

INSERT INTO point
  SELECT data_owner_code,
         point_code,
         valid_from,
         point_type,
         ST_TRANSFORM(
           ST_SETSRID(ST_MAKEPOINT(location_x, location_y), 28992),
           4326),
         description FROM temp_points;

DROP TABLE temp_points;
