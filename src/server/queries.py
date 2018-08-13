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
       st_asgeojson(location) AS location,
       st_distance(location, 
            st_setsrid(st_point(%(long)s, %(lat)s), 4326), 
            false) as distance
  FROM stop_locations
  WHERE st_dwithin(location, 
            st_setsrid(st_makepoint(%(long)s, %(lat)s), 4326), 
            %(max_distance)s, 
            false)
  ORDER BY distance
  LIMIT %(max_items)s;
""")