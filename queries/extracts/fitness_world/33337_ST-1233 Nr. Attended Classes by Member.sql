-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT /*+ materialize */
            $$StartDate$$ AS start_date,
            $$EndDate$$ + 24*3600*1000 AS end_date
        FROM
            dual
    )
SELECT p.CENTER || 'p' || p.ID as "Member id",
       pr.NAME as "Subscription name" ,
       count(*) as "Number of classes",
       to_char(exerpro.longtodate(part.start_time), 'YYYY') as Year
FROM 
        params,
        PERSONS p
JOIN SUBSCRIPTIONS s ON p.CENTER=s.OWNER_CENTER AND p.ID=s.OWNER_ID
JOIN PRODUCTS pr ON pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND pr.ID = s.SUBSCRIPTIONTYPE_ID
JOIN PARTICIPATIONS part ON part.PARTICIPANT_CENTER=p.CENTER AND part.PARTICIPANT_ID=p.ID AND part.STATE='PARTICIPATION'
WHERE 
        s.STATE IN (2,4,8)
        AND (pr.GLOBALID = 'EFT_LOCAL_NORMAL' OR pr.GLOBALID = 'EFT_NORMAL')
        AND part.START_TIME >= params.start_date and part.START_TIME < params.end_date
        AND p.center = 101
        
GROUP BY
     p.CENTER,
     p.ID,
     pr.NAME,
     to_char(exerpro.longtodate(part.start_time), 'YYYY') 
