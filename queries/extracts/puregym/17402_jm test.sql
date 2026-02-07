-- 1. first representation (converted and non converted members)
SELECT
    p.center,
    p.id
    ,TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD') ORIG_DUE_DATE
        ,TO_CHAR(case when (to_char(ci.RECEIVED_DATE + 10, 'D') = to_char(to_date('2014-11-06', 'YYYY-MM-DD'), 'D')) then ci.RECEIVED_DATE + 11 else ci.RECEIVED_DATE + 10 end , 'YYYY-MM-DD') REPR_DUE_DATE

    , pr.REQ_AMOUNT
    , pag.ref
    , pr.XFR_INFO
    , ci.id
    , TO_CHAR(ci.RECEIVED_DATE, 'YYYY-MM-DD') as ARUDD_RECEIVED_DATE
	--, p.status
    , nvl(IL.TOTAL_AMOUNT,0) as AdminFee

FROM
    PUREGYM.PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    PUREGYM.ACCOUNT_RECEIVABLES ar
ON
    ar.center = prs.center
    AND ar.id = prs.id
JOIN
    PUREGYM.PERSONS p
ON
    p.center = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
JOIN PUREGYM.CASHCOLLECTIONCASES cc on cc.PERSONCENTER = p.center and cc.personid = p.id and cc.MISSINGPAYMENT = 1 and cc.CLOSED = 0

JOIN
    PUREGYM.PAYMENT_ACCOUNTS pac
ON
    pac.center = ar.center
    AND pac.id = ar.id
JOIN
    PUREGYM.PAYMENT_AGREEMENTS pag
ON
    pag.center = pac.ACTIVE_AGR_center
    AND pag.id = pac.ACTIVE_AGR_id
    AND pag.SUBID = pac.ACTIVE_AGR_SUBID
JOIN
    PUREGYM.PAYMENT_REQUESTS pr
ON
    prs.center = pr.INV_COLL_CENTER
    AND prs.id = pr.INV_COLL_ID
    AND prs.subid = pr.INV_COLL_SUBID
    AND pr.REQUEST_TYPE = 1
    --and pr.REQ_DELIVERY is null -- converted
    AND pr.STATE NOT IN (1,2,3,4,8,12)
	-- exclude inactive members
	AND p.status  in (1,3,8)
    AND ((
            pr.REQ_DELIVERY IS NULL
            AND pr.XFR_DELIVERY IS NULL 
            AND pr.REJECTED_REASON_CODE = '0')
        OR pr.xfr_info = 'Refer to payer') 
LEFT JOIN PUREGYM.CLEARING_IN ci on ci.ID = pr.XFR_DELIVERY        
LEFT JOIN INVOICELINES il on il.center = pr.REJECT_FEE_INVLINE_CENTER and il.ID = pr.REJECT_FEE_INVLINE_ID and il.SUBID = pr.REJECT_FEE_INVLINE_SUBID

WHERE
    NOT EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.PAYMENT_REQUESTS rep1_pr
        WHERE
            rep1_pr.INV_COLL_CENTER = prs.center
            AND prs.id = rep1_pr.INV_COLL_ID
            AND prs.subid = rep1_pr.INV_COLL_SUBID
            AND rep1_pr.REQUEST_TYPE = 6 
			--AND rep1_pr.STATE != 8
)
    AND pag.state = 4
	AND p.center in (:scope)
    AND ar.BALANCE < 0
    AND (
        /* nvl(ci.RECEIVED_DATE, prs.ORIGINAL_DUE_DATE) <= (SYSDATE - 7)) */
		nvl(ci.RECEIVED_DATE, prs.ORIGINAL_DUE_DATE) <= (SYSDATE - 7 - (decode(2 + TRUNC (sysdate) - TRUNC (sysdate, 'IW'),2,1,0))  ))
    AND (
        prs.ORIGINAL_DUE_DATE > (SYSDATE - 28))
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.PAYMENT_REQUESTS newer_pr
        WHERE
            newer_pr.INV_COLL_CENTER = prs.center
            AND prs.id = newer_pr.INV_COLL_ID
            AND prs.subid < newer_pr.INV_COLL_SUBID
            and newer_pr.REQUEST_TYPE = 1 and newer_pr.STATE not in (8))  
/* Exclude LAX members */
and (p.center,p.id) not in (
SELECT  
    persons.CENTER,
    persons.ID
FROM
    PERSONS persons
JOIN
    CONVERTER_ENTITY_STATE con
ON
    con.NEWENTITYCENTER = persons.CENTER
    AND con.NEWENTITYID = persons.ID
    AND con.WRITERNAME = 'ClubLeadPersonWriter'
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = persons.CENTER
    AND s.OWNER_ID = persons.ID
    AND s.STATE IN (2,4,8)
    
LEFT JOIN
    SUBSCRIPTIONS sext
ON
    sext.EXTENDED_TO_CENTER = s.CENTER
    AND sext.EXTENDED_TO_ID = s.ID
    and sext.CREATOR_CENTER = 100 and sext.CREATOR_ID = 1
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
    AND st.ST_TYPE = 1
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.id = s.SUBSCRIPTIONTYPE_ID
WHERE
    persons.CENTER IN (141,
                       147,
                       123,149)
    AND prod.GLOBALID IN ('DD_TIER_1000',
                          'LAX_PIF',
                          'DD_TIER_777')
     and ((s.CREATOR_CENTER = 100 and s.CREATOR_ID = 1) or sext.CENTER is not null) 
) 
/* END Exclude LAX members */
ORDER BY
    prs.ORIGINAL_DUE_DATE ASC