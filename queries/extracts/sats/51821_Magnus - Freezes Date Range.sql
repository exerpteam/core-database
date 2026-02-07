
SELECT
    f.FREEZE_ID
  , f.SUBSCRIPTION_ID
  , f.SUBSCRIPTION_CENTER_ID
  , f.START_DATE
  , f.END_DATE
  , f.STATE
  , f.TYPE
  , f.REASON
  , f.ENTRY_DATE
  , f.CANCEL_DATE
  , f.ETS
FROM
    BI_FREEZES f
WHERE
    ETS >= $$startdate$$ + (86400 * 1000) 
    AND ETS < $$enddate$$ + (86400 * 1000)    
