# subscriptions.state
Maps code values from `subscriptions.state` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|0|PENDING|integer|[subscriptions](../exerp/subscriptions.md)|
|1|AWAITING ACTIVATION (DEPRECATED)|integer|[subscriptions](../exerp/subscriptions.md)|
|2|ACTIVE|integer|[subscriptions](../exerp/subscriptions.md)|
|3|ENDED|integer|[subscriptions](../exerp/subscriptions.md)|
|4|FROZEN|integer|[subscriptions](../exerp/subscriptions.md)|
|5|CANCELLED|integer|[subscriptions](../exerp/subscriptions.md)|
|6|NOT PAID|integer|[subscriptions](../exerp/subscriptions.md)|
|7|WINDOW|integer|[subscriptions](../exerp/subscriptions.md)|
|8|CREATED|integer|[subscriptions](../exerp/subscriptions.md)|
|9|CREATED TRANSFERRED|integer|[subscriptions](../exerp/subscriptions.md)|
|10|CREATED TRANSFERRED (DEPRECATED)|integer|[subscriptions](../exerp/subscriptions.md)|
