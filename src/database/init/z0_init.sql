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

CREATE TYPE ovdata.TransportType AS
  ENUM('TRAIN',
       'BUS',
       'METRO',
       'TRAM',
       'BOAT');

CREATE TYPE ovdata.PointType AS
  ENUM('AG', 'AV', 'PL', 'RS', 'SP');

CREATE TYPE ovdata.Direction AS ENUM ('A', 'B');

CREATE TABLE ovdata.point (
  data_owner_code DataOwnerCode NOT NULL ,
  point_code VARCHAR(10) NOT NULL ,
  CONSTRAINT point_pk PRIMARY KEY (data_owner_code, point_code) ,

  valid_from DATE NOT NULL ,
  point_type PointType NOT NULL ,
  physical_location geography(Point, 4326) NOT NULL,
  description VARCHAR(255)
);

CREATE INDEX point_location_index ON point USING gist (physical_location);


CREATE TABLE ovdata.stop_areas(
  data_owner_code DataOwnerCode NOT NULL ,
  user_stop_area_code VARCHAR(10) NOT NULL ,

  CONSTRAINT stop_area_pk
      PRIMARY KEY (data_owner_code, user_stop_area_code),

  name VARCHAR(50) NOT NULL ,
  town VARCHAR(50) NOT NULL ,
  description VARCHAR(255)
);

CREATE TABLE ovdata.user_stops(
  data_owner_code DataOwnerCode NOT NULL ,
  user_stop_code  VARCHAR(10) NOT NULL ,
  CONSTRAINT data_owner_user_stop_codes_pk PRIMARY KEY (data_owner_code, user_stop_code) ,
  timing_point_code VARCHAR(10),

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

CREATE INDEX stop_name_index ON user_stops (name);
CREATE INDEX stop_user_point_code ON user_stops (user_stop_code);
CREATE INDEX stop_timing_code ON user_stops (timing_point_code);

CREATE TABLE ovdata.timing_link( -- The abstract connection between two stops
  data_owner_code DataOwnerCode NOT NULL,

  user_stop_code_begin VARCHAR(10) NOT NULL,
  FOREIGN KEY (data_owner_code, user_stop_code_begin)
    REFERENCES user_stops (data_owner_code, user_stop_code),

  user_stop_code_end VARCHAR(10) NOT NULL,
  FOREIGN KEY (data_owner_code, user_stop_code_end)
    REFERENCES user_stops (data_owner_code, user_stop_code),

  CONSTRAINT timing_link_pk
    PRIMARY KEY (data_owner_code, user_stop_code_begin, user_stop_code_end),

  minimal_drive_time INTEGER,
  description VARCHAR(255)
);

CREATE TABLE ovdata.link( -- The actual connection between two stops, e.g. rails
  data_owner_code DataOwnerCode NOT NULL,
  user_stop_code_begin VARCHAR(10) NOT NULL,
  user_stop_code_end VARCHAR(10) NOT NULL,
  valid_from DATE NOT NULL,
  distance INTEGER NOT NULL,
  description VARCHAR(255),
  transport_type TransportType NOT NULL,

  CONSTRAINT link_pk
    PRIMARY KEY (data_owner_code, user_stop_code_begin, user_stop_code_end, valid_from, transport_type),

  FOREIGN KEY (data_owner_code, user_stop_code_begin, user_stop_code_end)
    REFERENCES timing_link (data_owner_code, user_stop_code_begin, user_stop_code_end)
);

CREATE TABLE ovdata.point_on_link(
  data_owner_code DataOwnerCode NOT NULL,
  user_stop_code_begin VARCHAR(10) NOT NULL,
  user_stop_code_end VARCHAR(10) NOT NULL,
  link_valid_from DATE NOT NULL,
  point_data_owner_code DataOwnerCode NOT NULL,
  point_code VARCHAR(10) NOT NULL,
  distance_since_start_of_link INTEGER NOT NULL ,
  description VARCHAR(255),
  transport_type TransportType NOT NULL,

  FOREIGN KEY (data_owner_code, user_stop_code_begin, user_stop_code_end, link_valid_from, transport_type)
    REFERENCES link (data_owner_code, user_stop_code_begin, user_stop_code_end, valid_from, transport_type),

  FOREIGN KEY (point_data_owner_code, point_code)
    REFERENCES point (data_owner_code, point_code),

  CONSTRAINT pool_pk
    PRIMARY KEY (data_owner_code, user_stop_code_begin, user_stop_code_end,
                 link_valid_from, point_data_owner_code, point_code,
                 transport_type)
);


CREATE TABLE ovdata.line(
  data_owner_code DataOwnerCode NOT NULL ,
  line_planning_number VARCHAR(10) NOT NULL ,
  PRIMARY KEY (data_owner_code, line_planning_number),

  line_public_number VARCHAR(4) NOT NULL ,
  line_name VARCHAR(50) NOT NULL ,

  description VARCHAR(255) ,
  transport_type TransportType NOT NULL
);

CREATE TABLE ovdata.journey_pattern(
  data_owner_code DataOwnerCode NOT NULL ,
  line_planning_number VARCHAR(10) NOT NULL ,
  journey_pattern_code VARCHAR(10) NOT NULL ,
  PRIMARY KEY (data_owner_code, line_planning_number, journey_pattern_code),
  FOREIGN KEY (data_owner_code, line_planning_number)
    REFERENCES line (data_owner_code, line_planning_number),

  direction Direction NOT NULL ,
  description VARCHAR(255)
);

CREATE TABLE ovdata.destination(
  data_owner_code DataOwnerCode NOT NULL,
  dest_code VARCHAR(10) NOT NULL ,
  PRIMARY KEY (data_owner_code, dest_code),

  dest_name_full VARCHAR(50) NOT NULL ,
  dest_name_main VARCHAR(24) NOT NULL ,
  dest_name_detail VARCHAR(24) ,
  relevant_dest_name_detail BOOLEAN NOT NULL ,

  dest_name_main_21 VARCHAR(21) NOT NULL ,
  dest_name_detail_21 VARCHAR(21) ,

  dest_name_main_19 VARCHAR(19) NOT NULL ,
  dest_name_detail_19 VARCHAR(19) ,

  dest_name_main_16 VARCHAR(16) NOT NULL ,
  dest_name_detail_16 VARCHAR(16)
);

CREATE TABLE ovdata.journey_pattern_timing_link(
  data_owner_code DataOwnerCode NOT NULL,
  line_planning_number VARCHAR(10) NOT NULL,
  journey_pattern_code VARCHAR(10) NOT NULL,
  FOREIGN KEY (data_owner_code, line_planning_number, journey_pattern_code)
    REFERENCES journey_pattern (data_owner_code, line_planning_number,
                                journey_pattern_code),

  timing_link_order SMALLINT NOT NULL ,
  PRIMARY KEY (data_owner_code, line_planning_number,
               journey_pattern_code, timing_link_order),


  user_stop_code_begin VARCHAR(10) NOT NULL ,
  user_stop_code_end VARCHAR(10) NOT NULL ,
  FOREIGN KEY (data_owner_code, user_stop_code_begin, user_stop_code_end)
    REFERENCES timing_link (data_owner_code, user_stop_code_begin,
                            user_stop_code_end),


  dest_code VARCHAR(10) NOT NULL ,
  FOREIGN KEY (data_owner_code, dest_code)
    REFERENCES destination (data_owner_code, dest_code),

  is_timing_stop BOOLEAN NOT NULL ,
  display_public_line VARCHAR(4)
);



\i database-scripts/init/create-views.sql

-- Order of import:
-- point
-- stop
-- stop area
-- timing link
-- link
-- point on link