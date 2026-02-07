SELECT * 
  FROM  BI_SUBSCRIPTION_SALES_LOG 
 WHERE SUBSCRIPTION_CENTER in ($$Scope$$) 
   AND ETS >= $$startdate$$
   AND ETS < $$enddate$$ + (86400 * 1000)