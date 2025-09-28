CREATE OR REPLACE FUNCTION Age_In_Months(
    start_date DATE,
    end_date DATE
)
RETURNS INT AS $$
    SELECT EXTRACT(YEAR FROM age(end_date, start_date)) * 12 +
           EXTRACT(MONTH FROM age(end_date, start_date)) + 1;
$$ LANGUAGE sql IMMUTABLE;