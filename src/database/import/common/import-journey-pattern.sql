\i database-scripts/connect.sql;

CREATE TABLE temp_jopa AS TABLE journey_pattern;
ALTER TABLE temp_jopa ALTER COLUMN direction SET DATA TYPE CHAR(1);

COPY temp_jopa FROM :data
WITH (FORMAT CSV,
  HEADER TRUE,
  DELIMITER '|',
  NULL '');

UPDATE temp_jopa SET direction='A' WHERE direction='1';
UPDATE temp_jopa SET direction='B' WHERE direction='2';

INSERT INTO journey_pattern
    (SELECT data_owner_code,
            line_planning_number,
            journey_pattern_code,
            CAST (direction AS Direction),
            description
     FROM temp_jopa);
DROP TABLE temp_jopa;
