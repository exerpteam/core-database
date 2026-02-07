SELECT
	cen.COUNTRY,
	cen.EXTERNAL_ID 										AS Cost,
	sub.CENTER || 'ss' || sub.ID 							AS Subscription,
	sub.OWNER_CENTER || 'p' || sub.OWNER_ID 				AS PersonId,
	TO_CHAR(longToDate(sub.CREATION_TIME), 'YYYY-MM-DD') 	AS Sales_Date,
	sub.START_DATE,
	sub.END_DATE,
    DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') Current_STATE,
    DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  Current_SUB_STATE,
    DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') 		AS PaymentType,

--	'DELIMITER',
	TO_CHAR(longToDate(sp_campaign.ENTRY_TIME), 'YYYY-MM-DD') AS campaign_Entry_time,
	sp_campaign.FROM_DATE 									AS campaign_FROM_DATE,
	sp_campaign.TO_DATE 									AS campaign_to_DATE,
--	sp_campaign.SUBSCRIPTION_CENTER || 'ss' || sp_campaign.SUBSCRIPTION_ID AS c_sub,
	sp_campaign.PRICE 										AS campaign_PRICE,
--	sp_campaign.BINDING 									AS c_BINDING,
--	sp_campaign.EMPLOYEE_CENTER || 'emp' || sp_campaign.EMPLOYEE_ID AS c_Employee,
	sp_campaign.TYPE 										AS campaign_type,
--	sp_campaign.COMENT 										AS c_coment,

--	'DELIMITER',
	TO_CHAR(longToDate(sp_normal.ENTRY_TIME), 'YYYY-MM-DD') AS normal_Entry_time,
	sp_normal.FROM_DATE 									AS normal_from_date,
	sp_normal.TO_DATE 										AS normal_to_date,
--	sp_normal.SUBSCRIPTION_CENTER || 'ss' || sp_normal.SUBSCRIPTION_ID AS n_sub,
	sp_normal.PRICE 										AS normal_price,
--	sp_normal.BINDING 										AS n_binding,
--	sp_normal.EMPLOYEE_CENTER || 'emp' || sp_normal.EMPLOYEE_ID AS Employee,
	sp_normal.TYPE 											AS normal_type
--	sp_normal.COMENT										AS n_coment

FROM SUBSCRIPTIONS sub
INNER JOIN SUBSCRIPTIONTYPES st
ON
	sub.SUBSCRIPTIONTYPE_CENTER = st.CENTER
	AND sub.SUBSCRIPTIONTYPE_ID = st.ID
	
INNER JOIN SUBSCRIPTION_PRICE sp_campaign
ON
	sub.CENTER = sp_campaign.SUBSCRIPTION_CENTER
	AND sub.ID	= sp_campaign.SUBSCRIPTION_ID
	AND sp_campaign.TYPE LIKE 'CAMPAIGN'

INNER JOIN SUBSCRIPTION_PRICE sp_normal
ON
	sub.CENTER = sp_normal.SUBSCRIPTION_CENTER
	AND sub.ID	= sp_normal.SUBSCRIPTION_ID
	AND sp_normal.TYPE LIKE 'NORMAL'

LEFT JOIN CENTERS cen
ON
	sub.OWNER_CENTER = cen.ID

WHERE
	sub.CENTER IN (:Scope)
--	AND sub.STATE IN (2, 8)
	AND st.ST_TYPE = 1
	AND sub.CREATION_TIME BETWEEN :fromDate AND :toDate
