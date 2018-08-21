CREATE MATERIALIZED VIEW stops AS
  SELECT DISTINCT f.data_owner_code, f.user_stop_code,
                  replace(f.name, (f.town || ', '), '') AS name, f.town,
                  f.stop_side_code, f.description, f.user_stop_type, f.user_stop_area_code,
                  point.physical_location as location
    FROM user_stops AS f
    INNER JOIN timing_link AS tl
      ON f.data_owner_code = tl.data_owner_code AND
         f.user_stop_code = tl.user_stop_code_begin
    INNER JOIN user_stops AS s
      ON tl.data_owner_code = s.data_owner_code AND
         tl.user_stop_code_end = s.user_stop_code
    INNER JOIN link
      ON link.data_owner_code = tl.data_owner_code AND
          link.user_stop_code_begin = tl.user_stop_code_begin AND
          link.user_stop_code_end = tl.user_stop_code_end
    INNER JOIN point_on_link AS pol
        ON pol.data_owner_code = link.data_owner_code AND
            pol.user_stop_code_begin = link.user_stop_code_begin AND
            pol.user_stop_code_end = link.user_stop_code_end AND
            pol.link_valid_from = link.valid_from AND
            pol.transport_type = link.transport_type
    INNER JOIN point
        ON point.data_owner_code = pol.data_owner_code AND
            point.point_code = pol.point_code
    WHERE pol.distance_since_start_of_link = 0;

CREATE INDEX stops_location_idx ON stops USING gist (location);
CREATE INDEX stops_name_idx ON stops (name);
CREATE INDEX stops_code_idx ON stops (data_owner_code, user_stop_code);


CREATE MATERIALIZED VIEW lines_at_stop AS
    SELECT DISTINCT
    line.data_owner_code, stops.user_stop_code, stops.user_stop_area_code, line.line_planning_number, line.line_public_number, line.line_name,
    line.transport_type,
    d2.dest_code, d2.dest_name_full, d2.dest_name_main, d2.dest_name_detail,
    d2.relevant_dest_name_detail, d2.dest_name_main_21, d2.dest_name_detail_21,
    d2.dest_name_main_19, d2.dest_name_detail_19, d2.dest_name_main_16,
    d2.dest_name_detail_16
    FROM line
    INNER JOIN journey_pattern AS jopa
        ON jopa.data_owner_code = line.data_owner_code AND
            jopa.line_planning_number = line.line_planning_number
    INNER JOIN journey_pattern_timing_link AS jopatili
        ON jopatili.data_owner_code = line.data_owner_code AND
            jopatili.line_planning_number = line.line_planning_number AND
            jopatili.journey_pattern_code = jopa.journey_pattern_code
    INNER JOIN user_stops as stops
        ON stops.data_owner_code = line.data_owner_code AND
           (stops.user_stop_code = jopatili.user_stop_code_begin OR
               stops.user_stop_code = jopatili.user_stop_code_end)
    INNER JOIN destination d2 ON
            jopatili.data_owner_code = d2.data_owner_code
              AND jopatili.dest_code = d2.dest_code;

CREATE INDEX ON lines_at_stop (data_owner_code, user_stop_code);
CREATE INDEX ON lines_at_stop (data_owner_code, user_stop_area_code);
