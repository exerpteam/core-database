SELECT
    r1.*
FROM
    (
        SELECT
            p.center||'p'||p.id "Member id",
            s.subscription_price "Membership price",
            DECODE(PERSONTYPE,0,'PRIVATE',1,'STUDENT',2,'STAFF',3,'FRIEND',4,'CORPORATE',5,
            'ONEMANCORPORATE',6,'FAMILY',7,'SENIOR',8,'GUEST',9,'CHILD',10,'EXTERNAL_STAFF',
            'Undefined') AS "Person type",
            CASE PERSONTYPE
                WHEN 1
                THEN TO_CHAR(to_date(A.TXTVALUE, 'yyyy-mm-dd'), 'dd-mm-yyyy')
                WHEN 3
                THEN TO_CHAR(R.EXPIREDATE,'DD-MM-YYYY' )
                WHEN 4
                THEN TO_CHAR(R1.EXPIREDATE,'DD-MM-YYYY' )
            END "Documentation expired"
        FROM
            PERSONS P
        JOIN
            subscriptions s
        ON
            p.center= s.owner_center
        AND p.id=s.owner_id
        LEFT JOIN
            RELATIVES R
        ON
            P.CENTER = R.CENTER
        AND P.ID = R.ID
        AND R.RTYPE = 1
            /* RTYPE 1 for Friend */
        AND r.status = 2 -- Inactive (Documentation expired)
        LEFT JOIN
            RELATIVES R1
        ON
            P.CENTER = R1.CENTER
        AND P.ID = R1.ID
        AND R1.RTYPE = 3
            /* RTYPE 3 for Company Agreement */
        AND r1.status = 2 -- Inactive (Documentation expired)
        LEFT JOIN
            PERSON_EXT_ATTRS A
        ON
            P.CENTER = A.PERSONCENTER
        AND P.ID = A.PERSONID
        AND a.name = '_eClub_StudyDocValidUntil'
        AND a.txtvalue < TO_CHAR(SYSDATE,'yyyy-mm-dd')
        WHERE
            P.CENTER IN ($$scope$$)
        AND P.PERSONTYPE IN ($$persontype$$)
            /* Persontype - Student,Friend,Corporate*/
        AND P.STATUS IN (1,3) --Person status: Active, TemporaryInactive
        AND s.state IN (2,4) --Subsription state: Active,Frozen
    )r1
WHERE
    r1."Documentation expired" IS NOT NULL