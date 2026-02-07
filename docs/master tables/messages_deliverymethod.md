# messages.deliverymethod
Maps code values from `messages.deliverymethod` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|0|STAFF|integer|[messages](../exerp/messages.md)|
|1|EMAIL|integer|[messages](../exerp/messages.md)|
|2|SMS|integer|[messages](../exerp/messages.md)|
|3|PERSINTF|integer|[messages](../exerp/messages.md)|
|4|BLOCKPERSINTF|integer|[messages](../exerp/messages.md)|
|5|LETTER|integer|[messages](../exerp/messages.md)|
|6|MOBILE_API|integer|[messages](../exerp/messages.md)|
|7|STAFF_APP_NOTIFICATION|integer|[messages](../exerp/messages.md)|
|8|MEMBER_APP_NOTIFICATION|integer|[messages](../exerp/messages.md)|
