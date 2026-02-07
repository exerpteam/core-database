SELECT DISTINCT
    qi.Club,
    qi.MemberId,
    qi.PersonID,
    MAX(qi.LegacyMemberId) OVER (PARTITION BY qi.MemberId ORDER BY qi.DUE_DATE DESC) LegacyMemberId,
    qi.firstName,
    qi.lastName,
    TO_CHAR(ABS(MAX(total_debt_on_account)) ,'FM99999999999999999990.00') Balance,
    nvl(FIRST_VALUE(qi.DUE_DATE) OVER (PARTITION BY qi.MemberId ORDER BY qi.DUE_DATE DESC),qi.latest_due_date) DueDate,
    qi.DoB,
    qi.SubscriptionType,
    CASE
        WHEN qi.BACSRejectionCode is null
        THEN 'F'
        WHEN qi.STATE = 12
        THEN 'F'
        ELSE qi.BACSRejectionCode
    END AS BACSRejectionCode
FROM
    (
        SELECT DISTINCT
            (
                SELECT
                    SUM(art2.UNSETTLED_AMOUNT)
                FROM
                    AR_TRANS art2
                WHERE
                    art2.CENTER = art.CENTER
                    AND art2.ID = art.id
                    AND art2.UNSETTLED_AMOUNT < 0 ) AS total_debt_on_account,
            (
                SELECT
                    max(art3.DUE_DATE)
                FROM
                    AR_TRANS art3
                WHERE
                    art3.CENTER = art.CENTER
                    AND art3.ID = art.id
                    and (art3.DUE_DATE is not null and art3.DUE_DATE < sysdate)
                    AND art3.UNSETTLED_AMOUNT < 0 ) AS latest_due_date,                    
            /* Since we might have a representation we'll take the last request state */
            FIRST_VALUE(pr.STATE) OVER (PARTITION BY p.EXTERNAL_ID ORDER BY pr.ENTRY_TIME DESC) state ,
            p.CENTER                                                                            Club,
            p.firstname,
            p.lastname,
            p.EXTERNAL_ID           MemberId,
            p.CENTER || 'p' || p.ID PersonID,
            con.OLDENTITYID         LegacyMemberId,
            art.CENTER,
            art.ID,
            art.SUBID,
            art.UNSETTLED_AMOUNT,
            prs.ORIGINAL_DUE_DATE DUE_DATE,
            p.BIRTHDATE           DoB,
            /*prod.NAME                                                                                          SubscriptionType ,*/
            FIRST_VALUE(prod.NAME) OVER (PARTITION BY p.EXTERNAL_ID ORDER BY s.START_DATE ASC) SubscriptionType,
            /* Since we might have a representation we'll take the last request rejection code */
            FIRST_VALUE(pr.REJECTED_REASON_CODE) OVER (PARTITION BY p.EXTERNAL_ID ORDER BY pr.ENTRY_TIME DESC) BACSRejectionCode,
            pr.ENTRY_TIME
        FROM
            AR_TRANS art
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art.CENTER
            AND ar.ID = art.ID
            and ar.AR_TYPE = 4
		join centers c on c.id = art.center and c.country = 'GB'
        JOIN
            PERSONS pOld
        ON
            pOld.CENTER = ar.CUSTOMERCENTER
            AND pOld.ID = ar.CUSTOMERID
        JOIN
            PERSONS p
        ON
            p.CENTER = pOld.CURRENT_PERSON_CENTER
            AND p.id = pOld.CURRENT_PERSON_ID
        JOIN
            PERSONS pAll
        ON
            pAll.CURRENT_PERSON_CENTER = p.CENTER
            AND pAll.CURRENT_PERSON_ID = p.ID
        LEFT JOIN
            CONVERTER_ENTITY_STATE con
        ON
            con.NEWENTITYCENTER = pAll.CENTER
            AND con.NEWENTITYID = pAll.ID
            AND con.WRITERNAME = 'ClubLeadPersonWriter'
        LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.STATE IN (2,4,8)
        LEFT JOIN
            PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        LEFT JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.CENTER = art.PAYREQ_SPEC_CENTER
            AND prs.ID = art.PAYREQ_SPEC_ID
            AND prs.SUBID = art.PAYREQ_SPEC_SUBID
        LEFT JOIN
            PAYMENT_REQUESTS pr
        ON
            pr.INV_COLL_CENTER = prs.CENTER
            AND pr.INV_COLL_ID = prs.ID
            AND pr.INV_COLL_SUBID = prs.SUBID
        WHERE
            ((art.DUE_DATE     is not null and art.DUE_DATE < sysdate) and art.UNSETTLED_AMOUNT < 0)
            and
            /* Needs to be disabled since we will look at the total debt until ARC is in place
            art.DUE_DATE BETWEEN TRUNC(SYSDATE,'MM') AND TRUNC(SYSDATE,'DD')
            AND art.UNSETTLED_AMOUNT < 0
            and art.COLLECTED = 1
            */
            /* Linked members - exclude if the member is of type famiy */
            /*
            NOT EXISTS
            (
            SELECT
            1
            FROM
            RELATIVES rel
            WHERE
            rel.CENTER = p.CENTER
            AND rel.ID = p.ID
            AND rel.RTYPE IN (1,4,13)
            AND rel.STATUS = 1
            )
            */
            /*Debtors that have been sent to ARC/Agency - No open cash collection case
            Needs more attention. It's when they have passed some step according to Pelle which is not set up on any test systems
            */
            NOT EXISTS
            (
                SELECT
                    1
                FROM
                    CASHCOLLECTIONCASES ccc
                WHERE
                    ccc.PERSONCENTER = p.CENTER
                    AND ccc.PERSONID = p.ID
                    AND ccc.CLOSED = 0
                    AND ccc.SUCCESSFULL = 0
                    AND ccc.MISSINGPAYMENT = 1 
					and ccc.CC_AGENCY_AMOUNT is not null
)
            /* Under 18 - 18 and over is ok*/
            AND (
                MONTHS_BETWEEN (SYSDATE,p.BIRTHDATE) / 12 ) >= 18
            /* Pru Billed - I'll just assume that it's abbout being on the PRU company agreement and then fix the ca id later when we know*/
            AND  not EXISTS
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
                    AND rel.RELATIVECENTER = 4
                    AND rel.RELATIVEID = 674 )
            /* Remove all members that have any migrated debt */        
            AND NOT  EXISTS
            (
                SELECT
                    1
                FROM
                    AR_TRANS art2
                WHERE
                    art2.CENTER = ar.CENTER
                    AND art2.ID = ar.ID
                    AND art2.EMPLOYEECENTER = 100
                    AND art2.EMPLOYEEID = 1
                    AND art2.REF_TYPE = 'ACCOUNT_TRANS'
                    AND art2.AMOUNT < 0 )        
                    
            /* Company paid - If the company pays it will not be on the customers ar trans */
            /* Filter out any subs that don't have a primary group that is not derived from Membership Category Product Groups */
            AND prod.PRIMARY_PRODUCT_GROUP_ID IN
            (
                SELECT
                    pg2.ID
                FROM
                    PRODUCT_GROUP pg2
                WHERE
                    pg2.PARENT_PRODUCT_GROUP_ID = 206) ) qi
                    
GROUP BY
    qi.state,
    qi.latest_due_date,
    Club,
    MemberId,
    PersonID,
    LegacyMemberId,
    DUE_DATE,
    DoB,
    SubscriptionType,
    lastname,
    firstName,
    BACSRejectionCode
    /* All debtor under £25 - exclude all with a debt less then 25*/
HAVING
    MAX(total_debt_on_account) <= -25
    /*
    Needs to be disabled since we will look at the total debt until ARC is in place
    Looking at the total debt instead until then
    SUM(qi.UNSETTLED_AMOUNT) <= -25*/
