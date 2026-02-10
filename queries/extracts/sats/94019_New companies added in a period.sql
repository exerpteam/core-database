-- The extract is extracted from Exerp on 2026-02-08
--  

         SELECT
             comp.FULLNAME                                          AS CompanyName,
             longtodate(je.creation_time) as company_creation_time,
             p.CENTER || 'p' || p.ID                                AS MemberId,
            -- cag.CENTER || 'p' || cag.ID                            AS CompanyId,                   
            -- cag.CENTER || 'p' || cag.ID || 'rpt' || cag.SUBID      AS CompanyAgreementId,
           --x    CASE cag.STATE  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'STOP_NEW'  ELSE 'UNKNOWN' END AS AgreementStatus,
             prod.name as subscriptionname,
             s.center ||'ss'|| s.id as subscriptionid,
CASE s.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUBSCRIPTION_SUB_STATE,
             s.start_date,
             cag.NAME                                               AS CompanyAgreementName,
manager.fullname as "Key account manager"

         /*    ps.NAME                                                AS PrivilegeName,
             pg.SPONSORSHIP_NAME                                    AS SponsorshipType,
             pg.SPONSORSHIP_AMOUNT                                  AS SponsorshipAmount*/
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
        left join journalentries je
        on je.person_center = comp.center
        and je.person_id = comp.id
        and je.name = 'Company created'
        left join subscriptions s
        on
        p.center = s.owner_center
        and
        p.id = s.owner_id
        JOIN subscriptiontypes st
        ON s.subscriptiontype_center=st.center
        AND s.subscriptiontype_id=st.id
       JOIN products prod
        ON st.center=prod.center
        AND st.id=prod.id
      left join relatives rel2
     on comp.center = rel2.center
        and comp.id = rel2.id
        and rel2.rtype = 10 -- manager
        and rel2.status <> 3
 left join persons manager
     on manager.center = rel2.RELATIVECENTER
        and manager.id = rel2.RELATIVEID
                            
         WHERE
            comp.center IN ($$Scope$$)
             AND p.PERSONTYPE = 4
             AND p.STATUS IN (1,3)
             and s.state in (2,4,8)
             -- and je.creation_time > ($$companycreationafter$$)
             --and longtodate(je.creation_time) > ($$fromdate$$)
            -- and longtodate(je.creation_time) < ($$todate$$)
            -- AND cag.STATE IN (1,2)
            and  s.start_date >= ($$fromdate$$)
            and  s.start_date <= ($$todate$$)
            and je.creation_time is not null
 