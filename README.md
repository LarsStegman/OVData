# OVData

A software package to store OpenOV data from [ndovloket.nl](ndovloket.nl) on the public transit data in The Netherlands. 

## Deploy

There is a database server that can be started using the Dockerfile. To import the data into the database:

 1. Store the data in a `data` folder at the root of the project;
 2. Bash into the database Docker container and run `python3 backend/server/import-files.py`

The API endpoint can be started by running `flask run` with environment variable `FLASK_APP=/backend/server/APIServer.py`.

## Endpoints


### Nearest stops

*   URL: `/stops/near`
*   URL Parameters:
    * `lat`: latitude
    * `long`: longitude
    * `r`: maximum radius in meteres (max 5000m)
    * `limit`: The maximum number of stops returned (max 200)
* Returns: A JSON object with stops grouped in stop areas stop areas.

Example request:

```
localhost:5000/stops/near?lat=51.9988387&long=4.3712948&r=2000
```
