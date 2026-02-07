# payment_requests.request_type
Maps code values from `payment_requests.request_type` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|PAYMENT|integer|[payment_requests](../exerp/payment_requests.md)|
|2|DEBT COLLECTION|integer|[payment_requests](../exerp/payment_requests.md)|
|3|REVERSAL|integer|[payment_requests](../exerp/payment_requests.md)|
|4|REMINDER|integer|[payment_requests](../exerp/payment_requests.md)|
|5|REFUND|integer|[payment_requests](../exerp/payment_requests.md)|
|6|REPRESENTATION|integer|[payment_requests](../exerp/payment_requests.md)|
|7|LEGACY|integer|[payment_requests](../exerp/payment_requests.md)|
|8|ZERO|integer|[payment_requests](../exerp/payment_requests.md)|
|9|SERVICE CHARGE|integer|[payment_requests](../exerp/payment_requests.md)|
