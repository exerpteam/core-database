WITH
    v_main AS
    (
        SELECT
                inSQL.PersonId,
                inSQL.CompanyId,
                inSQL.CompanyName,
                inSQL.CompanyAgreementName,
                inSQL.CompanyAgreementId,
                inSQL.AgreementStatus,
                inSQL.PrivilegeSetName,
                inSQL.SponsorshipType,
                inSQL.SponsorshipAmount,
                STRING_AGG('[' || inSQL.PRICE_MODIFICATION_NAME || ',' || inSQL.PRICE_MODIFICATION_AMOUNT || ',' || inSQL.REF_TYPE || ':' || inSQL.PNAME || ']', ' , ' ORDER BY inSQL.PrivilegeSetName) AS ListPrivilege
                --STRING_AGG('[' || inSQL.PRICE_MODIFICATION_NAME || ',' || inSQL.PRICE_MODIFICATION_AMOUNT || ',' || inSQL.REF_TYPE || ':' || inSQL.PNAME || ']', ' , ') WITHIN GROUP (ORDER BY inSQL.PrivilegeSetName) AS ListPrivilege
        FROM
        (
                SELECT
                    p.CENTER || 'p' || p.ID                                AS PersonId,
                    cag.CENTER || 'p' || cag.ID                            AS CompanyId,
                    comp.FULLNAME                                          AS CompanyName,
                    cag.NAME                                               AS CompanyAgreementName,
                    cag.CENTER || 'p' || cag.ID || 'rpt' || cag.SUBID      AS CompanyAgreementId,
                    --DECODE(cag.STATE, 1,'ACTIVE', 2,'STOP_NEW', 'UNKNOWN') AS AgreementStatus,
                    (CASE cag.STATE   
                                WHEN 1 THEN 'ACTIVE'
                                WHEN 2 THEN 'STOP NEW'
                                ELSE 'UNKNOWN'
                    END) AS AgreementStatus,
                    ps.NAME                                                AS PrivilegeSetName,
                    pg.SPONSORSHIP_NAME                                    AS SponsorshipType,
                    pg.SPONSORSHIP_AMOUNT                                  AS SponsorshipAmount,
                    pp.PRICE_MODIFICATION_NAME,
                    pp.PRICE_MODIFICATION_AMOUNT,
                    pp.REF_TYPE,
                    (CASE WHEN pp.REF_TYPE = 'PRODUCT_GROUP' THEN pgr.NAME ELSE pp.REF_GLOBALID END) AS PNAME
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
                LEFT JOIN
                    PRODUCT_PRIVILEGES pp ON pp.PRIVILEGE_SET = ps.ID
                LEFT JOIN
                    PRODUCT_GROUP pgr ON pp.REF_TYPE = 'PRODUCT_GROUP' AND pp.REF_ID = pgr.ID
                WHERE
                    comp.center IN (:Scope)
                    AND p.PERSONTYPE = 4
                    AND p.STATUS IN (1,3)
                    AND cag.STATE IN (1,2)
                    AND (
                        pg.ID IS NULL
                        OR (
                            pg.VALID_FROM < dateToLong(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-dd HH24:MI'))
                            AND (
                                pg.VALID_TO >=dateToLong(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-dd HH24:MI'))
                                OR pg.VALID_TO IS NULL ) ) )
        ) inSQL
        GROUP BY
                inSQL.PersonId,
                inSQL.CompanyId,
                inSQL.CompanyName,
                inSQL.CompanyAgreementName,
                inSQL.CompanyAgreementId,
                inSQL.AgreementStatus,
                inSQL.PrivilegeSetName,
                inSQL.SponsorshipType,
                inSQL.SponsorshipAmount
    )
    ,
    v_pivot AS
    (
        SELECT
            v_main.*,
            LEAD(PrivilegeSetName,1) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeSetName2,
            LEAD(SponsorshipType,1) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType2 ,
            LEAD(SponsorshipAmount,1) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount2,
            LEAD(ListPrivilege,1) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS ListPrivilege2, 
            LEAD(PrivilegeSetName,2) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeSetName3,
            LEAD(SponsorshipType,2) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType3 ,
            LEAD(SponsorshipAmount,2) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount3,
            LEAD(ListPrivilege,2) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS ListPrivilege3,  
            LEAD(PrivilegeSetName,3) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)      AS PrivilegeSetName4,
            LEAD(SponsorshipType,3) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)    AS SponsorshipType4 ,
            LEAD(SponsorshipAmount,3) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS SponsorshipAmount4,
            LEAD(ListPrivilege,3) OVER (PARTITION BY PersonId, CompanyId, CompanyName, CompanyAgreementName, CompanyAgreementId, AgreementStatus ORDER BY PersonId)  AS ListPrivilege4,     
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
    v_pivot.PrivilegeSetName     AS "PrivilegeSetName1",
    v_pivot.SponsorshipType      AS "SponsorshipType1",
    v_pivot.SponsorshipAmount    AS "SponsorshipAmount1",
    v_pivot.ListPrivilege       AS "ListPrivilege1",
    v_pivot.PrivilegeSetName2       AS "PrivilegeSetName2",
    v_pivot.SponsorshipType2     AS "SponsorshipType2",
    v_pivot.SponsorshipAmount2   AS "SponsorshipAmount2",
    v_pivot.ListPrivilege2       AS "ListPrivilege2",
    v_pivot.PrivilegeSetName3       AS "PrivilegeSetName3",
    v_pivot.SponsorshipType3     AS "SponsorshipType3",
    v_pivot.SponsorshipAmount3   AS "SponsorshipAmount3",
    v_pivot.ListPrivilege3       AS "ListPrivilege3",
    v_pivot.PrivilegeSetName4       AS "PrivilegeSetName4",
    v_pivot.SponsorshipType4     AS "SponsorshipType4",
    v_pivot.SponsorshipAmount4   AS "SponsorshipAmount4",
    v_pivot.ListPrivilege4       AS "ListPrivilege4"
FROM
    v_pivot
WHERE
    ADDONSEQ=1