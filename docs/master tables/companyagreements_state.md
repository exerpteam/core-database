# companyagreements.state
Maps code values from `companyagreements.state` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|0|UNDER TARGET|integer|[companyagreements](../exerp/companyagreements.md)|
|1|ACTIVE|integer|[companyagreements](../exerp/companyagreements.md)|
|2|STOP NEW|integer|[companyagreements](../exerp/companyagreements.md)|
|3|OLD|integer|[companyagreements](../exerp/companyagreements.md)|
|4|AWAITING ACTIVATION|integer|[companyagreements](../exerp/companyagreements.md)|
|5|BLOCKED|integer|[companyagreements](../exerp/companyagreements.md)|
|6|DELETED|integer|[companyagreements](../exerp/companyagreements.md)|
