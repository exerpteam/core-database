# subscription_price.type
Maps code values from `subscription_price.type` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|CAMPAIGN|CAMPAIGN|text|[subscription_price](../exerp/subscription_price.md)|
|CONVERSION|CONVERSION|text|[subscription_price](../exerp/subscription_price.md)|
|INITIAL|CAMPAIGN (PRO-RATA)|text|[subscription_price](../exerp/subscription_price.md)|
|MANUAL|MANUAL|text|[subscription_price](../exerp/subscription_price.md)|
|PRORATA|CAMPAIGN (PRO-RATA)|text|[subscription_price](../exerp/subscription_price.md)|
