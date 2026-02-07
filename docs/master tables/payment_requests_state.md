# payment_requests.state
Maps code values from `payment_requests.state` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|NEW|integer|[payment_requests](../exerp/payment_requests.md)|
|2|SENT|integer|[payment_requests](../exerp/payment_requests.md)|
|3|DONE|integer|[payment_requests](../exerp/payment_requests.md)|
|4|DONE, MANUAL|integer|[payment_requests](../exerp/payment_requests.md)|
|5|REJECTED, CLEARINGHOUSE|integer|[payment_requests](../exerp/payment_requests.md)|
|6|REJECTED, BANK|integer|[payment_requests](../exerp/payment_requests.md)|
|7|REJECTED, DEBTOR|integer|[payment_requests](../exerp/payment_requests.md)|
|8|CANCELLED|integer|[payment_requests](../exerp/payment_requests.md)|
|10|REVERSED, NEW|integer|[payment_requests](../exerp/payment_requests.md)|
|11|REVERSED , SENT|integer|[payment_requests](../exerp/payment_requests.md)|
|12|FAILED, NOT CREDITOR|integer|[payment_requests](../exerp/payment_requests.md)|
|13|REVERSED, REJECTED|integer|[payment_requests](../exerp/payment_requests.md)|
|14|REVERSED, CONFIRMED|integer|[payment_requests](../exerp/payment_requests.md)|
|17|FAILED, PAYMENT REVOKED|integer|[payment_requests](../exerp/payment_requests.md)|
|18|DONE PARTIAL|integer|[payment_requests](../exerp/payment_requests.md)|
|19|FAILED, UNSUPPORTED|integer|[payment_requests](../exerp/payment_requests.md)|
|20|REQUIRE APPROVAL|integer|[payment_requests](../exerp/payment_requests.md)|
|21|FAIL, DEBT CASE EXISTS|integer|[payment_requests](../exerp/payment_requests.md)|
|22|FAILED, TIMED OUT|integer|[payment_requests](../exerp/payment_requests.md)|
