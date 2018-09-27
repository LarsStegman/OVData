CREATE VIEW pass_departures AS
SELECT pass.data_owner_code,
       pass.line_planning_number,
       pass.journey_number,
       pass.stop_order,
       pass.journey_pattern_code,
       pass.user_stop_code,
       current_date + pass.target_arrival_time AS target_arrival_time,
       current_date + pass.target_departure_time AS target_departure_time
FROM pass_operating_day as oper_day
INNER JOIN pass_public_journey_pass pass ON
        oper_day.data_owner_code = pass.data_owner_code AND
        oper_day.organizational_unit_code = pass.organizational_unit_code AND
        oper_day.schedule_code = pass.schedule_code AND
        oper_day.schedule_type_code = pass.schedule_type_code
WHERE oper_day.valid_date = current_date;
