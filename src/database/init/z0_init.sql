CREATE DATABASE ovdata_db TEMPLATE=template_postgis OWNER=larsstegman;
\c ovdata_db

CREATE SCHEMA IF NOT EXISTS ovdata AUTHORIZATION larsstegman;
SET SEARCH_PATH TO ovdata,public;


\i database-scripts/init/create-functions.sql
\i database-scripts/init/create-types.sql


-- Stops
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


-- Schedule

CREATE TABLE ovdata.organizational_unit(
  data_owner_code DataOwnerCode NOT NULL ,
  code VARCHAR(10) NOT NULL ,
  PRIMARY KEY (data_owner_code, code) ,

  name VARCHAR(50) NOT NULL ,
  type OrganizationalUnitType NOT NULL ,
  description VARCHAR(255)
);

CREATE TABLE ovdata.organizational_unit_relations(
  data_owner_code DataOwnerCode NOT NULL ,
  parent VARCHAR(10) NOT NULL ,
  FOREIGN KEY (data_owner_code, parent)
    REFERENCES organizational_unit (data_owner_code, code) ,

  child VARCHAR(10) NOT NULL ,
  FOREIGN KEY (data_owner_code, child)
    REFERENCES organizational_unit (data_owner_code, code) ,

  valid_from Date NOT NULL,
  PRIMARY KEY (data_owner_code, parent, child, valid_from)
);


-- Time demand runtime group schedules
CREATE TABLE ovdata.period_group(
  data_owner_code DataOwnerCode NOT NULL ,
  period_group_code VARCHAR(10) NOT NULL ,
  PRIMARY KEY (data_owner_code, period_group_code) ,
  description VARCHAR(255)
);

CREATE TABLE ovdata.period_group_validity(
  data_owner_code DataOwnerCode NOT NULL ,
  organization_unit_code VARCHAR(10) NOT NULL ,
  period_group_code VARCHAR(10) NOT NULL ,

  FOREIGN KEY (data_owner_code, period_group_code)
    REFERENCES period_group (data_owner_code, period_group_code) ,
  FOREIGN KEY (data_owner_code, organization_unit_code)
    REFERENCES organizational_unit (data_owner_code, code) ,

  valid_from Date NOT NULL ,
  PRIMARY KEY (data_owner_code, organization_unit_code,
               period_group_code, valid_from) ,
  valid_through Date
);

CREATE TABLE ovdata.specific_day(
  data_owner_code DataOwnerCode NOT NULL ,
  specific_day_code VARCHAR(10) NOT NULL ,

  PRIMARY KEY (data_owner_code, specific_day_code) ,

  name VARCHAR(50) NOT NULL ,
  description VARCHAR(255)
);

CREATE TABLE ovdata.exceptional_operating_day(
  data_owner_code DataOwnerCode NOT NULL ,
  organization_unit_code VARCHAR(10) NOT NULL ,
  valid_date TIMESTAMP(0) NOT NULL ,

  PRIMARY KEY (data_owner_code, organization_unit_code, valid_date) ,

  day_type_as_on CHAR(7) NOT NULL ,
  specific_day_code VARCHAR(10) NOT NULL ,

  FOREIGN KEY (data_owner_code, specific_day_code)
    REFERENCES specific_day (data_owner_code, specific_day_code),

  period_group_code VARCHAR(10) ,
  FOREIGN KEY (data_owner_code, period_group_code)
    REFERENCES period_group (data_owner_code, period_group_code) ,

  description VARCHAR(255)
);

