# participations.cancelation_reason
Maps code values from `participations.cancelation_reason` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|NO_SEAT|NOSEAT|text|[participations](../exerp/participations.md)|
|NO_SHOW|NOSHOW|text|[participations](../exerp/participations.md)|
|USER|CANCELLED_MEMBER|text|[participations](../exerp/participations.md)|
|USER_CANCEL_LATE|FAIL|text|[participations](../exerp/participations.md)|
