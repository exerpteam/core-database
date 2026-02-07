# change_logs.type
Maps code values from `change_logs.type` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|ADD|integer|[change_logs](../exerp/change_logs.md)|
|2|UPDATE|integer|[change_logs](../exerp/change_logs.md)|
|3|REMOVE|integer|[change_logs](../exerp/change_logs.md)|
