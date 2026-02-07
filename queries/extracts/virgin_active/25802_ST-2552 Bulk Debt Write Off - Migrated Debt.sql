SELECT
    i1."Member club"
  , i1."Membership number"
  , i1."Member Id"
  , i1."Member first name"
  , i1."Member last name"
  , i1."Member person status"
  , i1."Member on freeze"
  , i1."Membership blocked"
  , SUM(i1."Total amount of debt") "Total amount of debt"
  , SUM(i1."Amount legacy debt") "Amount legacy debt"
  , SUM(i1."Amount accrued debt") "Amount accrued debt"
  , TRUNC(SYSDATE) - MIN(i1."Number days in debt") "Number days in debt"
FROM
    (
        SELECT
            c.SHORTNAME "Member club"
          , nvl2(s.CENTER,s.CENTER || 'ss' || s.ID,'') "Membership number"
          , p.CENTER || 'p' || p.ID "Member Id"
          , p.FIRSTNAME "Member first name"
          , p.LASTNAME "Member last name"
          , DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') "Member person status"
          , CASE
                WHEN s.STATE = 4
                THEN 'Y'
                ELSE 'N'
            END "Member on freeze"
          , CASE
                WHEN s.SUB_STATE = 9
                THEN 'Y'
                ELSE 'N'
            END "Membership blocked"
          , art.UNSETTLED_AMOUNT "Total amount of debt"
          , CASE
                WHEN art.TEXT LIKE '%CCTransID=%'
                THEN art.UNSETTLED_AMOUNT
                ELSE 0
            END "Amount legacy debt"
          , CASE
                WHEN art.TEXT NOT LIKE '%CCTransID=%'
                THEN art.UNSETTLED_AMOUNT
                ELSE 0
            END "Amount accrued debt"
          , art.DUE_DATE "Number days in debt"
        FROM
            AR_TRANS art
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art.center
            AND ar.id = art.id
            and ar.AR_TYPE = 4
        JOIN
            PERSONS p
        ON
            p.CENTER = ar.CUSTOMERCENTER
            AND p.id = ar.CUSTOMERID
        LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.center
            AND s.OWNER_ID = p.id
            AND s.STATE IN (2,4,8)
        JOIN
            CENTERS c
        ON
            c.id = p.center
        LEFT JOIN
            CASHCOLLECTIONCASES cc
        ON
            cc.PERSONCENTER = p.center
            AND cc.PERSONID = p.id
            AND cc.MISSINGPAYMENT = 1
        WHERE
            art.DUE_DATE < SYSDATE
            AND c.id IN ($$scope$$)
            /* and (ar.CUSTOMERCENTER,ar.CUSTOMERID) in ((440,2574)) */
            and art.UNSETTLED_AMOUNT < 0
           
            AND (
                s.CENTER IS NULL
                OR s.ID IN
                (
                    SELECT
                        MAX(s2.id)
                    FROM
                        SUBSCRIPTIONS s2
                    WHERE
                        s2.OWNER_CENTER = s.OWNER_CENTER
                        AND s2.OWNER_ID = s.OWNER_ID
                        AND s2.STATE IN (2,4,8)) ) ) i1
GROUP BY
    i1."Member club"
  , i1."Membership number"
  , i1."Member Id"
  , i1."Member first name"
  , i1."Member last name"
  , i1."Member person status"
  , i1."Member on freeze"
  , i1."Membership blocked"