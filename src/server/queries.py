from psycopg2 import sql

"""
Finds the 80 stops within a radius of x meters
"""
closest_stops_query = sql.SQL("""
SELECT data_owner_code,
       user_stop_code,
       name,
       town,
       stop_side_code,
       user_stop_area_code,
       stop_area_name,
       st_asgeojson(location) AS location,
       st_distance(location, 
            st_setsrid(st_point(%(long)s, %(lat)s), 4326), 
            false) as distance
  FROM stops
  WHERE st_dwithin(location, 
            st_setsrid(st_makepoint(%(long)s, %(lat)s), 4326), 
            %(max_distance)s, 
            false)
  ORDER BY distance
  LIMIT %(max_items)s;
""")

"""
Retrieves the lines that stop at a stop.
"""
lines_at_stop = sql.SQL("""
SELECT * FROM lines_at_stop 
    WHERE data_owner_code=%(data_owner_code)s 
        AND user_stop_code=%(stop_code)s;
""")


"""
Retrieves the lines that stop in a stop area
"""
lines_at_stop_area = sql.SQL("""
SELECT * FROM lines_at_stop 
    WHERE data_owner_code=%(data_owner_code)s 
        AND user_stop_area_code=%(stop_area_code)s;
""")
