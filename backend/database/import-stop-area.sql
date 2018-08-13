\i database-scripts/connect.sql;

CREATE TABLE temp_stop_areas AS TABLE stop_areas;

COPY temp_stop_areas
FROM :data
WITH (FORMAT CSV,
HEADER TRUE,
DELIMITER '|',
NULL '');


UPDATE temp_stop_areas SET description=NULL WHERE description = 'Onbekend';

INSERT INTO stop_areas
  SELECT data_owner_code,
         user_stop_area_code,
         name,
         town,
         description FROM temp_stop_areas;

DROP TABLE temp_stop_areas;
