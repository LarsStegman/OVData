
CREATE VIEW departures_at_stop AS
  (SELECT
        rt.data_owner_code,
        rt.line_planning_number,
        rt.journey_pattern_code,
        rt.time_demand_group_code,
        rt.timing_link_order AS stop_order,
        rt.user_stop_code_begin AS user_stop_code,

        INTERVAL '0' AS target_arrival_time,
        INTERVAL '0' AS target_departure_time

  FROM time_demand_group_run_time AS rt
  WHERE rt.timing_link_order = 0)

  UNION

  (SELECT
          rt.data_owner_code,
          rt.line_planning_number,
          rt.journey_pattern_code,
          rt.time_demand_group_code,
          rt.timing_link_order + 1 AS stop_order,
          rt.user_stop_code_end AS user_stop_code,

          coalesce ((SELECT SUM(total_drive_time)
          FROM time_demand_group_run_time AS sub
          WHERE sub.data_owner_code = rt.data_owner_code AND
           sub.line_planning_number = rt.line_planning_number AND
          sub.journey_pattern_code = rt.journey_pattern_code AND
          sub.time_demand_group_code = rt.time_demand_group_code AND
          sub.timing_link_order < rt.timing_link_order), INTERVAL '0') + drive_time
            AS target_arrival_time,
          coalesce ((SELECT SUM(total_drive_time)
          FROM time_demand_group_run_time AS sub
          WHERE sub.data_owner_code = rt.data_owner_code AND
           sub.line_planning_number = rt.line_planning_number AND
          sub.journey_pattern_code = rt.journey_pattern_code AND
          sub.time_demand_group_code = rt.time_demand_group_code AND
          sub.timing_link_order < rt.timing_link_order), INTERVAL '0') + total_drive_time
            AS target_departure_time

  FROM time_demand_group_run_time AS rt)
  ORDER BY data_owner_code, line_planning_number,
           journey_pattern_code, time_demand_group_code,
           stop_order;

CREATE VIEW journey_days AS
  SELECT
       today.date, pujo.data_owner_code, pujo.timetable_version_code,
       period_group_code, line_planning_number, journey_number,
       time_demand_group_code, journey_pattern_code, departure_time AS journey_start_time
FROM
     (SELECT pujo.*, CAST(day AS INT) AS weekday
      FROM public_journey AS pujo,
         unnest(string_to_array(pujo.day_type, NULL)) AS day
      WHERE NOT day = '0') AS pujo,
     (SELECT current_date AS date, extract(dow FROM current_date) AS current_day) AS today
WHERE today.current_day = pujo.weekday;


CREATE VIEW valid_journeys AS
SELECT jd.*
FROM journey_days AS jd
  INNER JOIN period_group_validity AS pgv
    ON pgv.data_owner_code = jd.data_owner_code AND
        pgv.period_group_code = jd.period_group_code
WHERE valid_from <= current_date AND valid_through >= current_date;

CREATE VIEW tdg_public_journey_pass AS
SELECT vj.data_owner_code,
       vj.timetable_version_code,
       vj.line_planning_number,
       vj.journey_number,
       das.stop_order,
       vj.journey_pattern_code,
       das.user_stop_code,
       vj.date + vj.journey_start_time + das.target_arrival_time AS target_arrival_time,
       vj.date + vj.journey_start_time + das.target_departure_time AS target_departure_time
FROM valid_journeys AS vj
INNER JOIN departures_at_stop AS das ON
        vj.data_owner_code = das.data_owner_code AND
            vj.line_planning_number = das.line_planning_number AND
            vj.journey_pattern_code = das.journey_pattern_code AND
            vj.time_demand_group_code = das.time_demand_group_code
ORDER BY target_departure_time ASC;