CREATE TABLE ovdata.timetable_version(
  data_owner_code DataOwnerCode NOT NULL,
  organizational_unit_code VARCHAR(10) NOT NULL,

  FOREIGN KEY (data_owner_code, organizational_unit_code)
    REFERENCES organizational_unit (data_owner_code, code) ,

  timetable_version_code VARCHAR(10) NOT NULL,
  period_group_code VARCHAR(10) NOT NULL,
  specific_day_code VARCHAR(10) NOT NULL,


  PRIMARY KEY (data_owner_code, organizational_unit_code,
               timetable_version_code, period_group_code, specific_day_code) ,
  FOREIGN KEY (data_owner_code, specific_day_code)
    REFERENCES specific_day (data_owner_code, specific_day_code),
  FOREIGN KEY (data_owner_code, period_group_code)
    REFERENCES period_group (data_owner_code, period_group_code) ,

  valid_from Date NOT NULL,
  time_table_version_type VARCHAR(10) NOT NULL ,

  valid_through Date,
  description VARCHAR(255)
);


CREATE TABLE ovdata.time_demand_group(
  data_owner_code DataOwnerCode NOT NULL ,
  line_planning_number VARCHAR(10) NOT NULL ,
  journey_pattern_code VARCHAR(10) NOT NULL ,

  FOREIGN KEY (data_owner_code, line_planning_number, journey_pattern_code)
    REFERENCES journey_pattern (data_owner_code, line_planning_number,
                                journey_pattern_code),

  time_demand_group_code VARCHAR(10) NOT NULL ,

  PRIMARY KEY (data_owner_code, line_planning_number, journey_pattern_code,
               time_demand_group_code)
);

CREATE TABLE ovdata.time_demand_group_run_time(
  data_owner_code DataOwnerCode NOT NULL ,
  line_planning_number VARCHAR(10) NOT NULL ,
  journey_pattern_code VARCHAR(10) NOT NULL ,
  time_demand_group_code VARCHAR(10) NOT NULL ,
  FOREIGN KEY (data_owner_code, line_planning_number, journey_pattern_code,
               time_demand_group_code)
    REFERENCES time_demand_group (data_owner_code, line_planning_number,
                                  journey_pattern_code,
                                  time_demand_group_code) ,

  timing_link_order SMALLINT NOT NULL ,
  FOREIGN KEY (data_owner_code, line_planning_number, journey_pattern_code,
               timing_link_order)
    REFERENCES journey_pattern_timing_link (data_owner_code,
                                            line_planning_number,
                                            journey_pattern_code,
                                            timing_link_order) ,

  PRIMARY KEY (data_owner_code, line_planning_number, journey_pattern_code,
               time_demand_group_code, timing_link_order) ,

  user_stop_code_begin VARCHAR(10) NOT NULL ,
  user_stop_code_end VARCHAR(10) NOT NULL ,

  total_drive_time INTERVAL NOT NULL ,
  drive_time INTERVAL NOT NULL ,
  expected_delay INTERVAL ,
  layover_time INTERVAL ,
  stop_wait_time INTERVAL NOT NULL ,
  minimum_stop_time INTERVAL
);

CREATE TABLE ovdata.public_journey(
  data_owner_code DataOwnerCode NOT NULL,
  timetable_version_code VARCHAR(10) NOT NULL,
  organizational_unit_code VARCHAR(10) NOT NULL ,
  period_group_code VARCHAR(10) NOT NULL ,
  specific_day_code VARCHAR(10) NOT NULL ,

  FOREIGN KEY (data_owner_code, timetable_version_code,
               organizational_unit_code, period_group_code, specific_day_code)
    REFERENCES timetable_version (data_owner_code, timetable_version_code,
                                  organizational_unit_code, period_group_code,
                                  specific_day_code),

  day_type CHAR(7) NOT NULL ,
  line_planning_number VARCHAR(10) NOT NULL ,
  journey_number INTEGER NOT NULL,

  PRIMARY KEY (data_owner_code, timetable_version_code,
               organizational_unit_code, period_group_code, specific_day_code,
               day_type, line_planning_number, journey_number) ,

  time_demand_group_code VARCHAR(10) NOT NULL ,
  journey_pattern_code VARCHAR(10) NOT NULL ,

  FOREIGN KEY (data_owner_code, line_planning_number, time_demand_group_code,
               journey_pattern_code)
    REFERENCES time_demand_group (data_owner_code, line_planning_number,
                                  time_demand_group_code, journey_pattern_code) ,

  departure_time INTERVAL NOT NULL , -- interval after midnight since departure time > 24h is possible.
  wheelchair_accessible WheelChairAccessibility NOT NULL ,

  data_owner_is_operator BOOLEAN NOT NULL ,
  planned_monitored BOOLEAN NOT NULL
);

