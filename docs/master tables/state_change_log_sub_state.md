# state_change_log.sub_state
Maps code values from `state_change_log.sub_state` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|NONE|integer|[state_change_log](../exerp/state_change_log.md)|
|2|AWAITING_ACTIVATION|integer|[state_change_log](../exerp/state_change_log.md)|
|3|UPGRADED|integer|[state_change_log](../exerp/state_change_log.md)|
|4|DOWNGRADED|integer|[state_change_log](../exerp/state_change_log.md)|
|5|EXTENDED|integer|[state_change_log](../exerp/state_change_log.md)|
|6|TRANSFERRED|integer|[state_change_log](../exerp/state_change_log.md)|
|7|REGRETTED|integer|[state_change_log](../exerp/state_change_log.md)|
|8|CANCELLED|integer|[state_change_log](../exerp/state_change_log.md)|
|9|BLOCKED|integer|[state_change_log](../exerp/state_change_log.md)|
|10|CHANGED|integer|[state_change_log](../exerp/state_change_log.md)|
