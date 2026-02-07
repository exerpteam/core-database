# payment_agreements.state
Maps code values from `payment_agreements.state` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|CREATED|integer|[payment_agreements](../exerp/payment_agreements.md)|
|2|SENT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|3|FAILED|integer|[payment_agreements](../exerp/payment_agreements.md)|
|4|OK|integer|[payment_agreements](../exerp/payment_agreements.md)|
|5|ENDED BY DEBITOR|integer|[payment_agreements](../exerp/payment_agreements.md)|
|6|ENDED BY THE CLEARING HOUSE|integer|[payment_agreements](../exerp/payment_agreements.md)|
|7|ENDED BY DEBITOR|integer|[payment_agreements](../exerp/payment_agreements.md)|
|8|CANCELLED, NOT SENT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|9|CANCELLED, SENT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|10|ENDED, CREDITOR|integer|[payment_agreements](../exerp/payment_agreements.md)|
|11|NO AGREEMENT (DEPRECATED)|integer|[payment_agreements](../exerp/payment_agreements.md)|
|12|CASH PAYMENT (DEPRECATED)|integer|[payment_agreements](../exerp/payment_agreements.md)|
|13|AGREEMENT NOT NEEDED (INVOICE PAYMENT)|integer|[payment_agreements](../exerp/payment_agreements.md)|
|14|AGREEMENT INFORMATION INCOMPLETE|integer|[payment_agreements](../exerp/payment_agreements.md)|
|15|TRANSFER|integer|[payment_agreements](../exerp/payment_agreements.md)|
|16|AGREEMENT RECREATED|integer|[payment_agreements](../exerp/payment_agreements.md)|
|17|SIGNATURE MISSING|integer|[payment_agreements](../exerp/payment_agreements.md)|
