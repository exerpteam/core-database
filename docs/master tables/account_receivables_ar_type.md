# account_receivables.ar_type
Maps code values from `account_receivables.ar_type` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|CASH|integer|[account_receivables](../exerp/account_receivables.md)|
|4|PAYMENT|integer|[account_receivables](../exerp/account_receivables.md)|
|5|DEBT|integer|[account_receivables](../exerp/account_receivables.md)|
|6|INSTALLMENT|integer|[account_receivables](../exerp/account_receivables.md)|
