import ast

from server.data_connection import Database
from server.queries import closest_stops_query


class API:

    max_stop_items = 200
    max_stop_distance = 5000

    def __init__(self):
        self.db = Database()

    def clamp(self, v, min_v, max_v):
        return max(min(v, max_v), min_v)

    def closest_stops(self, long, lat, r, max_items):
        if r is not None:
            r = self.clamp(r, 0, self.max_stop_distance)
        if max_items is not None:
            max_items = self.clamp(max_items, 1, self.max_stop_items)

        if r is None:
            if max_items is None:
                return self.closest_stops_internal(long, lat)
            else:
                return self.closest_stops_internal(long, lat, max_items=max_items)
        else:
            if max_items is None:
                return self.closest_stops_internal(long, lat, r)
            else:
                return self.closest_stops_internal(long, lat, r, max_items)

    def closest_stops_internal(self, long, lat, r=1000, max_items=80):
        """
        Finds the stops closest to a WGS84 coordinate

        :param long: the longitude (x)
        :param lat: the latitide (y)
        :return: A list of dictionaries containing the stops data.
        """
        closest_stops = self.db.dict_query(closest_stops_query, {
                'long': long,
                'lat': lat,
                'max_distance': r,
                'max_items': max_items})

        for stop in closest_stops:
            stop['location'] = ast.literal_eval(stop['location'])

        return closest_stops

