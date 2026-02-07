# subscription_sales.type
Maps code values from `subscription_sales.type` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|NEW|integer|[subscription_sales](../exerp/subscription_sales.md)|
|2|EXTENSION|integer|[subscription_sales](../exerp/subscription_sales.md)|
|3|CHANGE|integer|[subscription_sales](../exerp/subscription_sales.md)|
|4|REACTIVATE|integer|[subscription_sales](../exerp/subscription_sales.md)|
