# bookings.recurrence_type
Maps code values from `bookings.recurrence_type` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|DAILY|integer|[bookings](../exerp/bookings.md)|
|2|WEEKLY|integer|[bookings](../exerp/bookings.md)|
|3|MONTHLY|integer|[bookings](../exerp/bookings.md)|
