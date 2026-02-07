SELECT
        p.CENTER || 'p' || p.ID AS "Member ID",
        p.FULLNAME AS "Full name",
        p.ADDRESS1 AS "Address",
        p.ZIPCODE AS "Postnumber",
        p.CITY AS "Area",
        p.BIRTHDATE,
        floor(MONTHS_BETWEEN(exerpsysdate(),p.BIRTHDATE)/12) as "Age",
        DECODE(p.SEX,'M','Male','F','Female','Unknown') AS "Gender",
        pr.NAME AS "Subscription",
        s.START_DATE AS "Subscription startdate",
        sl.SALES_DATE AS "Subscription sales date",
        DECODE(st.ST_TYPE,0,'CASH',1,'EFT') AS "Subscription type",
        pea.TXTVALUE AS "Where did you hear?"
        
FROM PERSONS p
JOIN SUBSCRIPTIONS s ON p.CENTER=s.OWNER_CENTER AND p.ID=s.OWNER_ID
JOIN SUBSCRIPTIONTYPES st ON s.SUBSCRIPTIONTYPE_CENTER=st.CENTER AND s.SUBSCRIPTIONTYPE_ID=st.ID
JOIN SUBSCRIPTION_SALES sl ON sl.SUBSCRIPTION_CENTER=s.CENTER and sl.SUBSCRIPTION_ID=s.ID
JOIN PRODUCTS pr ON pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND pr.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN PERSON_EXT_ATTRS pea ON pea.PERSONCENTER=p.CENTER AND pea.PERSONID=p.ID AND pea.NAME='heard'
WHERE p.STATUS IN (1,3)
    AND p.CENTER IN ($$Scope$$)    
	AND sl.SALES_DATE >= $$FromDate$$
	AND sl.SALES_DATE <= $$ToDate$$
ORDER BY sl.SALES_DATE