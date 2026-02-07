# subscriptions.sub_state
Maps code values from `subscriptions.sub_state` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|NONE|integer|[subscriptions](../exerp/subscriptions.md)|
|2|AWAITING_ACTIVATION|integer|[subscriptions](../exerp/subscriptions.md)|
|3|UPGRADED|integer|[subscriptions](../exerp/subscriptions.md)|
|4|DOWNGRADED|integer|[subscriptions](../exerp/subscriptions.md)|
|5|EXTENDED|integer|[subscriptions](../exerp/subscriptions.md)|
|6|TRANSFERRED|integer|[subscriptions](../exerp/subscriptions.md)|
|7|REGRETTED|integer|[subscriptions](../exerp/subscriptions.md)|
|8|CANCELLED|integer|[subscriptions](../exerp/subscriptions.md)|
|9|BLOCKED|integer|[subscriptions](../exerp/subscriptions.md)|
|10|CHANGED|integer|[subscriptions](../exerp/subscriptions.md)|
