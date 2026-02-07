# participations.state
Maps code values from `participations.state` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|BOOKED|N|text|[participations](../exerp/participations.md)|
|CANCELLED|NO_SHOW|text|[participations](../exerp/participations.md)|
|PARTICIPATION|PARTICIPATED|text|[participations](../exerp/participations.md)|
|REVIEW|REVIEW|text|[participations](../exerp/participations.md)|
|TENTATIVE|TENTATIVE|text|[participations](../exerp/participations.md)|
