-- The extract is extracted from Exerp on 2026-02-08
-- Copy of the Sales count extract showinng only junior mem cats
SELECT

	cen.SHORTNAME Club,
    SS.SALES_DATE Sales_Date,
    p.CENTER || 'p' || p.ID Person_ID,
    SS.SUBSCRIPTION_CENTER || 'ss' || SS.SUBSCRIPTION_ID Subscription_ID,
    p.FULLNAME Person_Name,
    pr.NAME Subscription,
    prg.NAME Product_Group,
    SS.TYPE salesType,
    longtodateC(SU.CREATION_TIME, SU.CENTER) Created_Date
FROM
    SUBSCRIPTION_SALES SS
JOIN
    SUBSCRIPTIONS SU
ON
    SUBSCRIPTION_CENTER = SU.CENTER
    AND SUBSCRIPTION_ID = SU.ID
INNER JOIN
    SUBSCRIPTIONTYPES ST
ON
    (
        SS.SUBSCRIPTION_TYPE_CENTER = ST.CENTER
        AND SS.SUBSCRIPTION_TYPE_ID = ST.ID)
INNER JOIN
    PRODUCTS PR
ON
    (
        SS.SUBSCRIPTION_TYPE_CENTER = PR.CENTER
        AND SS.SUBSCRIPTION_TYPE_ID = PR.ID)
INNER JOIN
    PERSONS p
ON
    p.center = SS.OWNER_CENTER
    AND p.ID = ss.OWNER_ID
INNER JOIN
    CENTERS cen
ON
    cen.ID = p.CENTER
LEFT JOIN
    PRODUCT_GROUP prg
ON
    prg.ID = pr.PRIMARY_PRODUCT_GROUP_ID
WHERE
    --(SS.SUBSCRIPTION_TYPE_CENTER
		--Italian Clubs Only 
		CEN.COUNTRY = 'IT'
		--1st of the current month
		AND SS.SALES_DATE >= trunc(sysdate) - (to_number(to_char(sysdate,'DD')) - 1)
		AND 
		--New Sales
		SS.TYPE = 1 
       --Junior mem cat groups only
       AND PRG.ID IN (5406,5407)
ORDER BY 
        cen.SHORTNAME asc,
        pr.NAME asc
    
    