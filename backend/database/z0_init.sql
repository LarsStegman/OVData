CREATE DATABASE ovdata_db TEMPLATE=template_postgis OWNER=larsstegman;
\c ovdata_db

CREATE SCHEMA IF NOT EXISTS ovdata AUTHORIZATION larsstegman;
SET SEARCH_PATH TO ovdata,public;

-- Source: 
-- "Specificatie BISON, BISON Enumaraties en Tabellen, Koppelvlak overkoepelend,
-- versie 8.2.0.3, 12 april 2018. Table E1"
CREATE TYPE ovdata.DataOwnerCode AS
    ENUM('ARR', 
         'VTN',
         'CXX',
         'GVB',
         'HTM',
         'RET',
         'NS',
         'SYNTUS',
         'QBUZZ',
         'EBS',
         'HTMBUZZ',
         'DELIJN',
         'TEC',
         'MIVB',
         'DOEKSEN',
         'WPD',
         'TESO',
         'WSF',
         'TCR',
         'FLIXBUS',
         'OUIBUS',
         'EUROLINES',
         'HTZ',
         'WTR',
         'ALGEMEEN',
         'DRECHTSTED',
         'GOVI',
         'RIG',
         'SABIMOS',
         'PRORAIL',
         'OPENOV',
         'CBSXXYYYY',
         'RWSaaaaaa',
         'INFRAbbbbb');

CREATE TYPE ovdata.UserStopType AS
    ENUM('PASSENGER',
         'BRIDGE',
         'FINANCIAL');

CREATE TABLE ovdata.locations(
data_owner_code DataOwnerCode NOT NULL ,
  point_code VARCHAR(10) NOT NULL ,
  CONSTRAINT data_owner_point_code_pk PRIMARY KEY (data_owner_code, point_code) ,

  valid_from date NOT NULL ,
  physical_location geography(Point, 4326) NOT NULL,
  description VARCHAR(255)
);

CREATE INDEX point_location_index ON locations USING gist (physical_location);


CREATE TABLE ovdata.stop_areas(
  data_owner_code DataOwnerCode NOT NULL ,
  user_stop_area_code VARCHAR(10) NOT NULL ,

  CONSTRAINT data_owner_code_stop_area_code_pk
      PRIMARY KEY (data_owner_code, user_stop_area_code),

  name VARCHAR(50) NOT NULL ,
  town VARCHAR(50) NOT NULL ,
  description VARCHAR(255)
);

CREATE TABLE ovdata.stops(
  data_owner_code DataOwnerCode NOT NULL ,
  user_stop_code  VARCHAR(10) NOT NULL ,
  CONSTRAINT data_owner_user_stop_codes_pk PRIMARY KEY (data_owner_code, user_stop_code) ,
  timing_point_code VARCHAR(10),

  FOREIGN KEY (data_owner_code, user_stop_code)
    REFERENCES locations (data_owner_code, point_code),
  FOREIGN KEY (data_owner_code, timing_point_code)
    REFERENCES locations (data_owner_code, point_code),

  get_in BOOLEAN NOT NULL ,
  get_out BOOLEAN NOT NULL ,

  name VARCHAR(50) NOT NULL ,
  town VARCHAR(50) NOT NULL ,
  user_stop_area_code VARCHAR(10) ,
  FOREIGN KEY  (data_owner_code, user_stop_area_code)
    REFERENCES stop_areas (data_owner_code, user_stop_area_code),

  stop_side_code VARCHAR(10) , -- perron, e.g. J
  description VARCHAR(255) ,
  user_stop_type UserStopType NOT NULL
);

CREATE INDEX stop_name_index ON stops (name);
CREATE INDEX stop_user_point_code ON stops (user_stop_code);
CREATE INDEX stop_timing_code ON stops (timing_point_code);

CREATE VIEW stop_locations AS
  SELECT
    s.data_owner_code, s.user_stop_code, s.name, s.town, s.stop_side_code,
    s.description, s.user_stop_type, s.user_stop_area_code,
    l.physical_location as location
  FROM locations AS l
  INNER JOIN stops as s
    ON (s.data_owner_code = l.data_owner_code AND s.timing_point_code = l.point_code);

-- CREATE INDEX stop_locations_idx ON stop_locations (location);