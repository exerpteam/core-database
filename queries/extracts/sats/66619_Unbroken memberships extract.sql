 WITH
         params AS
         (
                 SELECT
                     /*+ materialize */
                     TO_CHAR(TO_DATE(getCenterTime(c.ID), 'YYYY-MM-DD HH24:MI'),'YYYY-MM-DD') AS executionDate,
                     TRUNC(TO_DATE(getCenterTime(c.ID), 'YYYY-MM-DD HH24:MI')) AS startDay,
                     c.ID AS CENTER
                 FROM
                      CENTERS c
         )
 SELECT
         p.CENTER || 'p' || p.ID AS "MemberID",
         (CASE
                 WHEN p.LAST_ACTIVE_END_DATE IS NULL
                         THEN TRUNC(params.startDay - P.LAST_ACTIVE_START_DATE) + 1
                 WHEN p.LAST_ACTIVE_START_DATE IS NULL
                         THEN 0 ELSE p.MEMBERDAYS
         END) AS "Unbroken Membership Days",
         params.executionDate AS "Extract execution date"
 FROM
         PERSONS p
 JOIN params ON params.CENTER = p.CENTER
 WHERE
         p.CENTER IN (:Scope)
         AND p.STATUS = 1
