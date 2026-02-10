-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        st.ST_TYPE,
        s.center || 'ss' || s.id AS Subscriptionid,
        s.OWNER_CENTER || 'p' || s.OWNER_ID AS PersonId,
        s.BILLED_UNTIL_DATE,
        s.END_DATE,
        p.PERSONTYPE,
        prs.OPEN_AMOUNT,
        prs.PAID_STATE,
        (CASE 
                WHEN pr.state is null then null
                else
        DECODE(pr.state,1, 'New',2, 'Sent',3, 'Done',4, 'Done, manual',5, 'Rejected, clearinghouse',6, 'Rejected, bank',
        7, 'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',12, 'Failed, not creditor',
        13, 'Reversed, rejected',14, 'Reversed, confirmed', 17, 'Failed, payment revoked', 18, 'Done Partial', 
        19, 'Failed, Unsupported', 20, 'Require approval', 21,'Fail, debt case exists', 22,' Failed, timed out','UNDEFINED') 
        END) as  PaymentRequestState,
        (CASE
                WHEN r.CENTER IS NULL THEN NULL
                ELSE r.CENTER || 'p' || r.ID 
        END) AS OtherPayer,
        pr.REQ_AMOUNT
FROM
        PERSONS p
JOIN
        PERSON_EXT_ATTRS pea ON p.CENTER = pea.PERSONCENTER AND p.ID = pea.PERSONID AND pea.NAME = '_eClub_OldSystemPersonId'
JOIN 
        SUBSCRIPTIONS s ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID
JOIN
        SUBSCRIPTIONTYPES st ON st.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND st.ID = s.SUBSCRIPTIONTYPE_ID AND st.ST_TYPE = 1
LEFT JOIN
        ACCOUNT_RECEIVABLES ar ON ar.CUSTOMERCENTER = p.CENTER AND ar.CUSTOMERID = p.ID AND ar.AR_TYPE = 4
LEFT JOIN PAYMENT_REQUEST_SPECIFICATIONS prs ON ar.CENTER = prs.CENTER AND ar.ID = prs.ID AND prs.ORIGINAL_DUE_DATE = to_date('2019-02-26','YYYY-MM-DD')
LEFT JOIN PAYMENT_REQUESTS pr ON pr.INV_COLL_CENTER = prs.CENTER AND pr.INV_COLL_ID = prs.ID AND pr.INV_COLL_SUBID = prs.SUBID
LEFT JOIN RELATIVES r ON p.CENTER = r.RELATIVECENTER AND p.ID = r.RELATIVEID AND r.RTYPE = 12 AND r.STATUS = 1
--LEFT JOIN
--        SUBSCRIPTIONPERIODPARTS spp ON s.CENTER = spp.CENTER AND s.ID = spp.ID AND spp.FROM_DATE >= to_date('2019-03-01','YYYY-MM-DD') AND spp.TO_DATE = to_date('2019-03-31','YYYY-MM-DD') AND spp.SPP_STATE != 2
WHERE
        p.CENTER IN (544,545,546)
        AND (s.END_DATE IS NULL OR s.BILLED_UNTIL_DATE > to_date('2019-02-28','YYYY-MM-DD'))
        AND s.SUBSCRIPTION_PRICE > 0
        AND s.BILLED_UNTIL_DATE = to_date('2019-03-31','YYYY-MM-DD')
        AND s.SUB_COMMENT IS NOT NULL