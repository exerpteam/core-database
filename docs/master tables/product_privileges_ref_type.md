# product_privileges.ref_type
Maps code values from `product_privileges.ref_type` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|GLOBAL_PRODUCT|INCLUDE|text|[product_privileges](../exerp/product_privileges.md)|
|PRODUCT_GROUP|EXCLUDE|text|[product_privileges](../exerp/product_privileges.md)|
