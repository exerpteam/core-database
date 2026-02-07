# persons.status
Maps code values from `persons.status` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|0|LEAD|integer|[persons](../exerp/persons.md)|
|1|ACTIVE|integer|[persons](../exerp/persons.md)|
|2|INACTIVE|integer|[persons](../exerp/persons.md)|
|3|TEMPORARYINACTIVE|integer|[persons](../exerp/persons.md)|
|4|TRANSFERRED|integer|[persons](../exerp/persons.md)|
|5|DUPLICATE|integer|[persons](../exerp/persons.md)|
|6|PROSPECT|integer|[persons](../exerp/persons.md)|
|7|DELETED|integer|[persons](../exerp/persons.md)|
|8|ANONYMIZED|integer|[persons](../exerp/persons.md)|
|9|CONTACT|integer|[persons](../exerp/persons.md)|
|10|BLOCKED|integer|[persons](../exerp/persons.md)|
