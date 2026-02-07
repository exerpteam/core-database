-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-2723
WITH
    PARAMS AS
    (
        SELECT /*+ materialize */
               $$fromDate$$ AS fromDate,
               $$toDate$$ + 24 * 3600 * 1000 AS toDate
        FROM DUAL
    )
    
SELECT 
        per.CENTER || 'p' || per.ID AS "Medlemsnummer", 
        DECODE (per.sex, 'C', 'Company','M','MALE','F','FEMALE') AS "Køn",
        floor(months_between(exerpsysdate(), per.BIRTHDATE) / 12) AS "Alder",
        per.ZIPCODE AS "Post nr.(medlem)", 
        an.NAME AS "Hold aktivitet",
        to_char(exerpro.longtodate(par.START_TIME), 'YYYY-MM-dd HH24:MI') AS "Hold tidspunkt",
        par.CENTER AS "Center nr.",
        cen.ZIPCODE AS "Post nr.(center)"
FROM 
        PARAMS,
        PERSONS per
LEFT JOIN RELATIVES rel
    ON
        per.CENTER = rel.RELATIVECENTER
        AND  per.id = rel.RELATIVEID
        AND  rel.RTYPE = 2 /* persons in company*/
        AND  rel.status = 1
LEFT JOIN PERSONS c
    ON
        c.CENTER = rel.CENTER
        AND c.id = rel.ID
        AND  rel.status = 1
JOIN    PARTICIPATIONS par  
    ON  per.center = par.participant_center 
        AND per.id = par.participant_id
JOIN    CENTERS cen
        ON cen.ID = par.CENTER
JOIN    BOOKINGS bo
    ON  par.booking_center = bo.center 
        AND  par.booking_id = bo.id
JOIN    ACTIVITY an
    ON  bo.activity = an.id
LEFT JOIN SUBSCRIPTIONS s
ON
        s.OWNER_CENTER = per.CENTER
        AND  s.OWNER_ID = per.ID
        AND  s.STATE IN (2,4)
JOIN SUBSCRIPTIONTYPES st
    ON
        s.subscriptiontype_center = st.center
        AND  s.subscriptiontype_id = st.id
JOIN PRODUCTS pr
    ON
        st.center = pr.center 
        AND st.id = pr.id
JOIN PRODUCT_GROUP productGroup 
    ON 
		pr.PRIMARY_PRODUCT_GROUP_ID = productGroup.id 
WHERE
        par.START_TIME BETWEEN PARAMS.fromDate AND PARAMS.toDate 
and     par.center in (:scope)
AND     par.state = 'PARTICIPATION' 
AND     productGroup.name <> 'Tillægs medlemskab'
order by 
per.center,
per.id,
par.START_TIME