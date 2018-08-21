import json
from flask import Flask
from flask import request
from flask import Response

from server import API

app = Flask(__name__)
api = API.API()



def json_response(value):
    return Response(json.dumps(value), mimetype='text/json')


def argument_error():
    return app.response_class(status=400)

@app.route("/")
def hello():
    return "Hello world!"


@app.route("/stops/near")
def stops_near():
    request_params = request.args
    long = request_params.get('long')
    lat = request_params.get('lat')
    max_radius = request_params.get('r')
    max_items = request_params.get('max_items')

    try:
        long = float(long)
        lat = float(lat)
        if max_radius is not None:
            max_radius = float(max_radius)
        if max_items is not None:
            max_items = int(max_items)
    except ValueError:
        return argument_error()

    result = api.closest_stops(long, lat, max_radius, max_items)
    return json_response(result)


@app.route("/lines/stop")
def lines_at_stop():
    request_params = request.args
    data_owner = request_params.get('data_owner_code')
    stop_code = request_params.get('stop_code')
    result = api.lines_at_stop(data_owner, stop_code)
    return json_response(result)


@app.route("/lines/stop_area")
def lines_in_stop_area():
    request_params = request.args
    data_owner = request_params.get('data_owner_code')
    stop_area_code = request_params.get('stop_area_code')
    result = api.lines_in_stop_area(data_owner, stop_area_code)
    return json_response(result)


if __name__ == '__main__':
    app.run(host='0.0.0.0')