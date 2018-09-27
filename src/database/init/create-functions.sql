CREATE FUNCTION remove_trailing_leading(string VARCHAR(255),
  to_remove VARCHAR(255), separator VARCHAR(255) = ', ')
  RETURNS VARCHAR(255) AS $$
BEGIN
  RETURN  replace(
            replace(string, (to_remove || separator), ''),
            (separator || to_remove),
            ''
          );
END;
$$ LANGUAGE plpgsql;