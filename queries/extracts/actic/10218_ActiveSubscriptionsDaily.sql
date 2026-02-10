-- The extract is extracted from Exerp on 2026-02-08
--  
/**
* Creator: Martin Blomgren
* Purpose: Get count for active or frozen memberships within scope.
* These are supposed to be counted by center and membershiptype.
* Extract is published as an Automated Export to Qlickview daily.
*
* Include products from the following categories
* 7 = EFT Subscriptions
* 8 = Autogiromedlemskap
* 9 = AvtaleGiromedlemskap
* 10 = CASH Subscriptions
* 11 = Kontantmedlemskap
* 12 = Kontantmedlemskap
* 218 = EFT campaign subscriptions
* 219 = CASH campaign subscriptions
* 220 = Joining fee campaign subscriptions
* 221 = Kontantmedlemskap Kampanje
* 16024 = CrossFit Medlemskap
*
*/
SELECT
	cen.EXTERNAL_ID AS Cost,
	COUNT(CASE WHEN per.PERSONTYPE = 0 THEN sub.ID END) AS Private,
	COUNT(CASE WHEN per.PERSONTYPE = 1 THEN sub.ID END) AS Student,
	COUNT(CASE WHEN per.PERSONTYPE = 3 THEN sub.ID END) AS Friend,
	COUNT(CASE WHEN per.PERSONTYPE = 4 THEN sub.ID END) AS Corporate,
	COUNT(CASE WHEN per.PERSONTYPE = 5 THEN sub.ID END) AS Onemancorporate,
	COUNT(CASE WHEN per.PERSONTYPE = 6 THEN sub.ID END) AS Family,
	COUNT(CASE WHEN per.PERSONTYPE = 7 THEN sub.ID END) AS Senior,
	COUNT(*) AS Members
	
FROM
	SUBSCRIPTIONS sub
LEFT JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = sub.SUBSCRIPTIONTYPE_ID
LEFT JOIN PRODUCTS prod
ON
    st.CENTER = prod.CENTER
    AND st.ID = prod.ID
LEFT JOIN PERSONS per
ON
	sub.OWNER_CENTER = per.CENTER
	AND sub.OWNER_ID = per.ID
LEFT JOIN CENTERS cen
ON
	sub.CENTER = cen.ID

WHERE
	sub.CENTER IN (:ChosenScope)
	AND sub.STATE IN (2, 4)-- Active and frozen memberships
	AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 220, 16024)	
	AND per.PERSONTYPE != 2 -- Don't include staff
GROUP BY cen.EXTERNAL_ID
ORDER BY cen.EXTERNAL_ID
