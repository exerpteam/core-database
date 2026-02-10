-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             r.*
         FROM
             (
                 SELECT
                     rp.END_DATE,
                     rp.END_DATE+1 AS CutDate,
                     datetolongTZ(TO_CHAR(rp.end_date + 1, 'YYYY-MM-DD HH24:MI'),
                     'Europe/London')   AS CutDateLong,
                     rp.CLOSE_TIME      AS CloseLong,
                     rp.HARD_CLOSE_TIME AS HardCloseLong
                 FROM
                     REPORT_PERIODS rp
                 WHERE
                     rp.end_date IS NOT NULL
                 AND rp.end_date >= $$dateinperiod$$
                 AND rp.SCOPE_ID = 2
                 ORDER BY
                     rp.END_DATE ASC) r
--         WHERE
--             rownum = 1
                 LIMIT 1
     )
 SELECT
     CENTER,
     GL_CODE,
     SALES_CENTER,
     CASE
          WHEN GL_CODE = '515198' THEN 'ignore'
                 WHEN GL_CODE LIKE '1013%'
         THEN '101301'
         WHEN GL_CODE LIKE '1011%'
         THEN '101101'
         WHEN GL_CODE LIKE '1010%'
         OR  GL_CODE LIKE '1018%'
         THEN '101070'
         ELSE 'OTHER'
     END AS REBOOK_SALES_GL_CODE,
     AR_TYPE,
     CASE AR_TYPE
             WHEN 'payment' THEN '515005'
             WHEN 'cashcollection' THEN '515030' END AS AR_GL_CODE,
     ROUND(SUM(OPEN_AMOUNT),2)            OPEN_AMOUNT ,
     PERSON_ID ,
     SUM(OPEN_VAT_AMOUNT) AS OPEN_VAT_AMOUNT,
     CASE
         WHEN SUM(OPEN_VAT_AMOUNT) = 0
         THEN NULL
         ELSE VAT_CODE
     END AS VAT_CODE
     --,AGE_MONTHS
 FROM
     (
         SELECT
             ar.CENTER,
             'DEBT' SIGN,
             CASE  ar.AR_TYPE
                     WHEN 4 THEN 'payment'
                     WHEN 5 THEN 'cashcollection'
                     WHEN 1  THEN 'cash'
                     WHEN 6 THEN 'installmentPlan'
                     ELSE 'other'  END                          AR_TYPE,
             acc.EXTERNAL_ID                           GL_CODE,
             vatacc.EXTERNAL_ID                        VAT_CODE,
             ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID PERSON_ID,
             CASE
                 WHEN il.center IS NULL
                 THEN ar.CENTER
                 ELSE il.CENTER
             END                                               AS SALES_CENTER,
             art.CENTER || 'ar' || art.ID || 'tr' || art.SUBID    transID,
             floor(months_between( params.END_DATE,CAST(longtodateTZ(
                 CASE
                     WHEN org2art.TRANS_TIME IS NOT NULL
                     THEN org2art.TRANS_TIME
                     WHEN orgart.TRANS_TIME IS NOT NULL
                     THEN orgart.TRANS_TIME
                     ELSE art.TRANS_TIME
                 END, 'Europe/London')AS DATE))) AS AGE_MONTHS,
             -- Proportion of the open amount according to the invoice line
             ROUND(ABS(
                 CASE
                     WHEN il.TOTAL_AMOUNT IS NULL
                     AND orgart.AMOUNT IS NULL
                         -- No invoice line, no transfer between accounts
                     THEN art.AMOUNT
                     WHEN il.TOTAL_AMOUNT IS NULL
                     AND org2art.AMOUNT IS NULL
                         -- No invoice line, no transfer between accounts
                     THEN orgart.AMOUNT * tst.AMOUNT/orgart.AMOUNT
                     WHEN il.TOTAL_AMOUNT IS NULL
                     AND org2art.AMOUNT IS NOT NULL
                         -- No invoice line but transfer between accounts twice
                     THEN org2art.AMOUNT * t2st.AMOUNT/org2art.AMOUNT* tst.AMOUNT/orgart.AMOUNT
                     WHEN tst.AMOUNT IS NULL
                         -- Invoice line on account
                     THEN IL.TOTAL_AMOUNT
                     WHEN t2st.AMOUNT IS NULL
                         -- Invoice line that has been transferred between accounts
                     THEN IL.TOTAL_AMOUNT* tst.AMOUNT/orgart.AMOUNT
                         -- Invoice line that has been transferred twice between accounts
                     ELSE IL.TOTAL_AMOUNT* t2st.AMOUNT/org2art.AMOUNT* tst.AMOUNT/ orgart.AMOUNT
                 END) *
             -- How much is open (percentage)
             COALESCE(
                   (
                   SELECT
                       1+ SUM(st.AMOUNT) /art.AMOUNT
                   FROM
                       ART_MATCH st ,
                       AR_TRANS arts
                   WHERE
                       st.ART_PAID_CENTER = art.CENTER
                   AND st.ART_PAID_ID = art.ID
                   AND st.ART_PAID_SUBID = art.SUBID
                   AND st.ENTRY_TIME < params.CloseLong
                   AND (
                           st.CANCELLED_TIME IS NULL
                       OR  st.CANCELLED_TIME > params.CloseLong)
                   AND arts.CENTER = st.ART_PAYING_CENTER
                   AND arts.ID = st.ART_PAYING_ID
                   AND arts.SUBID = st.ART_PAYING_SUBID
                   AND arts.ENTRY_TIME < params.CloseLong
                   AND arts.TRANS_TIME < params.CutDateLong ),1) , 4) OPEN_AMOUNT,
             -- Proportion of the open amount according to the invoice line
             ROUND(ABS(
                 CASE
                     WHEN il.TOTAL_AMOUNT IS NULL
                         -- No invoice line
                     THEN 0
                     WHEN tst.AMOUNT IS NULL
                         -- Invoice line on account
                     THEN vattrans.AMOUNT
                         -- Invoice line that has been transferred between accounts
                     ELSE vattrans.AMOUNT* tst.AMOUNT/orgart.AMOUNT
                 END) *
             -- How much is open (percentage)
             COALESCE(
                   (
                   SELECT
                       1+ SUM(st.AMOUNT) /art.AMOUNT
                   FROM
                       ART_MATCH st ,
                       AR_TRANS arts
                   WHERE
                       st.ART_PAID_CENTER = art.CENTER
                   AND st.ART_PAID_ID = art.ID
                   AND st.ART_PAID_SUBID = art.SUBID
                   AND st.ENTRY_TIME < params.CloseLong
                   AND (
                           st.CANCELLED_TIME IS NULL
                       OR  st.CANCELLED_TIME > params.CloseLong)
                   AND arts.CENTER = st.ART_PAYING_CENTER
                   AND arts.ID = st.ART_PAYING_ID
                   AND arts.SUBID = st.ART_PAYING_SUBID
                   AND arts.ENTRY_TIME < params.CloseLong
                   AND arts.TRANS_TIME < params.CutDateLong ),1) ,4) OPEN_VAT_AMOUNT
         FROM
             params
         CROSS JOIN
             ACCOUNT_RECEIVABLES ar
         JOIN
             AR_TRANS art
         ON
             ar.CENTER = art.CENTER
         AND ar.ID = art.ID
             -- We want the GL codes
         LEFT JOIN
             -- transaction transfered from another account.
             AR_TRANS tart
         ON
             tart.REF_TYPE = art.ref_TYPE
         AND tart.ref_center = art.ref_center
         AND tart.ref_id = art.ref_id
         AND tart.ref_subid = art.ref_subid
         AND tart.id <> art.id
         AND tart.ENTRY_TIME < params.CloseLong
         AND tart.TRANS_TIME < params.CutDateLong
         LEFT JOIN
             ( params p1
         CROSS JOIN
             ART_MATCH tst
         JOIN
             AR_TRANS orgart
         ON
             orgart.CENTER = tst.ART_PAID_CENTER
         AND orgart.ID = tst.ART_PAID_ID
         AND orgart.SUBID = tst.ART_PAID_SUBID
         AND orgart.ENTRY_TIME < p1.CloseLong
         AND orgart.TRANS_TIME < p1.CutDateLong )
         ON
             tst.ART_PAYING_CENTER = tart.CENTER
         AND tst.ART_PAYING_ID = tart.ID
         AND tst.ART_PAYING_SUBID = tart.SUBID
         AND tst.ENTRY_TIME < params.CloseLong
         AND (
                 tst.CANCELLED_TIME IS NULL
             OR  tst.CANCELLED_TIME > params.CloseLong)
         LEFT JOIN
             -- transaction transfered from another account.
             AR_TRANS t2art
         ON
             t2art.REF_TYPE = orgart.ref_TYPE
         AND t2art.ref_center = orgart.ref_center
         AND t2art.ref_id = orgart.ref_id
         AND t2art.ref_subid = orgart.ref_subid
         AND t2art.id <> orgart.id
         AND t2art.ENTRY_TIME < params.CloseLong
         AND t2art.TRANS_TIME < params.CutDateLong
         LEFT JOIN
             ( params p2
         CROSS JOIN
             ART_MATCH t2st
         JOIN
             AR_TRANS org2art
         ON
             org2art.CENTER = t2st.ART_PAID_CENTER
         AND org2art.ID = t2st.ART_PAID_ID
         AND org2art.SUBID = t2st.ART_PAID_SUBID
         AND org2art.ENTRY_TIME < p2.CloseLong
         AND org2art.TRANS_TIME < p2.CutDateLong )
         ON
             t2st.ART_PAYING_CENTER = t2art.CENTER
         AND t2st.ART_PAYING_ID = t2art.ID
         AND t2st.ART_PAYING_SUBID = t2art.SUBID
         AND t2st.ENTRY_TIME < params.CloseLong
         AND (
                 t2st.CANCELLED_TIME IS NULL
             OR  t2st.CANCELLED_TIME > params.CloseLong)
         LEFT JOIN
             INVOICELINES il
         ON
             (
                 orgart.center IS NULL
             AND art.REF_TYPE = 'INVOICE'
             AND art.REF_CENTER = il.center
             AND art.REF_ID = il.id )
         OR  (
                 orgart.center IS NOT NULL
             AND orgart.REF_TYPE = 'INVOICE'
             AND orgart.REF_CENTER = il.center
             AND orgart.REF_ID = il.id )
         OR  (
                 org2art.center IS NOT NULL
             AND org2art.REF_TYPE = 'INVOICE'
             AND org2art.REF_CENTER = il.center
             AND org2art.REF_ID = il.id )
         LEFT JOIN
             ACCOUNT_TRANS gltrans
         ON
             (
                 il.ACCOUNT_TRANS_CENTER IS NOT NULL
             AND gltrans.center = il.ACCOUNT_TRANS_CENTER
             AND gltrans.id = il.ACCOUNT_TRANS_ID
             AND gltrans.subid = il.ACCOUNT_TRANS_SUBID )
         OR  (
                 il.ACCOUNT_TRANS_CENTER IS NULL
             AND org2art.REF_TYPE = 'ACCOUNT_TRANS'
             AND org2art.REF_CENTER = gltrans.center
             AND org2art.REF_ID = gltrans.id
             AND org2art.REF_SUBID = gltrans.subid)
         OR  (
                 il.ACCOUNT_TRANS_CENTER IS NULL
             AND org2art.REF_TYPE IS NULL
             AND orgart.REF_TYPE = 'ACCOUNT_TRANS'
             AND orgart.REF_CENTER = gltrans.center
             AND orgart.REF_ID = gltrans.id
             AND orgart.REF_SUBID = gltrans.subid)
         OR  (
                 il.ACCOUNT_TRANS_CENTER IS NULL
             AND orgart.REF_TYPE IS NULL
             AND art.REF_TYPE = 'ACCOUNT_TRANS'
             AND art.REF_CENTER = gltrans.center
             AND art.REF_ID = gltrans.id
             AND art.REF_SUBID = gltrans.subid )
         LEFT JOIN
             ACCOUNTS acc
         ON
             gltrans.CREDIT_ACCOUNTCENTER = acc.CENTER
         AND gltrans.CREDIT_ACCOUNTID = acc.ID
         LEFT JOIN
             ACCOUNT_TRANS vattrans
         ON
             vattrans.center = il.VAT_ACC_TRANS_CENTER
         AND vattrans.id = il.VAT_ACC_TRANS_ID
         AND vattrans.subid = il.VAT_ACC_TRANS_SUBID
         LEFT JOIN
             ACCOUNTS vatacc
         ON
             vattrans.CREDIT_ACCOUNTCENTER = vatacc.CENTER
         AND vattrans.CREDIT_ACCOUNTID = vatacc.ID
         WHERE
             art.CENTER IN
             (
                 SELECT
                     c.id
                 FROM
                     centers c
                 WHERE
                     c.country = 'GB'
                 AND id = ($$center$$))
         AND art.AMOUNT < 0
         AND art.ENTRY_TIME < params.CloseLong
         AND art.TRANS_TIME < params.CutDateLong
         AND (
                 ar.BALANCE <> 0
             OR  ar.LAST_ENTRY_TIME >= params.CutDateLong - 31622400000)
---(366 * 24 * 60 * 60 * 1000) )

             -- Only the rows in debt (% open > 0)
         AND COALESCE(
                   (
                   SELECT
                       1- SUM(st.AMOUNT) /ABS(art.AMOUNT)
                   FROM
                       ART_MATCH st ,
                       AR_TRANS arts
                   WHERE
                       st.ART_PAID_CENTER = art.CENTER
                   AND st.ART_PAID_ID = art.ID
                   AND st.ART_PAID_SUBID = art.SUBID
                   AND st.ENTRY_TIME < params.CloseLong
                   AND (
                           st.CANCELLED_TIME IS NULL
                       OR  st.CANCELLED_TIME > params.CloseLong)
                   AND arts.CENTER = st.ART_PAYING_CENTER
                   AND arts.ID = st.ART_PAYING_ID
                   AND arts.SUBID = st.ART_PAYING_SUBID
                   AND arts.ENTRY_TIME < params.CloseLong
                   AND arts.TRANS_TIME < params.CutDateLong ),1) > 0
         ORDER BY
             art.CENTER,
             art.ID,
             art.SUBID) t1
 GROUP BY
     CENTER,
     GL_CODE,
     SALES_CENTER,
     VAT_CODE ,
     AR_TYPE
     ,
     PERSON_ID  /**,
     AGE_MONTHS **/
 ORDER BY
     CENTER,
     AR_TYPE
     ,
     PERSON_ID
     /**, OPEN_AMOUNT
     ,AGE_MONTHS**/
     ,
     GL_CODE
