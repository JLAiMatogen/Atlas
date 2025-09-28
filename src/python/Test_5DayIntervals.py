from datetime import datetime, timedelta

def generate_5_day_intervals(start_date_str, end_date_str):
    # Parse input dates
    start_date = datetime.strptime(start_date_str, "%Y-%m-%d")
    end_date = datetime.strptime(end_date_str, "%Y-%m-%d")

    intervals = []
    current_start = start_date

    while current_start <= end_date:
        current_end = min(current_start + timedelta(days=4), end_date)
        intervals.append((
            current_start.strftime("%Y-%m-%d"),
            current_end.strftime("%Y-%m-%d")
        ))
        current_start = current_end + timedelta(days=1)

    return intervals

# Example usage
intervals = generate_5_day_intervals("2025-02-01", "2025-02-28")
for start, end in intervals:
    print(f"{start} to {end}")