/*
 * Creator: Mikahel Ahlberg
 * Purpose: 
 * SoldCardsDaily
 * mimics the Subscription sales report in Exerp
 * filter on salesdate. Used for finaceauditing.
 */

SELECT
	ss.ID,
	cen.COUNTRY,
	cen.EXTERNAL_ID AS Cost,
	ss.OWNER_CENTER || 'p' || ss.OWNER_ID AS PersonId,
    DECODE (ss.OWNER_TYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT','UNKNOWN') AS PersonType,
	TO_CHAR(trunc(months_between(TRUNC(exerpsysdate()), per.birthdate)/12)) AS Age,
	ss.EMPLOYEE_CENTER || 'emp' || ss.EMPLOYEE_ID AS Sales_Employee,
    DECODE(ss.SUBSCRIPTION_TYPE_TYPE, 0, 'CASH', 1, 'EFT', 'UKNOWN') as PaymentType,
	/* CASE
		WHEN ss.CANCELLATION_DATE IS NOT NULL THEN 'CANCEL'
		WHEN ss.TERMINATION_DATE IS NOT NULL THEN 'TERMINATION'
		ELSE DECODE(ss.TYPE, 1, 'NEW', 2, 'EXTENSION', 3, 'CHANGE')
	END AS SalesType, */
	CASE
		WHEN ss.TYPE = 1
		THEN 1
		ELSE 0
	END AS New,
	CASE
		WHEN ss.TYPE = 2
		THEN 1
		ELSE 0
	END AS Extension,
	CASE
		WHEN ss.TYPE = 3
		THEN 1
		ELSE 0
	END AS Change,
	CASE
		WHEN ss.CANCELLATION_DATE IS NOT NULL THEN 1
		ELSE 0
	END	AS Cancel,
	CASE
		WHEN ss.TERMINATION_DATE IS NOT NULL THEN 1
		ELSE 0
	END AS Termination,
	ss.PRICE_NEW AS JoiningOriginal,
	ss.PRICE_NEW_SPONSORED AS JoiningSponsored,
	ss.PRICE_NEW_DISCOUNT AS JoiningRebate,
	ss.PRICE_INITIAL AS InitialOriginal,
	ss.PRICE_INITIAL_SPONSORED AS InitialSponsored,
	ss.PRICE_INITIAL_DISCOUNT AS InitialRebate,
	ss.PRICE_PERIOD AS InitialCustomer,
	prod.price as OriginalProductPrice,
-------------------------------------------------
-- calculate cash price	per month
	CASE
		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN trunc(ss.PRICE_PERIOD / MONTHS_BETWEEN((ss.END_DATE + 1), ss.START_DATE), 2) -- cash pr month
		WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN ss.PRICE_PERIOD
	END   AS MonthlyPrice,
	
	CASE WHEN sp.PRICE IS NULL 
		 THEN CASE
				WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN trunc(ss.PRICE_PERIOD / MONTHS_BETWEEN((ss.END_DATE + 1), ss.START_DATE), 2) -- cash pr month
				WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN ss.PRICE_PERIOD
			  END
		 ELSE CASE
				WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN trunc(sp.PRICE / MONTHS_BETWEEN((ss.END_DATE + 1), ss.START_DATE), 2) -- cash pr month
				WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN sp.PRICE
			  END		
	END	AS SP_PRICE,
-------------------------------------------------
	-- sp.PRICE AS SP_PRICE,
	CASE
		WHEN sp.TYPE IS NULL THEN 'NORMAL'
		ELSE sp.TYPE
	END	AS SP_TYPE,
--	sp.TYPE AS SP_TYPE,
	sp.FROM_DATE AS SP_FROM_DATE,
	sp.TO_DATE AS SP_TO_DATE,
	sp.APPLIED AS SP_APPLIED,
--	sp.COMENT AS sp_COMENT,
	ss.CREDITED,
	ss.BINDING_DAYS,
	ss.SALES_DATE,
	ss.START_DATE,
	CASE
		WHEN ss.END_DATE IS NULL
		THEN sub.END_DATE
		ELSE ss.END_DATE
	END AS End_Date,
--	ss.END_DATE AS old_end_date,
	ss.SUBSCRIPTION_CENTER || 'ss' || ss.SUBSCRIPTION_ID AS Subscription,
	ss.CANCELLATION_DATE,
	ss.TERMINATION_DATE,
	CASE
		WHEN ss.CANCELLATION_DATE IS NOT NULL OR ss.TERMINATION_DATE IS NOT NULL
		THEN ss.CANCELLATION_EMPLOYEE_CENTER || 'emp' || ss.CANCELLATION_EMPLOYEE_ID
		ELSE NULL
	END AS Cancellation_Employee,
	prod.NAME AS Product_Name,
	prod.GLOBALID AS Global_Id,
	pg.NAME AS ProductGroup

FROM SUBSCRIPTION_SALES ss
LEFT JOIN PERSONS per
ON
	ss.OWNER_CENTER = per.CENTER
	AND ss.OWNER_ID = per.ID
LEFT JOIN SUBSCRIPTIONS sub
ON
	ss.SUBSCRIPTION_CENTER = sub.CENTER
	AND ss.SUBSCRIPTION_ID	= sub.id

LEFT JOIN PRODUCTS prod
ON
	ss.SUBSCRIPTION_TYPE_CENTER = prod.CENTER
	AND ss.SUBSCRIPTION_TYPE_ID	= prod.ID
LEFT JOIN PRODUCT_GROUP pg
ON
	prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID
LEFT JOIN SUBSCRIPTION_PRICE sp
ON
	sub.CENTER = sp.SUBSCRIPTION_CENTER
	AND sub.ID = sp.SUBSCRIPTION_ID
    AND sp.FROM_DATE <= sub.START_DATE
    AND
        (sp.TO_DATE IS NULL
        OR sp.TO_DATE >= sub.START_DATE)
	AND SP.CANCELLED = 0
LEFT JOIN CENTERS cen
ON
	ss.OWNER_CENTER = cen.ID

-------------------------------------------------------------
WHERE
	ss.OWNER_CENTER IN (:Scope)
	AND ss.SALES_DATE  >= (:From_date)
 	AND ss.SALES_DATE < (:To_date)
	AND ss.OWNER_TYPE != 2

	