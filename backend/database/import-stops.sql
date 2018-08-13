\i database-scripts/connect.sql;

CREATE TABLE temp_stops AS TABLE stops;


COPY temp_stops FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');

UPDATE temp_stops SET stop_side_code=NULL WHERE stop_side_code = '-';
UPDATE temp_stops SET timing_point_code=user_stop_code WHERE timing_point_code=NULL;

INSERT INTO stops (SELECT * FROM temp_stops)
  ON CONFLICT ON CONSTRAINT data_owner_user_stop_codes_pk DO UPDATE
    SET
      timing_point_code=EXCLUDED.timing_point_code,
      get_in=EXCLUDED.get_in,
      get_out=EXCLUDED.get_out,

      name=EXCLUDED.name,
      town=EXCLUDED.town,
      user_stop_area_code=EXCLUDED.user_stop_area_code,
      stop_side_code=EXCLUDED.stop_side_code,
      description=EXCLUDED.description,
      user_stop_type=EXCLUDED.user_stop_type;

DROP TABLE temp_stops;
