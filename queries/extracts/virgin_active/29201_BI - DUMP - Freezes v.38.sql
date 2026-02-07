SELECT
    CAST ( f.ID AS VARCHAR(255))                                             "FREEZE_ID",
    f.SUBSCRIPTION_CENTER || 'ss' || f.SUBSCRIPTION_ID                       "SUBSCRIPTION_ID",
    CAST ( f.SUBSCRIPTION_CENTER AS VARCHAR(255))                            "SUBSCRIPTION_CENTER_ID",
    TO_CHAR(f.START_DATE, 'YYYY-MM-DD')                                      "START_DATE",
    TO_CHAR(f.END_DATE, 'YYYY-MM-DD')                                        "END_DATE",
    f.STATE AS                                                               "STATE",
    f.TYPE  AS                                                               "TYPE",
    f.TEXT                                                                   "REASON",
    TO_CHAR(longtodateC(f.ENTRY_TIME, f.SUBSCRIPTION_CENTER), 'YYYY-MM-DD')  "ENTRY_DATE",
    TO_CHAR(longtodateC(f.CANCEL_TIME, f.SUBSCRIPTION_CENTER), 'YYYY-MM-DD') "CANCEL_DATE",
    f.LAST_MODIFIED                                                          "ETS"
FROM
    SUBSCRIPTION_FREEZE_PERIOD f