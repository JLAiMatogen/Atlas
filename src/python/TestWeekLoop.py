from datetime import date, timedelta

def get_week_ranges(year):
    first_day = date(year, 1, 1)
    # Find the first Monday of the year
    start = first_day if first_day.weekday() == 0 else first_day + timedelta(days=(7 - first_day.weekday()))
    
    while start.year <= year:
        end = start + timedelta(days=5)  # Monday to Saturday
        iso_year, iso_week, _ = start.isocalendar()
        
        if iso_year == year or end.year == year:
            yield iso_year, iso_week, start, end
        
        start += timedelta(days=7)

# Sample SQL template (use parameter placeholders for actual DB execution)
sql_template = """
SELECT * FROM your_table
WHERE open_date BETWEEN '{start_date}' AND '{end_date}';
"""

# Loop and inject
for y, w, start_date, end_date in get_week_ranges(2025):
    sql = sql_template.format(start_date=start_date, end_date=end_date)
    print(f"-- Week {y}{w:02d}")
    print(sql)