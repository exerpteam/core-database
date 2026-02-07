  WITH
     v_main AS
     (
         SELECT
             p.CENTER || 'p' || p.ID                                AS PersonId,
             cag.CENTER || 'p' || cag.ID                            AS CompanyId,
             comp.FULLNAME                                          AS CompanyName,
             cag.NAME                                               AS CompanyAgreementName,
             cag.CENTER || 'p' || cag.ID || 'rpt' || cag.SUBID      AS CompanyAgreementId,
             CASE cag.STATE  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'STOP_NEW'  ELSE 'UNKNOWN' END AS AgreementStatus,
             ps.NAME                                                AS PrivilegeName,
             pg.SPONSORSHIP_NAME                                    AS SponsorshipType,
             pg.SPONSORSHIP_AMOUNT                                  AS SponsorshipAmount
         FROM
             PERSONS p
         JOIN
             RELATIVES r
         ON
             p.CENTER = r.CENTER
             AND p.ID = r.ID
             AND r.RTYPE = 3
             AND r.STATUS < 2
         JOIN
             COMPANYAGREEMENTS cag
         ON
             cag.CENTER = r.RELATIVECENTER
             AND cag.ID = r.RELATIVEID
             AND cag.SUBID = r.RELATIVESUBID
         JOIN
             PERSONS comp
         ON
             comp.CENTER = cag.CENTER
             AND comp.ID = cag.ID
         LEFT JOIN
             PRIVILEGE_GRANTS pg
         ON
             pg.GRANTER_CENTER = cag.CENTER
             AND pg.GRANTER_ID = cag.ID
             AND pg.GRANTER_SUBID = cag.SUBID
             AND pg.GRANTER_SERVICE = 'CompanyAgreement'
         LEFT JOIN
             PRIVILEGE_SETS ps
         ON
             pg.PRIVILEGE_SET = ps.ID
         WHERE
             p.center IN ($$Scope$$)
             AND p.PERSONTYPE = 4
             AND p.STATUS IN (1,3)
             AND cag.STATE IN (1,2)
             AND (
                 pg.ID IS NULL
                 OR (
                     pg.VALID_FROM < dateToLong(TO_CHAR(Current_timestamp+1, 'YYYY-MM-dd HH24:MI'))
                     AND (
                         pg.VALID_TO >=dateToLong(TO_CHAR(Current_timestamp+1, 'YYYY-MM-dd HH24:MI'))
                         OR pg.VALID_TO IS NULL ) ) )
     )
     ,
     v_pivot AS
     (
         SELECT
             v_main.*,
             LEAD(PrivilegeName,1) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeName2,
             LEAD(SponsorshipType,1) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType2 ,
             LEAD(SponsorshipAmount,1) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount2,
             LEAD(PrivilegeName,2) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeName3,
             LEAD(SponsorshipType,2) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType3 ,
             LEAD(SponsorshipAmount,2) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount3,
             LEAD(PrivilegeName,3) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeName4,
             LEAD(SponsorshipType,3) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType4 ,
             LEAD(SponsorshipAmount,3) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount4,
             LEAD(PrivilegeName,4) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeName5,
             LEAD(SponsorshipType,4) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType5,
             LEAD(SponsorshipAmount,4) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount5,
             LEAD(PrivilegeName,5) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeName6,
             LEAD(SponsorshipType,5) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType6,
             LEAD(SponsorshipAmount,5) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount6,
             LEAD(PrivilegeName,6) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeName7,
             LEAD(SponsorshipType,6) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType7,
             LEAD(SponsorshipAmount,6) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount7,
             LEAD(PrivilegeName,7) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeName8,
             LEAD(SponsorshipType,7) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType8,
             LEAD(SponsorshipAmount,7) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount8,
             LEAD(PrivilegeName,8) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeName9,
             LEAD(SponsorshipType,8) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType9,
             LEAD(SponsorshipAmount,8) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount9,
             LEAD(PrivilegeName,9) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeName10,
             LEAD(SponsorshipType,9) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType10,
             LEAD(SponsorshipAmount,9) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount10,
             LEAD(PrivilegeName,10) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)     AS Privilege11,
             LEAD(SponsorshipType,10) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)   AS SponsorshipType11,
             LEAD(SponsorshipAmount,10) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId) AS SponsorshipAmount11,
             LEAD(PrivilegeName,11) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)     AS Privilege12,
             LEAD(SponsorshipType,11) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)   AS SponsorshipType12,
             LEAD(SponsorshipAmount,11) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId) AS SponsorshipAmount12,
             LEAD(PrivilegeName,12) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)     AS Privilege13,
             LEAD(SponsorshipType,12) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)   AS SponsorshipType13,
             LEAD(SponsorshipAmount,12) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId) AS SponsorshipAmount13,
             LEAD(PrivilegeName,13) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)     AS Privilege14,
             LEAD(SponsorshipType,13) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)   AS SponsorshipType14,
             LEAD(SponsorshipAmount,13) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId) AS SponsorshipAmount14,
             LEAD(PrivilegeName,14) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)     AS Privilege15,
             LEAD(SponsorshipType,14) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)   AS SponsorshipType15,
             LEAD(SponsorshipAmount,14) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId) AS SponsorshipAmount15,
             LEAD(PrivilegeName,15) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)     AS Privilege16,
             LEAD(SponsorshipType,15) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)   AS SponsorshipType16,
             LEAD(SponsorshipAmount,15) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId) AS SponsorshipAmount16,
             LEAD(PrivilegeName,16) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)     AS Privilege17,
             LEAD(SponsorshipType,16) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)   AS SponsorshipType17,
             LEAD(SponsorshipAmount,16) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId) AS SponsorshipAmount17,
             ROW_NUMBER() OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)               AS ADDONSEQ
         FROM
             v_main
     )
 SELECT
     v_pivot.PersonId             AS "PersonId",
     v_pivot.CompanyId            AS "CompanyId",
     v_pivot.CompanyName          AS "CompanyName",
     v_pivot.CompanyAgreementName AS "CompanyAgreementName",
     v_pivot.CompanyAgreementId   AS "CompanyAgreementId",
     v_pivot.AgreementStatus      AS "AgreementStatus",
     v_pivot.PrivilegeName        AS "Privilege1",
     v_pivot.SponsorshipType      AS "SponsorshipType1",
     v_pivot.SponsorshipAmount    AS "SponsorshipAmount1",
     v_pivot.PrivilegeName2       AS "Privilege2",
     v_pivot.SponsorshipType2     AS "SponsorshipType2",
     v_pivot.SponsorshipAmount2   AS "SponsorshipAmount2",
     v_pivot.PrivilegeName3       AS "Privilege3",
     v_pivot.SponsorshipType3     AS "SponsorshipType3",
     v_pivot.SponsorshipAmount3   AS "SponsorshipAmount3",
     v_pivot.PrivilegeName4       AS "Privilege4",
     v_pivot.SponsorshipType4     AS "SponsorshipType4",
     v_pivot.SponsorshipAmount4   AS "SponsorshipAmount4",
     v_pivot.PrivilegeName5       AS "Privilege5",
     v_pivot.SponsorshipType5     AS "SponsorshipType5",
     v_pivot.SponsorshipAmount5   AS "SponsorshipAmount5",
     v_pivot.PrivilegeName6       AS "Privilege6",
     v_pivot.SponsorshipType6     AS "SponsorshipType6",
     v_pivot.SponsorshipAmount6   AS "SponsorshipAmount6",
     v_pivot.PrivilegeName7       AS "Privilege7",
     v_pivot.SponsorshipType7     AS "SponsorshipType7",
     v_pivot.SponsorshipAmount7   AS "SponsorshipAmount7",
     v_pivot.PrivilegeName8       AS "Privilege8",
     v_pivot.SponsorshipType8     AS "SponsorshipType8",
     v_pivot.SponsorshipAmount8   AS "SponsorshipAmount8",
     v_pivot.PrivilegeName9       AS "Privilege9",
     v_pivot.SponsorshipType9     AS "SponsorshipType9",
     v_pivot.SponsorshipAmount9   AS "SponsorshipAmount9",
     v_pivot.PrivilegeName10      AS "Privilege10",
     v_pivot.SponsorshipType10    AS "SponsorshipType10",
     v_pivot.SponsorshipAmount10  AS "SponsorshipAmount10"
 FROM
     v_pivot
 WHERE
     ADDONSEQ=1
