# accounts.atype
Maps code values from `accounts.atype` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|ASSET|integer|[accounts](../exerp/accounts.md)|
|2|LIABILITY|integer|[accounts](../exerp/accounts.md)|
|3|INCOME|integer|[accounts](../exerp/accounts.md)|
|4|EXPENSE|integer|[accounts](../exerp/accounts.md)|
