 SELECT
     p.CENTER || 'p' || p.ID   AS "MemberID",
     op.CENTER || 'p' || op.ID AS "Other payer",
     (
         CASE op.SEX
             WHEN 'C'
             THEN 'Company'
             ELSE 'Person'
         END) AS "Payer entity"
 FROM
     PERSONS p
 JOIN
     RELATIVES r
 ON
     p.CENTER = r.RELATIVECENTER
 AND p.ID = r.RELATIVEID
 AND r.RTYPE = 12
 AND r.STATUS < 2
 JOIN
     PERSONS op
 ON
     op.CENTER = r.CENTER
 AND op.ID = r.ID
 WHERE
     p.STATUS IN (1,3)
 AND p.CENTER IN (:Scope)
