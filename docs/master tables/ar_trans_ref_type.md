# ar_trans.ref_type
Maps code values from `ar_trans.ref_type` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|ACCOUNT_TRANS|ACCOUNT_TRANS|text|[ar_trans](../exerp/ar_trans.md)|
|CREDIT_NOTE|SALE_LOG|text|[ar_trans](../exerp/ar_trans.md)|
|INVOICE|SALE_LOG|text|[ar_trans](../exerp/ar_trans.md)|
|OVERDUE_AMOUNT|OVERDUE AMOUNT|text|[ar_trans](../exerp/ar_trans.md)|
