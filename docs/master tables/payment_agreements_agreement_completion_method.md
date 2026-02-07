# payment_agreements.agreement_completion_method
Maps code values from `payment_agreements.agreement_completion_method` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|CARD_TERMINAL|CLIENT|text|[payment_agreements](../exerp/payment_agreements.md)|
|SEND_EMAIL|WEB|text|[payment_agreements](../exerp/payment_agreements.md)|
