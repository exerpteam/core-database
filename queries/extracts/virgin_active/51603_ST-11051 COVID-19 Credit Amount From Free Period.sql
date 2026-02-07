 WITH
     PARAMS AS
     (
         SELECT
             /*+ materialize */
             datetolongTZ(TO_CHAR(CURRENT_TIMESTAMP-3, 'YYYY-MM-dd HH24:MI'), 'Europe/London') AS cutdate
         
     )
 SELECT
     p.center || 'p' || p.id AS PersonId,
     SUM(art.amount)         AS CREDITAMOUNT
 FROM
     persons p
 CROSS JOIN
     PARAMS par
 JOIN
     account_receivables ar
 ON
     p.CENTER = ar.customercenter
     AND p.ID = ar.customerid
     AND ar.ar_type = 4
 JOIN
     ar_trans art
 ON
     ar.center = art.center
     AND ar.id = art.id
 WHERE
     art.employeecenter = 100
     AND art.employeeid = 3002
     AND art.entry_time > par.cutdate
     AND art.amount != 0
     AND p.center IN ($$Scope$$)
 GROUP BY
     p.center,
     p.id
