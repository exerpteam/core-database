-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            CAST(COALESCE(from_Date,dateToLong(TO_CHAR(TRUNC(CURRENT_TIMESTAMP-2),
            'YYYY-MM-dd HH24:MI') )) AS bigint) AS from_Date,
            CAST(dateToLong(TO_CHAR(TRUNC(CURRENT_TIMESTAMP), 'YYYY-MM-dd HH24:MI')) -1 AS bigint)
            AS to_Date
        FROM
            (
                SELECT
                    MAX(efop.START_TIME) from_Date
                FROM
                    EXCHANGED_FILE ef
                JOIN
                    EXCHANGED_FILE_OP efop
                ON
                    efop.EXCHANGED_FILE_ID = ef.ID
                AND efop.OPERATION_ID = 'GENERATE'
                WHERE
                    /* Needs to be set to the right agency */
                    ef.AGENCY = 8802
                AND ef.EXPORTED = 1 ) t
    )
    ,
    person AS
    (
        -- Get list of active corporate vitality members
        SELECT
            p.CENTER,
            p.ID,
            p.External_ID           ExternalId,
            LookupEntityId.TXTVALUE VitalityEntityNo
        FROM
            persons p
        JOIN
            CENTERS c
        ON
            c.ID = p.CENTER
        AND c.country = 'GB'
        JOIN
            RELATIVES comp_rel
        ON
            comp_rel.center = p.center
        AND comp_rel.id = p.id
        AND comp_rel.RTYPE = 3
        AND comp_rel.STATUS < 3
        JOIN
            COMPANYAGREEMENTS cag
        ON
            cag.center= comp_rel.RELATIVECENTER
        AND cag.id=comp_rel.RELATIVEID
        AND cag.subid = comp_rel.RELATIVESUBID
        JOIN
            persons comp
        ON
            comp.center = cag.center
        AND comp.id=cag.id
        LEFT JOIN
            PERSON_EXT_ATTRS LookupEntityId
        ON
            p.center = LookupEntityId.PERSONCENTER
        AND p.id = LookupEntityId.PERSONID
        AND LookupEntityId.name = '_eClub_PBLookupPartnerPersonId'
        WHERE
            comp.center = 4
        AND comp.ID = 674
        AND p.STATUS IN (1,3)
        AND TRIM(LookupEntityId.TXTVALUE) IS NOT NULL -- Oracle dumbness: it interprets an
        -- empty varchar string as NULL
        UNION
        -- Get list of non-corporate vitality members using extended attribute VITENT
        SELECT
            p.CENTER,
            p.ID,
            p.External_ID           ExternalId,
            LookupEntityId.TXTVALUE VitalityEntityNo
        FROM
            persons p
        JOIN
            PERSON_EXT_ATTRS LookupEntityId
        ON
            p.CENTER = LookupEntityId.PERSONCENTER
        AND p.ID = LookupEntityId.PERSONID
        AND LookupEntityId.NAME = 'VITENT'
        WHERE
            p.STATUS IN (1,3)
        AND LookupEntityId.TXTVALUE IS NOT NULL
        AND TRIM(LookupEntityId.TXTVALUE) IS NOT NULL -- Oracle dumbness: it interprets an
            -- empty varchar string as NULL
    )
SELECT
    CASE OrderBy
            -- This is the record line, consisting of record count and remainder of visit info
        WHEN 3
        THEN '"' || CAST(RecordNo AS VARCHAR) || '",' || FileLine
            -- This is the footer line, consisting of count of visit records and sum of entity
            -- numbers
        WHEN 4
        THEN '"' || CAST(row_number() over() - 3 AS VARCHAR) || '","0"'
        ELSE FileLine
    END AS "FILELINE"
FROM
    (
        SELECT
            -- Header record #1: VA entity number , file number (incremented by day), date / time ,
            -- constants: %%BATCHNUMBER%% is replaced by Go Anywhere
            1 OrderBy,
            '"1067434512","%%BATCHNUMBER%%","' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMddHH24MISS') ||
            '","Point Events Request"' FileLine,
            0                          RecordNo
        UNION ALL
        SELECT
            -- Header record #2: Column Names
            2 OrderBy,
            '"RecordNo","RecordType","PartnerMembershipNo","SiteEntityNo","MemberEntityNo","Date","DetailedCategoryID"'
              FileLine,
            0 RecordNo
        UNION ALL
        SELECT
            3 OrderBy,
            '"Create","' || CAST(person.ExternalId AS VARCHAR) || '","' || sp.TXTVALUE || '","' ||
            person.VitalityEntityNo || '","' || TO_CHAR(longToDateC(cin.CHECKIN_TIME,person.CENTER)
            , 'YYYYMMdd') || '","HPLA"'             FileLine,
            RANK() OVER (ORDER BY cin.CHECKIN_TIME) RecordNo
        FROM
            params,
            person
        JOIN
            CHECKINS cin
        ON
            cin.PERSON_CENTER = person.CENTER
        AND cin.PERSON_ID = person.ID
        LEFT JOIN
            SYSTEMPROPERTIES sp
        ON
            sp.SCOPE_ID = cin.CHECKIN_CENTER
        AND sp.SCOPE_TYPE = 'C'
        AND sp.GLOBALID = 'PruhealthBranchEntityNo'
        WHERE
            cin.CHECKIN_TIME BETWEEN params.from_Date AND params.to_date
        UNION ALL
        -- This is a placeholder for the footer which will contain calculated fields: count of
        -- visit records
        SELECT
            4  OrderBy,
            '' FileLine,
            0 RecordNo ) t1
ORDER BY
    OrderBy,
    RecordNo