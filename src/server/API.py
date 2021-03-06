import ast

from server.data_connection import Database
from server.queries import closest_stops_query, lines_at_stop, \
    lines_at_stop_area, departures_at_stop


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
                return self.__closest_stops__(long, lat)
            else:
                return self.__closest_stops__(long, lat, max_items=max_items)
        else:
            if max_items is None:
                return self.__closest_stops__(long, lat, r)
            else:
                return self.__closest_stops__(long, lat, r, max_items)

    def __closest_stops__(self, long, lat, r=1000, max_items=80):
        """
        Finds the stops closest to a WGS84 coordinate

        :param long: the longitude (x)
        :param lat: the latitide (y)
        :return: A dictionary of stop areas with the stops inside them
        """
        # TODO: Stops that are not in stop areas exist!
        closest_stops = self.db.dict_query(closest_stops_query, {
                'long': long,
                'lat': lat,
                'max_distance': r,
                'max_items': max_items
        })

        result = {}
        for stop in closest_stops:
            stop['location'] = ast.literal_eval(stop['location'])
            stop_area_code = stop['user_stop_area_code']
            if result.get(stop_area_code) is None:
                result[stop_area_code] = {
                    'data_owner_code': stop['data_owner_code'],
                    'stop_area_code': stop_area_code,
                    'name': stop['stop_area_name'],
                    'town': stop['town'],
                    'stops': []
                }

            result.get(stop_area_code).get('stops').append(stop)

        return list(result.values())


    def lines_at_stop(self, data_owner_code, stop_code):
        """
        Finds the lines at the stop

        :param data_owner_code:
        :param stop_code:
        :return:
        """
        lines = self.db.dict_query(lines_at_stop, {
            'data_owner_code': data_owner_code,
            'stop_code': stop_code
        })

        return self.__lines__(lines)

    def lines_in_stop_area(self, data_owner_code, stop_area_code):
        """
        Finds the lines in a stop area

        :param data_owner_code:
        :param stop_area_code:
        :return:
        """
        lines = self.db.dict_query(lines_at_stop_area, {
            'data_owner_code': data_owner_code,
            'stop_area_code': stop_area_code
        })

        return self.__lines__(lines)

    @staticmethod
    def __lines__(lines):
        """
        Organises a list of lines into dictionaries

        :param lines:
        :return:
        """
        result = {}
        for line in lines:
            stop_code = line['user_stop_code']
            if result.get(stop_code) is None:
                result[stop_code] = []

            lines_at_stop_arr = result[stop_code]
            line['destination'] = API.extract_destination(line)

            lines_at_stop_arr.append(line)

        return result.values()

    def departures_at_stop(self, data_owner_code, stop_code):
        departures = self.db.dict_query(departures_at_stop, {
            'data_owner_code': data_owner_code,
            'user_stop_code': stop_code
        })

        return self.__departures__(departures)

    def __departures__(self, departures):
        """
        Extracts the departures from the items
        :param departures: The departure data
        :return: A list of departures
        """

        for departure in departures:
            departure['destination'] = self.extract_destination(departure)

        return departures

    @staticmethod
    def extract_destination(item):
        """
        Extracts the destination from the item
        :param item: The destination data. The destination data will be
        removed from the original data.
        :type item: dict[String, Any]
        :return: A dictionary with the formatted destination data
        :rtype: dict[String, Any]
        """

        return {
                'data_owner_code': item['data_owner_code'],
                'code': item.pop('dest_code'),
                'name': {
                    'full': item.pop('dest_name_full'),
                    'main': {
                        'name': item.pop('dest_name_main'),
                        'detail': item.pop('dest_name_detail'),
                        'always_show_detail':
                            item.pop('relevant_dest_name_detail')
                    },
                    21: {
                        'name': item.pop('dest_name_main_21'),
                        'detail': item.pop('dest_name_detail_21')
                    },
                    19: {
                        'name': item.pop('dest_name_main_19'),
                        'detail': item.pop('dest_name_detail_19')
                    },
                    16: {
                        'name': item.pop('dest_name_main_16'),
                        'detail': item.pop('dest_name_detail_16')
                    },
                }
            }
