# activity.activity_type
Maps code values from `activity.activity_type` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|GENERAL|integer|[activity](../exerp/activity.md)|
|2|CLASS|integer|[activity](../exerp/activity.md)|
|3|RESOURCE BOOKING|integer|[activity](../exerp/activity.md)|
|4|STAFF BOOKING|integer|[activity](../exerp/activity.md)|
|5|MEETING|integer|[activity](../exerp/activity.md)|
|6|STAFF AVAILABILITY|integer|[activity](../exerp/activity.md)|
|7|RESOURCE AVAILABILITY|integer|[activity](../exerp/activity.md)|
|8|CHILDCARE|integer|[activity](../exerp/activity.md)|
|9|COURSE|integer|[activity](../exerp/activity.md)|
|10|TASK|integer|[activity](../exerp/activity.md)|
|11|CAMP|integer|[activity](../exerp/activity.md)|
|12|CAMP ELECTIVE|integer|[activity](../exerp/activity.md)|