-- pass schedules

CREATE TABLE ovdata.pass_schedule_version(
  data_owner_code DataOwnerCode NOT NULL ,
  organizational_unit_code VARCHAR(10) NOT NULL ,

  FOREIGN KEY (data_owner_code, organizational_unit_code)
    REFERENCES organizational_unit (data_owner_code, code) ,

  schedule_code VARCHAR(10) NOT NULL ,
  schedule_type_code VARCHAR(10) NOT NULL ,

  PRIMARY KEY (data_owner_code, organizational_unit_code,
               schedule_code, schedule_type_code) ,

  valid_from Date NOT NULL ,
  valid_through Date ,
  description VARCHAR(255)
);

CREATE TABLE ovdata.pass_operating_day(
  data_owner_code DataOwnerCode NOT NULL ,
  organizational_unit_code VARCHAR(10) NOT NULL ,
  schedule_code VARCHAR(10) NOT NULL ,
  schedule_type_code VARCHAR(10) NOT NULL ,

  FOREIGN KEY (data_owner_code, organizational_unit_code,
               schedule_code, schedule_type_code)
    REFERENCES pass_schedule_version (data_owner_code, organizational_unit_code,
                                      schedule_code, schedule_type_code) ,

  valid_date Date NOT NULL ,

  PRIMARY KEY (data_owner_code, organizational_unit_code, schedule_code,
               schedule_type_code, valid_date) ,

  description VARCHAR(255)
);

CREATE TABLE ovdata.pass_public_journey_pass(
  data_owner_code DataOwnerCode NOT NULL ,
  organizational_unit_code VARCHAR(10) NOT NULL ,
  schedule_code VARCHAR(10) NOT NULL ,
  schedule_type_code VARCHAR(10) NOT NULL ,

  FOREIGN KEY (data_owner_code, organizational_unit_code,
               schedule_code, schedule_type_code)
    REFERENCES pass_schedule_version (data_owner_code,
                                      organizational_unit_code, schedule_code,
                                      schedule_type_code) ,

  line_planning_number VARCHAR(10) NOT NULL ,
  journey_number INTEGER NOT NULL ,
  stop_order SMALLINT NOT NULL ,

  PRIMARY KEY (data_owner_code, organizational_unit_code, schedule_code,
               schedule_type_code, line_planning_number, journey_number,
               stop_order) ,

  journey_pattern_code VARCHAR(10) NOT NULL ,

  FOREIGN KEY (data_owner_code, line_planning_number, journey_pattern_code)
    REFERENCES journey_pattern (data_owner_code, line_planning_number,
                                journey_pattern_code) ,

  user_stop_code VARCHAR(10) NOT NULL ,
  FOREIGN KEY (data_owner_code, user_stop_code)
    REFERENCES user_stops (data_owner_code, user_stop_code) ,

  target_arrival_time INTERVAL NOT NULL ,
  target_departure_time INTERVAL NOT NULL ,

  wheel_chair_accessible WheelChairAccessibility NOT NULL ,
  data_owner_is_operator BOOLEAN NOT NULL ,
  planned_monitored BOOLEAN NOT NULL
);


-- Order of import:
-- point
-- stop area
-- stop
-- timing link
-- link
-- point on link
-- dest
-- line
-- jopa
-- jopatili
-- period group
-- period group validity
-- exceptional operating day
-- specific day
-- timetable version
-- time demand group
-- time demand group runtime
-- public journey

\i database-scripts/init/create-views.sql

