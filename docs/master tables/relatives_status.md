# relatives.status
Maps code values from `relatives.status` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|0|LEAD|integer|[relatives](../exerp/relatives.md)|
|1|ACTIVE|integer|[relatives](../exerp/relatives.md)|
|2|INACTIVE|integer|[relatives](../exerp/relatives.md)|
|3|BLOCKED|integer|[relatives](../exerp/relatives.md)|
