# journalentries.jetype
Maps code values from `journalentries.jetype` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|SUBSCRIPTION_CONTRACT|integer|[journalentries](../exerp/journalentries.md)|
|2|DOCUMENTATION|integer|[journalentries](../exerp/journalentries.md)|
|3|NOTE|integer|[journalentries](../exerp/journalentries.md)|
|8|STATUS|integer|[journalentries](../exerp/journalentries.md)|
|11|PAYMENT_AGREEMENT_CONTRACT|integer|[journalentries](../exerp/journalentries.md)|
|12|CASHOUT|integer|[journalentries](../exerp/journalentries.md)|
|13|FREEZE_CREATION|integer|[journalentries](../exerp/journalentries.md)|
|14|FREEZE_CANCELLATION|integer|[journalentries](../exerp/journalentries.md)|
|15|FREEZE_CHANGE|integer|[journalentries](../exerp/journalentries.md)|
|16|OTHER_PAYER_START|integer|[journalentries](../exerp/journalentries.md)|
|17|OTHER_PAYER_STOP|integer|[journalentries](../exerp/journalentries.md)|
|18|SUBSCRIPTION_TERMINATION|integer|[journalentries](../exerp/journalentries.md)|
|19|SUBSCRIPTION_TERMINATION_CANCELLATION|integer|[journalentries](../exerp/journalentries.md)|
|20|PAYMENT_NOTE|integer|[journalentries](../exerp/journalentries.md)|
|21|ACCOUNT_PAYMENT_NOTE|integer|[journalentries](../exerp/journalentries.md)|
|22|SAVED_FREE_DAYS_USE|integer|[journalentries](../exerp/journalentries.md)|
|23|FREE_PERIOD_ASSIGNMENT|integer|[journalentries](../exerp/journalentries.md)|
|24|FREE_PERIOD_CANCELLATION|integer|[journalentries](../exerp/journalentries.md)|
|25|CASH_ACCOUNT_CREDIT|integer|[journalentries](../exerp/journalentries.md)|
|26|ADDON_TERMINATION|integer|[journalentries](../exerp/journalentries.md)|
|27|ADDON_TERMINATION_CANCELLATION|integer|[journalentries](../exerp/journalentries.md)|
|28|CHILD_RELATION_CONTRACT|integer|[journalentries](../exerp/journalentries.md)|
|29|DOCTOR_NOTE|integer|[journalentries](../exerp/journalentries.md)|
|30|ADDON_CONTRACT|integer|[journalentries](../exerp/journalentries.md)|
|31|HEALTH_CERTIFICATE|integer|[journalentries](../exerp/journalentries.md)|
|32|CREDITCARD_AGREEMENT_CONTRACT|integer|[journalentries](../exerp/journalentries.md)|
|33|CLIPCARD_BUYOUT|integer|[journalentries](../exerp/journalentries.md)|
|34|CLIPCARD_CONTRACT|integer|[journalentries](../exerp/journalentries.md)|
|35|REASSIGN_SUBSCRIPTION_CONTRACT|integer|[journalentries](../exerp/journalentries.md)|
|36|AGGREGATED_SUBSCRIPTION_CONTRACT|integer|[journalentries](../exerp/journalentries.md)|
|37|FREE_PERIOD_CHANGE|integer|[journalentries](../exerp/journalentries.md)|
