# clearing_in.state
Maps code values from `clearing_in.state` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|RECEIVED|integer|[clearing_in](../exerp/clearing_in.md)|
|2|VERIFIED|integer|[clearing_in](../exerp/clearing_in.md)|
|3|ERRORED|integer|[clearing_in](../exerp/clearing_in.md)|
|4|BAD|integer|[clearing_in](../exerp/clearing_in.md)|
|5|HANDLED|integer|[clearing_in](../exerp/clearing_in.md)|
|6|CONFIRMED|integer|[clearing_in](../exerp/clearing_in.md)|
|7|CLEANED|integer|[clearing_in](../exerp/clearing_in.md)|
|8|HANDLING|integer|[clearing_in](../exerp/clearing_in.md)|
