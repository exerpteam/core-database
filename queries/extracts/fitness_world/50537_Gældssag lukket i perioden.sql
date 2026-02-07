-- This is the version from 2026-02-05
--  
WITH 
params AS
(
	SELECT 
		/*+ materialize */
		:rykker_2_dato - (60*60*24*45*1000) AS FROMDATE, 
		:rykker_2_dato - (60*60*24*30*1000) AS TODATE,
		:periodetil + (60*60*24*1000) AS PERIODUNTIL
	FROM DUAL 
)
SELECT
cc.PERSONCENTER ||'p'|| cc.PERSONID as Memberid,
longToDate(cc.START_DATETIME) as Cash_Collection_start,
longToDate(cc.CLOSED_DATETIME) as Cash_Collection_closed, 
cc.CURRENTSTEP as "last step before close",
DECODE (s.state, 2,'Active', 3,'Ended', 4,'Frozen', 7,'Window', 8,'Created','Unknown') AS "Subscription State",
s.END_DATE as "subscription enddate"
--TO_CHAR(LONGTODATEC(params.FROMDATE, cc.PERSONCENTER),'YYYY-MM-DD') AS FromDateParam,
--TO_CHAR(LONGTODATEC(params.TODATE, cc.PERSONCENTER),'YYYY-MM-DD') AS ToDateParam,
--TO_CHAR(LONGTODATEC(:periodefra, cc.PERSONCENTER),'YYYY-MM-DD HH24:MI:SS') AS periofr,
--TO_CHAR(LONGTODATEC(:periodetil  + (60*60*24*1000), cc.PERSONCENTER),'YYYY-MM-DD HH24:MI:SS') AS perioti
from
CASHCOLLECTIONCASES cc
cross join params
join
SUBSCRIPTIONS s

on
s.OWNER_CENTER = cc.PERSONCENTER
and
s.OWNER_ID = cc.PERSONID

where
cc.CLOSED_DATETIME between :periodefra and params.PERIODUNTIL

and

cc.CURRENTSTEP = 2

and 

cc.START_DATETIME between params.FROMDATE and params.TODATE

and 

cc.CURRENTSTEP_TYPE = 2

and

cc.CASHCOLLECTIONSERVICE in (601,602)

and

s.state not in (3,7)