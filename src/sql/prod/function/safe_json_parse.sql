-- DROP FUNCTION prod.safe_json_parse(text);

CREATE OR REPLACE FUNCTION safe_json_parse(input_text text)
 RETURNS json
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
  RETURN input_text::JSON;
EXCEPTION
  WHEN others THEN
    RETURN NULL;
END;
$function$
;