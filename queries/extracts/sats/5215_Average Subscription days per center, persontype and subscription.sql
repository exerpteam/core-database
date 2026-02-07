SELECT 
    S.CENTER, 
    PR.NAME                                                                    
                                                                             as PRODUCTNAME, 
    DECODE ( P.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR',
8,'GUEST','UNKNOWN') AS PERSONTYPE , 
    round(AVG (exerpsysdate()-S.start_date),2)                                        
                                                                             as AVGSUBDAYS ,
    count(s.center || 'ss' || s.id )   as NBSUB 
FROM 
    SUBSCRIPTIONS S
JOIN 
    PERSONS P 
    ON 
    S.OWNER_CENTER = P.CENTER 
    and S.OWNER_ID = P.ID
JOIN 
    PRODUCTS PR 
    ON 
    PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER 
    and PR.ID = S.SUBSCRIPTIONTYPE_ID
JOIN 
    SUBSCRIPTIONTYPES ST 
    ON 
    ST.CENTER = S.SUBSCRIPTIONTYPE_CENTER 
    and ST.ID = S.SUBSCRIPTIONTYPE_ID
WHERE 
    S.CENTER IN
(:scope)
    and ST.ST_TYPE = 1 
    and exists -- check state (back in time with log)  
    ( 
    SELECT 
        * 
    FROM 
        STATE_CHANGE_LOG SC 
    WHERE 
        SC.CENTER               = S.CENTER 
        and SC.ID               = S.ID 
        and SC.ENTRY_TYPE       = 2 
        and SC.BOOK_START_TIME <=
:Date 
        and 
        ( 
            SC.BOOK_END_TIME >
:Date 
            or SC.BOOK_END_TIME is null 
        ) 
        and SC.STATEID IN (2,4) 
    )
GROUP BY 
    S.CENTER, 
    PR.NAME , 
    P.PERSONTYPE
