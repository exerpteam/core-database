# gift_cards.state
Maps code values from `gift_cards.state` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|0|ISSUED|integer|[gift_cards](../exerp/gift_cards.md)|
|1|CANCELLED|integer|[gift_cards](../exerp/gift_cards.md)|
|2|EXPIRED|integer|[gift_cards](../exerp/gift_cards.md)|
|3|USED|integer|[gift_cards](../exerp/gift_cards.md)|
|4|PARTIAL USED|integer|[gift_cards](../exerp/gift_cards.md)|
