# account_trans.trans_type
Maps code values from `account_trans.trans_type` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|GENERAL LEDGER|integer|[account_trans](../exerp/account_trans.md)|
|2|ACCOUNT RECEIVABLES|integer|[account_trans](../exerp/account_trans.md)|
|3|ACCOUNT PAYABLES|integer|[account_trans](../exerp/account_trans.md)|
|4|INVOICE LINE|integer|[account_trans](../exerp/account_trans.md)|
|5|CREDIT NOTE LINE|integer|[account_trans](../exerp/account_trans.md)|
|6|BILL LINE|integer|[account_trans](../exerp/account_trans.md)|
