 SELECT DISTINCT
     OWNER_CENTER AS "CENTER",
     pgName AS "PGNAME",
     SUM(ACTIVE_CLOSING) AS "ACTIVE_CLOSING",
     SUM(BLOCKED) AS "BLOCKED",
     SUM(FROZEN) AS "FROZEN",
     SUM(MISSING_DDI) AS "MISSING_DDI",
     SUM(WINDOW2) "WINDOW",
     SUM(DEFERRED_ONE_MONTH) AS "DEFERRED_ONE_MONTH",
     SUM(DEFERRED_TWO_MONTHS) AS "DEFERRED_TWO_MONTHS",
     SUM(DEFERRED_LATER) AS "DEFERRED_LATER",
     SUM(ACTIVE_CLOSING) + SUM(BLOCKED) + SUM(MISSING_DDI) + SUM(FROZEN) + SUM(DEFERRED_TWO_MONTHS) + SUM
     (DEFERRED_LATER) + SUM(WINDOW2) AS "LIVE_CLOSING"
 FROM
     (
         SELECT DISTINCT
             personid || ', ' || subscriptionId id,
             OWNER_CENTER,
             personId,
             startdate,
             enddate,
             creation,
             pgName,
             SUM(ACTIVE_CLOSING) ACTIVE_CLOSING,
             SUM(BLOCKED) BLOCKED,
             SUM(FROZEN) FROZEN,
             SUM(MISSING_AGREEMENT) MISSING_DDI,
             SUM(WINDOW2) WINDOW2,
             SUM(DEFERRED_ONE_MONTH) DEFERRED_ONE_MONTH,
             SUM(DEFERRED_TWO_MONTHS) DEFERRED_TWO_MONTHS,
             SUM(DEFERRED_LATER) DEFERRED_LATER,
             SUM(ACTIVE_CLOSING) + SUM(BLOCKED) + SUM(MISSING_AGREEMENT) + SUM(FROZEN) + SUM(DEFERRED_TWO_MONTHS) + SUM
             (DEFERRED_LATER) + SUM(WINDOW2) LIVE_CLOSING
         FROM
             (
                 SELECT
                     SU.OWNER_CENTER,
                     SU.OWNER_ID,
                     SU.OWNER_CENTER || 'p' || SU.OWNER_ID personId,
                     SU.CENTER || 'ss' || SU.ID subscriptionId,
                     PG.NAME pgName,
                     TO_CHAR(SU.START_DATE, 'YYYY-MM-DD') STARTDATE,
                     TO_CHAR(SU.END_DATE, 'YYYY-MM-DD') ENDDATE,
                     TO_CHAR(longtodateTZ(SU.CREATION_TIME, 'Europe/London'), 'YYYY-MM-DD') CREATION,
                     TO_CHAR(longtodateTZ(SCL1.ENTRY_START_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI')
                     ENTRY_START,
                     TO_CHAR(longtodateTZ(SCL1.ENTRY_END_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI') ENTRY_END
                     ,
                     CASE
                         WHEN SCL1.STATEID IN (2,4,8)
                         THEN 1
                         ELSE 0
                     END ACTIVE_CLOSING,
                     CASE
                         WHEN SCL1.STATEID IN (9)
                             OR SU.SUB_STATE IN (9)
                         THEN -1
                         ELSE 0
                     END BLOCKED,
                     CASE
                         WHEN SCL1.STATEID IN (4)
                             AND SU.SUB_STATE NOT IN (9)
                             AND SCL1.STATEID NOT IN (9)
                         THEN -1
                         ELSE 0
                     END FROZEN,
                     CASE
                         WHEN SCL1.STATEID IN (2,4,8)
                             AND (memberAgreementCase.PERSONCENTER IS NOT NULL
                                 OR opAgreementCase.RELATIVECENTER IS NOT NULL)
                             AND SCL1.STATEID NOT IN (4)
                             AND SU.SUB_STATE NOT IN (9)
                             AND SCL1.STATEID NOT IN (9)
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
                             AND SU.SUB_STATE NOT IN (9)
                             AND SCL1.STATEID NOT IN (9)
                             AND memberAgreementCase.PERSONCENTER IS NULL
                             AND opAgreementCase.RELATIVECENTER IS NULL
                         THEN 1
                         ELSE 0
                     END WINDOW2,
                     CASE
                         WHEN SCL1.STATEID IN (8)
                             AND SU.SUB_STATE NOT IN (9)
                             AND SCL1.STATEID NOT IN (9)
                             AND memberAgreementCase.PERSONCENTER IS NULL
                             AND opAgreementCase.RELATIVECENTER IS NULL
                             AND SU.START_DATE <= add_months(longtodate($$CutDate$$),1)
                         THEN -1
                         ELSE 0
                     END DEFERRED_ONE_MONTH,
                     CASE
                         WHEN SCL1.STATEID IN (8)
                             AND SU.SUB_STATE NOT IN (9)
                             AND SCL1.STATEID NOT IN (9)
                             AND memberAgreementCase.PERSONCENTER IS NULL
                             AND opAgreementCase.RELATIVECENTER IS NULL
                             AND SU.START_DATE > add_months(longtodate($$CutDate$$),1)
                             AND SU.START_DATE <= add_months(longtodate($$CutDate$$),2)
                         THEN -1
                         ELSE 0
                     END DEFERRED_TWO_MONTHS,
                     CASE
                         WHEN SCL1.STATEID IN (8)
                             AND SU.SUB_STATE NOT IN (9)
                             AND SCL1.STATEID NOT IN (9)
                             AND memberAgreementCase.PERSONCENTER IS NULL
                             AND opAgreementCase.RELATIVECENTER IS NULL
                             AND SU.START_DATE > add_months(longtodate($$CutDate$$),2)
                         THEN -1
                         ELSE 0
                     END DEFERRED_LATER,
                     perCreation.txtvalue "Original joined date",
                     oldSystemId.txtvalue "Old System Id"
                 FROM
                     SUBSCRIPTIONS SU
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
                         AND SCL1.BOOK_START_TIME < $$CutDate$$ + (1000*60*60*24) + 2000
                         AND SCL1.ENTRY_START_TIME < $$CutDate$$ + (1000*60*60*30) )
                     AND (
                         SCL1.ENTRY_END_TIME IS NULL
                         OR SCL1.ENTRY_END_TIME > $$CutDate$$ + (1000*60*60*30) )
                 INNER JOIN
                     PRODUCTS PR
                 ON
                     (
                         ST.CENTER = PR.CENTER
                         AND ST.ID = PR.ID )
                 JOIN
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
                         JOIN
                             ACCOUNT_RECEIVABLES ar
                         ON
                             ar.CUSTOMERCENTER = cc.PERSONCENTER
                             AND ar.CUSTOMERID = cc.PERSONID
                             AND ar.AR_TYPE = 4
                             AND ar.BALANCE < 0
                         WHERE
                             cc.MISSINGPAYMENT = 0
                             AND cc.STARTDATE < longtodateTZ($$CutDate$$, 'Europe/London') + 1
                             AND cc.CLOSED = 0 ) memberAgreementCase
                 ON
                     memberAgreementCase.PERSONCENTER = SU.OWNER_CENTER
                     AND memberAgreementCase.PERSONID = Su.OWNER_ID
                 LEFT JOIN
                     (
                         SELECT
                             op_rel.RELATIVECENTER,
                             op_rel.RELATIVEID
                         FROM
                             CASHCOLLECTIONCASES cc
                         JOIN
                             ACCOUNT_RECEIVABLES ar
                         ON
                             ar.CUSTOMERCENTER = cc.PERSONCENTER
                             AND ar.CUSTOMERID = cc.PERSONID
                             AND ar.AR_TYPE = 4
                             AND ar.BALANCE < 0
                         JOIN
                             RELATIVES op_rel
                         ON
                             op_rel.CENTER = CC.PERSONCENTER
                             AND op_rel.ID = CC.PERSONID
                             AND op_rel.RTYPE = 12
                             AND op_rel.STATUS < 3
                         WHERE
                             cc.MISSINGPAYMENT = 0
                             AND cc.STARTDATE < longtodateTZ($$CutDate$$, 'Europe/London') + 1
                             AND cc.CLOSED = 0 ) opAgreementCase
                 ON
                     opAgreementCase.RELATIVECENTER = SU.OWNER_CENTER
                     AND opAgreementCase.RELATIVEID = SU.OWNER_ID
                 WHERE
                     (
                         SU.CENTER IN ($$Scope$$) ) ) t1
         GROUP BY
             OWNER_CENTER ,
             subscriptionId,
             personId,
             startdate,
             enddate,
             creation,
             pgName ) t2
 GROUP BY
     OWNER_CENTER,
     pgName
