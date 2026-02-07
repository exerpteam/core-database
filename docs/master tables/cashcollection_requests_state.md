# cashcollection_requests.state
Maps code values from `cashcollection_requests.state` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|-1|NOT_SENT|integer|[cashcollection_requests](../exerp/cashcollection_requests.md)|
|0|NEW|integer|[cashcollection_requests](../exerp/cashcollection_requests.md)|
|1|SENT|integer|[cashcollection_requests](../exerp/cashcollection_requests.md)|
|2|PAID|integer|[cashcollection_requests](../exerp/cashcollection_requests.md)|
|3|CANCELLED|integer|[cashcollection_requests](../exerp/cashcollection_requests.md)|
|4|RECEIVED|integer|[cashcollection_requests](../exerp/cashcollection_requests.md)|
|6|LEGACY|integer|[cashcollection_requests](../exerp/cashcollection_requests.md)|
|7|FAILED|integer|[cashcollection_requests](../exerp/cashcollection_requests.md)|
