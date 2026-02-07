# persons.member_status
Maps code values from `persons.member_status` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|0|N|integer|[persons](../exerp/persons.md)|
|1|NON-MEMBER|integer|[persons](../exerp/persons.md)|
|2|MEMBER|integer|[persons](../exerp/persons.md)|
|4|EXTRA|integer|[persons](../exerp/persons.md)|
|5|EX-MEMBER|integer|[persons](../exerp/persons.md)|
|6|LEGACY MEMBER|integer|[persons](../exerp/persons.md)|
