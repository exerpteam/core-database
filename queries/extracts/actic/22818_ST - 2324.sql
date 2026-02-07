SELECT
    i1.PID
  ,i1.COMPANY_NAME
  , i1.AMOUNT_IN_CASE
  ,i1.CASE_ON_HOLD
  , i1.AMOUNT_AT_AGENCY
  , SUM(art.AMOUNT) AMOUNT_ON_DEBT_ACC
  , i1.PAYMENT_ACCOUNT_BALANCE
  , i1.OVERDUE_AMOUNT_PAYMENT_ACCOUNT
  , (
        SELECT
            SUM(ccr.REQ_AMOUNT)
        FROM
            CASHCOLLECTION_REQUESTS ccr
        WHERE
            ccr.CENTER = i1.CASE_CENTER
            AND ccr.ID = i1.CASE_ID
            AND ccr.STATE IN (-1,0) ) CC_REQUESTS_NOT_SENT
FROM
    (
        SELECT
            p.CENTER || 'p' || p.ID pid
          ,p.LASTNAME               COMPANY_NAME
          ,cc.CENTER                CASE_CENTER
          ,cc.ID                    CASE_ID
          , cc.AMOUNT               AMOUNT_IN_CASE
          ,cc.HOLD                  CASE_ON_HOLD
          , cc.CC_AGENCY_AMOUNT     AMOUNT_AT_AGENCY
          ,ard.CENTER               DEBT_CENTER
          ,ard.ID                   DEBT_ID
          , SUM(art.AMOUNT)         PAYMENT_ACCOUNT_BALANCE
          , SUM(
                CASE
                    WHEN art.DUE_DATE < TRUNC(exerpsysdate()) - pcc.CASHCOLLECTION_DELAY
                        AND art.COLLECTED = 1
                    THEN art.UNSETTLED_AMOUNT
                    ELSE 0
                END) OVERDUE_AMOUNT_PAYMENT_ACCOUNT
        FROM
            PERSONS p
        JOIN
            CENTERS c
        ON
            c.id = p.CENTER
            AND c.COUNTRY = 'SE'
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.CENTER
            AND ar.CUSTOMERID = p.ID
            AND ar.AR_TYPE = 4
            AND ar.STATE = 0
        LEFT JOIN
            PAYMENT_ACCOUNTS pac
        ON
            pac.CENTER = ar.CENTER
            AND pac.id = ar.ID
        LEFT JOIN
            PAYMENT_AGREEMENTS pa
        ON
            pa.CENTER = pac.ACTIVE_AGR_CENTER
            AND pa.ID = pac.ACTIVE_AGR_ID
            AND pa.SUBID = pac.ACTIVE_AGR_SUBID
        LEFT JOIN
            PAYMENT_CYCLE_CONFIG pcc
        ON
            pcc.ID = pa.PAYMENT_CYCLE_CONFIG_ID
        LEFT JOIN
            ACCOUNT_RECEIVABLES ard
        ON
            ard.CUSTOMERCENTER = p.CENTER
            AND ard.CUSTOMERID = p.ID
            AND ard.AR_TYPE = 5
            AND ard.STATE = 0
        JOIN
            AR_TRANS art
        ON
            art.CENTER = ar.CENTER
            AND art.ID = ar.ID
        LEFT JOIN
            CASHCOLLECTIONCASES cc
        ON
            cc.PERSONCENTER = p.CENTER
            AND cc.PERSONID = p.ID
            AND cc.MISSINGPAYMENT = 1
            AND cc.CLOSED = 0
        WHERE
            p.SEX = 'C'
        GROUP BY
            p.CENTER
          , p.ID
          , cc.AMOUNT
          , cc.CC_AGENCY_AMOUNT
          ,ard.CENTER
          ,ard.ID
          ,p.LASTNAME
          ,cc.HOLD
          ,cc.CENTER
          ,cc.ID ) i1
LEFT JOIN
    AR_TRANS art
ON
    art.CENTER = i1.debt_center
    AND art.ID = i1.debt_id
GROUP BY
    i1.PID
  , i1.AMOUNT_IN_CASE
  , i1.AMOUNT_AT_AGENCY
  , i1.PAYMENT_ACCOUNT_BALANCE
  , i1.OVERDUE_AMOUNT_PAYMENT_ACCOUNT
  ,i1.COMPANY_NAME
  ,i1.CASE_ON_HOLD
  ,i1.CASE_CENTER
  ,i1.CASE_ID 
