-- The extract is extracted from Exerp on 2026-02-08
--  
select ccOuter.PERSONCENTER||'p'||ccOuter.PERSONID, sum(ccrOuter.REQ_AMOUNT),  count(*) from  
    cashcollection_requests ccrOuter
JOIN
    CASHCOLLECTIONCASES ccOuter
 ON
    ccrOuter.CENTER = ccOuter.CENTER
    AND ccrOuter.ID = ccOuter.ID
where 
ccrOuter.REQ_DELIVERY IN ( 66207,  65811,
                                  65812,
                                  65604,
                                  65808,
                                  66205,
                                  65810,
                                  65807,
                                  66402,
                                  65809,
                                  66206,
                                  66005,
                                  65603,
                                  65803,
                                  66202,
                                  66203,
                                  65806,
                                  66401,
                                  65805,
                                  65804,
                                  65802,
                                  66204,
                                  66002 )
group by ccOuter.PERSONCENTER,ccOuter.PERSONID
