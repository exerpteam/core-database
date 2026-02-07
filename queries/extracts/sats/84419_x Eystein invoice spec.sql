 SELECT
     ar.CUSTOMERCENTER AS CENTER,
     ar.CUSTOMERID AS ID,
     prs.center AS PRS_CENTER,
     prs.id AS PRS_ID,
 prs.*
 FROM
     PAYMENT_REQUEST_SPECIFICATIONS prs
 join ACCOUNT_RECEIVABLES ar
     on
     prs.center = ar.center
     AND prs.id = ar.id
 WHERE
     prs.center = 500
 and prs.id = 401082
