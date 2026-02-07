SELECT
    qi.Club,
    qi.MemberId,
    qi.PersonID,
    qi.LegacyMemberId,
    SUM(qi.UNSETTLED_AMOUNT) Balance,
    qi.DUE_DATE,
    qi.DoB,
    qi.SubscriptionType,
    qi.BACSRejectionCode
FROM
    (
        SELECT DISTINCT
            p.CENTER Club,
            p.EXTERNAL_ID MemberId,
            p.CENTER || 'p' || p.ID PersonID,
            con.OLDENTITYID LegacyMemberId,
            art.CENTER,
            art.ID,
            art.SUBID,
            art.UNSETTLED_AMOUNT,
            art.DUE_DATE,
            p.BIRTHDATE DoB,
            prod.NAME SubscriptionType,
            DECODE(pr.REJECTED_REASON_CODE,'1','Instruction Cancelled','2','Payer Deceased','3','Account Transferred','4','Advance Notice Disputed','5','No Account','6','No Instruction','A','Service User Differs','B','Account Closed','UNKNOWN') BACSRejectionCode
        FROM
            AR_TRANS art
        JOIN ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art.CENTER
            AND ar.ID = art.ID
        JOIN PERSONS pOld
        ON
            pOld.CENTER = ar.CUSTOMERCENTER
            AND pOld.ID = ar.CUSTOMERID
        JOIN PERSONS p
        ON
            p.CENTER = pOld.CURRENT_PERSON_ID
            AND p.id = pOld.CURRENT_PERSON_ID
        JOIN PERSONS pAll
        ON
            pAll.CURRENT_PERSON_CENTER = p.CENTER
            AND pAll.CURRENT_PERSON_ID = p.ID
        LEFT JOIN CONVERTER_ENTITY_STATE con
        ON
            con.NEWENTITYCENTER = pAll.CENTER
            AND con.NEWENTITYID = pAll.ID
            AND con.WRITERNAME = 'ClubLeadPersonWriter'
        LEFT JOIN SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.STATE IN (2,4,8)
        LEFT JOIN PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        LEFT JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.CENTER = art.PAYREQ_SPEC_CENTER
            AND prs.ID = art.PAYREQ_SPEC_ID
            AND prs.SUBID = art.PAYREQ_SPEC_SUBID
        LEFT JOIN PAYMENT_REQUESTS pr
        ON
            pr.INV_COLL_CENTER = prs.CENTER
            AND pr.INV_COLL_ID = prs.ID
            AND pr.INV_COLL_SUBID = prs.SUBID
        WHERE
            art.DUE_DATE BETWEEN TRUNC(sysdate,'MM') AND TRUNC(sysdate,'DD')
            AND art.UNSETTLED_AMOUNT < 0
            /* Exclude Deceased payers. */
            and pr.REJECTED_REASON_CODE != 2
            /* Linked members - exclude if the member is of type famiy */
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    RELATIVES rel
                WHERE
                    rel.CENTER = p.CENTER
                    AND rel.ID = p.ID
                    AND rel.RTYPE in (1,4,13)
                    AND rel.STATUS = 1
            )
            /*Debtors that have been sent to ARC/Agency - No open cash collection case 
            Needs more attention. It's when they have passed some step according to Pelle which is not set up on any test systems
            */
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    CASHCOLLECTIONCASES ccc
                WHERE
                    ccc.PERSONCENTER = p.CENTER
                    AND ccc.PERSONCENTER = p.ID
                    AND ccc.CLOSED = 0
                    AND ccc.SUCCESSFULL = 0
                    AND ccc.MISSINGPAYMENT = 1
            )
            /* Under 18 - 18 and over is ok*/
            AND
            (
                MONTHS_BETWEEN (sysdate,p.BIRTHDATE) / 12
            )
            >= 18
            /* Pru Billed - I'll just assume that it's abbout being on the PRU company agreement and then fix the ca id later when we know*/
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    RELATIVES rel
                WHERE
                    rel.CENTER = p.CENTER
                    AND rel.ID = p.ID
                    AND rel.RTYPE = 3
                    AND rel.STATUS = 1
                    AND rel.RELATIVECENTER = -1
                    AND rel.RELATIVEID = -1
                    AND rel.RELATIVESUBID = -1
            )
            
            /* Company paid - If the company pays it will not be on the customers ar trans */
    )
    qi
GROUP BY
    Club,
    MemberId,
    PersonID,
    LegacyMemberId,
    DUE_DATE,
    DoB,
    SubscriptionType,
    BACSRejectionCode
    /* All debtor under £25 - exclude all with a debt less then 25*/
HAVING
    SUM(qi.UNSETTLED_AMOUNT) <= -25