SELECT
    ar.CUSTOMERCENTER
  ,ar.CUSTOMERID
  , MAX(
        CASE
            WHEN TRUNC(months_between(SYSDATE,prs.ORIGINAL_DUE_DATE)) = 0
                AND pr.REQUEST_TYPE = 1
            THEN
                CASE
                    WHEN pr.STATE IN (3,4)
                    THEN 'PAID'
                    ELSE 'NOT PAID'
                END
            ELSE NULL
        END) PAYMENT_0
  , MAX(
        CASE
            WHEN TRUNC(months_between(SYSDATE,prs.ORIGINAL_DUE_DATE)) = 0
                AND pr.REQUEST_TYPE = 6
            THEN
                CASE
                    WHEN pr.STATE IN (3,4)
                    THEN 'PAID'
                    ELSE 'NOT PAID'
                END
            ELSE NULL
        END) Representation_0
  , MAX(
        CASE
            WHEN TRUNC(months_between(SYSDATE,prs.ORIGINAL_DUE_DATE)) = 1
                AND pr.REQUEST_TYPE = 1
            THEN
                CASE
                    WHEN pr.STATE IN (3,4)
                    THEN 'PAID'
                    ELSE 'NOT PAID'
                END
            ELSE NULL
        END) PAYMENT_1
  , MAX(
        CASE
            WHEN TRUNC(months_between(SYSDATE,prs.ORIGINAL_DUE_DATE)) = 1
                AND pr.REQUEST_TYPE = 6
            THEN
                CASE
                    WHEN pr.STATE IN (3,4)
                    THEN 'PAID'
                    ELSE 'NOT PAID'
                END
            ELSE NULL
        END) Representation_1
  , MAX(
        CASE
            WHEN TRUNC(months_between(SYSDATE,prs.ORIGINAL_DUE_DATE)) = 2
                AND pr.REQUEST_TYPE = 1
            THEN
                CASE
                    WHEN pr.STATE IN (3,4)
                    THEN 'PAID'
                    ELSE 'NOT PAID'
                END
            ELSE NULL
        END) PAYMENT_2
  , MAX(
        CASE
            WHEN TRUNC(months_between(SYSDATE,prs.ORIGINAL_DUE_DATE)) = 2
                AND pr.REQUEST_TYPE = 6
            THEN
                CASE
                    WHEN pr.STATE IN (3,4)
                    THEN 'PAID'
                    ELSE 'NOT PAID'
                END
            ELSE NULL
        END) Representation_2
  , MAX(
        CASE
            WHEN TRUNC(months_between(SYSDATE,prs.ORIGINAL_DUE_DATE)) = 3
                AND pr.REQUEST_TYPE = 1
            THEN
                CASE
                    WHEN pr.STATE IN (3,4)
                    THEN 'PAID'
                    ELSE 'NOT PAID'
                END
            ELSE NULL
        END) PAYMENT_3
  , MAX(
        CASE
            WHEN TRUNC(months_between(SYSDATE,prs.ORIGINAL_DUE_DATE)) = 3
                AND pr.REQUEST_TYPE = 6
            THEN
                CASE
                    WHEN pr.STATE IN (3,4)
                    THEN 'PAID'
                    ELSE 'NOT PAID'
                END
            ELSE NULL
        END) Representation_3
  , MAX(
        CASE
            WHEN TRUNC(months_between(SYSDATE,prs.ORIGINAL_DUE_DATE)) = 4
                AND pr.REQUEST_TYPE = 1
            THEN
                CASE
                    WHEN pr.STATE IN (3,4)
                    THEN 'PAID'
                    ELSE 'NOT PAID'
                END
            ELSE NULL
        END) PAYMENT_4
  , MAX(
        CASE
            WHEN TRUNC(months_between(SYSDATE,prs.ORIGINAL_DUE_DATE)) = 4
                AND pr.REQUEST_TYPE = 6
            THEN
                CASE
                    WHEN pr.STATE IN (3,4)
                    THEN 'PAID'
                    ELSE 'NOT PAID'
                END
            ELSE NULL
        END) Representation_4
FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    AR_TRANS art
ON
    art.center = ar.center
    AND art.id = ar.id
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = art.PAYREQ_SPEC_CENTER
    AND prs.id = art.PAYREQ_SPEC_ID
    AND prs.SUBID = art.PAYREQ_SPEC_SUBID
JOIN
    PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
WHERE
    ar.CUSTOMERCENTER in ($$scope$$)
    AND ar.AR_TYPE = 4
    AND prs.CANCELLED = 0
    AND pr.REQUEST_TYPE IN (1,6)
    AND pr.STATE NOT IN (1,2,8)
	and TRUNC(months_between(SYSDATE,prs.ORIGINAL_DUE_DATE)) < 5
GROUP BY
    ar.CUSTOMERCENTER
  ,ar.CUSTOMERID