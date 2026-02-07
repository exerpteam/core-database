# persons.persontype
Maps code values from `persons.persontype` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|0|PRIVATE|integer|[persons](../exerp/persons.md)|
|1|STUDENT|integer|[persons](../exerp/persons.md)|
|2|STAFF|integer|[persons](../exerp/persons.md)|
|3|FRIEND|integer|[persons](../exerp/persons.md)|
|4|CORPORATE|integer|[persons](../exerp/persons.md)|
|5|ONEMANCORPORATE|integer|[persons](../exerp/persons.md)|
|6|FAMILY|integer|[persons](../exerp/persons.md)|
|7|SENIOR|integer|[persons](../exerp/persons.md)|
|8|GUEST|integer|[persons](../exerp/persons.md)|
|9|CHILD|integer|[persons](../exerp/persons.md)|
|10|EXTERNAL_STAFF|integer|[persons](../exerp/persons.md)|
