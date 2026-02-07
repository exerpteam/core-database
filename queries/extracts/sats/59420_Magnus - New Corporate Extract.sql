 SELECT DISTINCT
     p.CENTER||'p'||p.ID                    AS "COMPANY_ID",
     ca.center||'p'||ca.id||'rpt'||ca.SUBID AS "COMPANY_AGREEMENT_ID",
     ps.ID                                  AS "PRIVILEGE SET ID",
     ps.NAME                                AS "PRIVILEGE SET",
     pg.SPONSORSHIP_NAME                    AS "SPONSORSHIP TYPE",
     pg.SPONSORSHIP_AMOUNT                  AS "SPONSORSHIP AMOUNT",
     account_manager.EXTERNAL_ID            AS "MANAGER_ID",
     pea.TXTVALUE                           AS "EMPLOYEE TARGET",
     mothercompany.EXTERNAL_ID              AS "MOTHER_COMPANY_ID",
     p.EXTERNAL_ID                          AS "EXTERNAL_COMPANY_ID",
     ca.stop_new_date                       AS "STOP_NEW_DATE"
 FROM
     COMPANYAGREEMENTS ca
 JOIN
     PERSONS p
 ON
     p.center = ca.center
 AND p.id = ca.id
 LEFT JOIN
     PRIVILEGE_GRANTS pg
 ON
     pg.GRANTER_SERVICE='CompanyAgreement'
 AND pg.GRANTER_CENTER=ca.center
 AND pg.granter_id=ca.id
 AND pg.GRANTER_SUBID = ca.SUBID
 LEFT JOIN
     RELATIVES rel_acc_man
 ON
     rel_acc_man.CENTER = p.CENTER
 AND rel_acc_man.ID = p.ID
 AND rel_acc_man.RTYPE = 10
 AND rel_acc_man.STATUS = 1
 LEFT JOIN
     PERSONS account_manager
 ON
     rel_acc_man.RELATIVECENTER = account_manager.CENTER
 AND rel_acc_man.RELATIVEID = account_manager.ID
 LEFT JOIN
     PERSON_EXT_ATTRS pea
 ON
     pea.NAME = '_eClub_TargetNumberOfEmployees'
 AND pea.PERSONCENTER = p.CENTER
 AND pea.PERSONID = p.ID
 LEFT JOIN
     RELATIVES rel_mother_comp
 ON
     rel_mother_comp.RELATIVECENTER = p.CENTER
 AND rel_mother_comp.RELATIVEID = p.ID
 AND rel_mother_comp.RTYPE = 6
 AND rel_mother_comp.STATUS = 1
 LEFT JOIN
     PERSONS mothercompany
 ON
     rel_mother_comp.CENTER = mothercompany.CENTER
 AND rel_mother_comp.ID = mothercompany.ID
 left JOIN
     PRIVILEGE_SETS ps
 ON
     ps.ID = pg.PRIVILEGE_SET
