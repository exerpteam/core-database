-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS MATERIALIZED
     (
         SELECT
            
             longtodateTZ($$CutDate$$, 'Europe/Copenhagen') cutDateAsDate,
             $$CutDate$$ cutDateAsLong
     )
 SELECT DISTINCT
     personid || ', ' || subscriptionId id,
     OWNER_CENTER CENTER,
     personId,
     startdate,
     enddate,
     creation,
     pgName,
     SUM(ACTIVE_CLOSING) ACTIVE_CLOSING,
     SUM(BLOCKED) BLOCKED,
     BLOCKED_ENTRY_TIME,
     SUM(FROZEN) FROZEN,
     SUM(MISSING_AGREEMENT) MISSING_DDI,
     SUM(WINDOW_T) "WINDOW",
     SUM(DEFERRED_ONE_MONTH) DEFERRED_ONE_MONTH,
     SUM(DEFERRED_TWO_MONTHS) DEFERRED_TWO_MONTHS,
     SUM(DEFERRED_LATER) DEFERRED_LATER,
     SUM(ACTIVE_CLOSING) + SUM(BLOCKED) + SUM(MISSING_AGREEMENT) + SUM(FROZEN) + SUM(DEFERRED_TWO_MONTHS) + SUM
     (DEFERRED_LATER) + SUM(WINDOW_T) LIVE_CLOSING,
     SUB_CENTER,
     SUB_ID
 FROM
     (
         SELECT
             SU.OWNER_CENTER,
             SU.OWNER_ID,
             SU.OWNER_CENTER || 'p' || SU.OWNER_ID personId,
             SU.CENTER || 'ss' || SU.ID subscriptionId,
             SU.CENTER SUB_CENTER,
             SU.ID SUB_ID,
             PR.name memType,
             PG.NAME pgName,
             TO_CHAR(SU.START_DATE, 'YYYY-MM-DD') STARTDATE,
             TO_CHAR(SU.END_DATE, 'YYYY-MM-DD') ENDDATE,
             TO_CHAR(longtodateTZ(SU.CREATION_TIME, 'Europe/Copenhagen'), 'YYYY-MM-DD') CREATION,
             TO_CHAR(longtodateTZ(SCL1.ENTRY_START_TIME, 'Europe/Copenhagen'), 'YYYY-MM-DD HH24:MI') ENTRY_START
             ,
             TO_CHAR(longtodateTZ(SCL1.ENTRY_END_TIME, 'Europe/Copenhagen'), 'YYYY-MM-DD HH24:MI') ENTRY_END,
             CASE
                 WHEN SCL1.STATEID IN (2,4,8)
                 THEN 1
                 ELSE 0
             END ACTIVE_CLOSING,
             CASE
                 WHEN SCL1.STATEID IN (2,4,8)
                     AND SCL1.SUB_STATE IN (9)
                     AND SCL1.ENTRY_START_TIME < datetolong(TO_CHAR(DATE_TRUNC('month',params.CutDateAsDate),
                     'YYYY-MM-DD HH24:MI'))
                 THEN -1
                 ELSE 0
             END BLOCKED,
             CASE
                 WHEN SCL1.STATEID IN (4)
                     AND NOT(SCL1.SUB_STATE IN (9)
                         AND SCL1.ENTRY_START_TIME < datetolong(TO_CHAR(DATE_TRUNC('month',params.CutDateAsDate),
                         'YYYY-MM-DD HH24:MI')))
                 THEN -1
                 ELSE 0
             END FROZEN,
             CASE
                 WHEN SCL1.STATEID IN (2,4,8)
                     AND SCL1.STATEID NOT IN (4)
                     AND NOT(SCL1.SUB_STATE IN (9)
                         AND SCL1.ENTRY_START_TIME < datetolong(TO_CHAR(DATE_TRUNC('month',params.CutDateAsDate),
                         'YYYY-MM-DD HH24:MI')))
                     AND ((memberAgreementCase.PERSONCENTER IS NOT NULL
                             AND EXISTS(
                             (
                                 SELECT
                                     1,
                                     ar.balance - SUM(COALESCE(art.AMOUNT,0)) AS BalanceAtCutDate
                                 FROM
                                     ACCOUNT_RECEIVABLES ar
                                 CROSS JOIN
                                     params
                                 LEFT JOIN
                                     AR_TRANS art
                                 ON
                                     art.center = ar.center
                                     AND art.id = ar.id
                                     AND art.ENTRY_TIME >= params.CutDateAsLong
                                 WHERE
                                     ar.AR_TYPE = 4
                                     AND ar.CUSTOMERCENTER = SU.OWNER_CENTER
                                     AND ar.CUSTOMERID = SU.OWNER_ID
                                 GROUP BY
                                     ar.center,
                                     ar.id,
                                     ar.AR_TYPE,
                                     ar.CUSTOMERCENTER,
                                     ar.customerid,
                                     ar.balance
                                 HAVING
                                     ar.balance - SUM(COALESCE(art.AMOUNT,0)) < 0)))
                         OR (opAgreementCase.RELATIVECENTER IS NOT NULL
                             AND EXISTS(
                             (
                                 SELECT
                                     1,
                                     ar.balance - SUM(COALESCE(art.AMOUNT,0)) AS BalanceAtCutDate
                                 FROM
                                     ACCOUNT_RECEIVABLES ar
                                 CROSS JOIN
                                     params
                                 LEFT JOIN
                                     AR_TRANS art
                                 ON
                                     art.center = ar.center
                                     AND art.id = ar.id
                                     AND art.ENTRY_TIME >= params.CutDateAsLong
                                 WHERE
                                     ar.AR_TYPE = 4
                                     AND ar.CUSTOMERCENTER = opAgreementCase.PAYERCENTER
                                     AND ar.CUSTOMERID = opAgreementCase.PAYERID
                                 GROUP BY
                                     ar.center,
                                     ar.id,
                                     ar.AR_TYPE,
                                     ar.CUSTOMERCENTER,
                                     ar.customerid,
                                     ar.balance
                                 HAVING
                                     ar.balance - SUM(COALESCE(art.AMOUNT,0)) < 0))))
                 THEN -1
                 ELSE 0
             END MISSING_AGREEMENT,
             CASE
                 WHEN SCL1.STATEID IN (7)
                     AND SCL1.SUB_STATE NOT IN (5)
                     AND ST.ST_TYPE = 0
                     AND ((ST.PERIODCOUNT = 1
                             AND ST.PERIODUNIT = 3)
                         OR (ST.PERIODCOUNT = 12
                             AND ST.PERIODUNIT = 2)
                         OR (ST.PERIODCOUNT = 6
                             AND ST.PERIODUNIT = 2))
                     AND NOT(SCL1.SUB_STATE IN (9)
                         AND SCL1.ENTRY_START_TIME < datetolong(TO_CHAR(DATE_TRUNC('month',params.CutDateAsDate),
                         'YYYY-MM-DD HH24:MI')))
                     AND memberAgreementCase.PERSONCENTER IS NULL
                     AND opAgreementCase.RELATIVECENTER IS NULL
                 THEN 1
                 ELSE 0
             END WINDOW_T,
             CASE
                 WHEN SCL1.STATEID IN (8)
                     AND NOT(SCL1.SUB_STATE IN (9)
                         AND SCL1.ENTRY_START_TIME < datetolong(TO_CHAR(DATE_TRUNC('month',params.CutDateAsDate),
                         'YYYY-MM-DD HH24:MI')))
                     AND memberAgreementCase.PERSONCENTER IS NULL
                     AND opAgreementCase.RELATIVECENTER IS NULL
                     AND SU.START_DATE <= params.CutDateAsDate + interval '1 month'
                 THEN -1
                 ELSE 0
             END DEFERRED_ONE_MONTH,
             CASE
                 WHEN SCL1.STATEID IN (8)
                     AND NOT(SCL1.SUB_STATE IN (9)
                         AND SCL1.ENTRY_START_TIME < datetolong(TO_CHAR(DATE_TRUNC('month',params.CutDateAsDate),
                         'YYYY-MM-DD HH24:MI')))
                     AND memberAgreementCase.PERSONCENTER IS NULL
                     AND opAgreementCase.RELATIVECENTER IS NULL
                     AND SU.START_DATE > params.CutDateAsDate + interval '1 month'
                     AND SU.START_DATE <= params.CutDateAsDate + interval '2 month'
                 THEN -1
                 ELSE 0
             END DEFERRED_TWO_MONTHS,
             CASE
                 WHEN SCL1.STATEID IN (8)
                     AND NOT(SCL1.SUB_STATE IN (9)
                         AND SCL1.ENTRY_START_TIME < datetolong(TO_CHAR(DATE_TRUNC('month',params.CutDateAsDate),
                         'YYYY-MM-DD HH24:MI')))
                     AND memberAgreementCase.PERSONCENTER IS NULL
                     AND opAgreementCase.RELATIVECENTER IS NULL
                     AND SU.START_DATE > params.CutDateAsDate + interval '2 month'
                 THEN -1
                 ELSE 0
             END DEFERRED_LATER,
             perCreation.txtvalue "Original joined date",
             oldSystemId.txtvalue "Old System Id",
             CASE
                 WHEN SCL1.SUB_STATE IN (9)
                 THEN TO_CHAR(longtodateTZ(SCL1.ENTRY_START_TIME, 'Europe/Copenhagen'), 'YYYY-MM-DD HH24:MI')
                 ELSE NULL
             END BLOCKED_ENTRY_TIME
         FROM
             SUBSCRIPTIONS SU
             cross join params
         INNER JOIN
             SUBSCRIPTIONTYPES ST
         ON
             (
                 SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                 AND SU.SUBSCRIPTIONTYPE_ID = ST.ID )
         INNER JOIN
             STATE_CHANGE_LOG SCL1
         ON
             (
                 SCL1.CENTER = SU.CENTER
                 AND SCL1.ID = SU.ID
                 AND SCL1.ENTRY_TYPE = 2
                 AND SCL1.STATEID IN (2,
                                      4,7,8)
                 AND SCL1.BOOK_START_TIME < params.CutDateAsLong + (1000*60*60*24) + 2000
                 AND SCL1.ENTRY_START_TIME < params.CutDateAsLong + (1000*60*60*33) )
             AND (
                 SCL1.ENTRY_END_TIME IS NULL
                 OR SCL1.ENTRY_END_TIME > params.CutDateAsLong + (1000*60*60*33) )
         INNER JOIN
             PRODUCTS PR
         ON
             (
                 ST.CENTER = PR.CENTER
                 AND ST.ID = PR.ID )
         LEFT JOIN
             PRODUCT_GROUP pg
         ON
             pg.ID = PR.PRIMARY_PRODUCT_GROUP_ID
             AND pg.NAME LIKE 'Mem Cat%'
         LEFT JOIN
             PERSON_EXT_ATTRS perCreation
         ON
             perCreation.PERSONCENTER = SU.OWNER_CENTER
             AND perCreation.PERSONID = SU.OWNER_ID
             AND perCreation.NAME = 'CREATION_DATE'
         LEFT JOIN
             PERSON_EXT_ATTRS oldSystemId
         ON
             oldSystemId.PERSONCENTER = SU.OWNER_CENTER
             AND oldSystemId.PERSONID = SU.OWNER_ID
             AND oldSystemId.NAME = '_eClub_OldSystemPersonId'
         LEFT JOIN
             (
                 SELECT
                     cc.PERSONCENTER,
                     cc.PERSONID
                 FROM
                     CASHCOLLECTIONCASES cc
                 CROSS JOIN
                     params
                 WHERE
                     cc.MISSINGPAYMENT = 0
                     AND cc.STARTDATE < params.CutDateAsDate + interval '1 day'
                     AND (
                         cc.CLOSED = 0
                         OR (
                             cc.CLOSED = 1
                             AND cc.CLOSED_DATETIME > params.CutDateAsLong + (1000*60*60*24)))) memberAgreementCase
         ON
             memberAgreementCase.PERSONCENTER = SU.OWNER_CENTER
             AND memberAgreementCase.PERSONID = SU.OWNER_ID
         LEFT JOIN
             (
                 SELECT
                     op_rel.RELATIVECENTER,
                     op_rel.RELATIVEID,
                     op_rel.CENTER payerCenter,
                     op_rel.ID payerId
                 FROM
                     CASHCOLLECTIONCASES cc
                 CROSS JOIN
                     params
                 JOIN
                     RELATIVES op_rel
                 ON
                     op_rel.CENTER = CC.PERSONCENTER
                     AND op_rel.ID = CC.PERSONID
                     AND op_rel.RTYPE = 12
                     --AND op_rel.STATUS < 3
                 JOIN
                     STATE_CHANGE_LOG scl
                 ON
                     scl.CENTER = op_rel.CENTER
                     AND scl.ID = op_rel.ID
                     AND scl.SUBID = op_rel.SUBID
                     AND scl.ENTRY_TYPE = 4
                     AND scl.STATEID < 3
                     AND scl.ENTRY_START_TIME < params.CutDateAsLong + (1000*60*60*24)
                     AND (
                         scl.ENTRY_END_TIME IS NULL
                         OR scl.ENTRY_END_TIME > params.CutDateAsLong + (1000*60*60*24))
                 WHERE
                     cc.MISSINGPAYMENT = 0
                     AND cc.STARTDATE < params.CutDateAsDate + interval '1 day'
                     AND (
                         cc.CLOSED = 0
                         OR (
                             cc.CLOSED = 1
                             AND cc.CLOSED_DATETIME > params.CutDateAsLong + (1000*60*60*24)))) opAgreementCase
         ON
             opAgreementCase.RELATIVECENTER = SU.OWNER_CENTER
             AND opAgreementCase.RELATIVEID = SU.OWNER_ID
         WHERE
             (
                 SU.CENTER IN ($$Scope$$) ) ) t1
 GROUP BY
     OWNER_CENTER ,
     subscriptionId,
     BLOCKED_ENTRY_TIME,
     personId,
     startdate,
     enddate,
     creation,
     pgName,
     SUB_CENTER,
     SUB_ID
