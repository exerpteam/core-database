# creditcardtransactions.transaction_state
Maps code values from `creditcardtransactions.transaction_state` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|0|INITIALIZED|integer|[creditcardtransactions](../exerp/creditcardtransactions.md)|
|1|AUTHORIZED|integer|[creditcardtransactions](../exerp/creditcardtransactions.md)|
|2|CAPTURED|integer|[creditcardtransactions](../exerp/creditcardtransactions.md)|
|3|REVERSED|integer|[creditcardtransactions](../exerp/creditcardtransactions.md)|
|4|FAILED|integer|[creditcardtransactions](../exerp/creditcardtransactions.md)|
|5|ERROR|integer|[creditcardtransactions](../exerp/creditcardtransactions.md)|
