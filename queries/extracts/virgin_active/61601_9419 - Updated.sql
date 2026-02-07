WITH
    params AS
    (
        SELECT
            id,
            TRUNC(CURRENT_TIMESTAMP,'DD') AS today
        FROM
            centers c
        WHERE
            c.country = 'IT'
    )

SELECT
     iq."PERSONID",
     iq."HOMEADDRESSID",
     iq."SITEID",
     iq."CREATEDDATE",
     longToDateC(pcl.ENTRY_TIME,iq.center) "MODIFIEDDATE",
     sal.TXTVALUE "TITLE",
     iq."FORENAME",
     iq."SURNAME",
     iq."DOB",
     CASE iq."GENDER" WHEN 'M' THEN 'MALE' WHEN 'F' THEN 'FEMALE' ELSE iq."GENDER" END AS "GENDER",
     CASE
         WHEN cc.CENTER IS NOT NULL
         THEN 'CASH COLLECTION'
         WHEN EXTRACT(DAY FROM (to_timestamp(getcentertime(iq.CENTER), 'YYYY-MM-DD HH24:MI') - MIN(art.DUE_DATE))) < 30
         THEN 'UNDER'
         ELSE 'OVER 30'
     END              AS "ACCOUNTSTATUS",
     arCash.DEBIT_MAX "CREDITLIMIT",
     CASE
         WHEN arCash.DEBIT_MAX IS NULL
             OR arCash.DEBIT_MAX = 0
         THEN 0
         ELSE 1
     END                              "ACCOUNTENABLED",
     COALESCE(SUM(art.UNSETTLED_AMOUNT),0) AS "DEBTBALANCE",
     pEmp.FULLNAME "CREATEDBY",
     cp.FULLNAME "EDITEDBY",
     iq."COMPANYID",
     iq."REFERREDBYID",
     iq."HEADOFFAMILY",
     CASE  iq."STATUS"  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS "STATUS",
     CASE  iq.persontype  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST'  WHEN 9 THEN  'CHILD'  WHEN 10 THEN  'EXTERNAL_STAFF' ELSE 'UNKNOWN' END AS "PERSONTYPE",
     iq.old_system_id AS "OLD_SYSTEM_ID",
     iq.ExerpPersonID AS "EXERPPERSONID",
     iq.SSN AS "TAX_CODE",
     iq.EXPIRATION_DATE AS "MED_CERT_EXPIRY",
     iq.ROLE_ID AS "ROLE_ID",
     iq.ROLE_NAME AS "ROLE_DESCRIPTION"
 FROM
     (
         SELECT
             (
                 SELECT
                     MAX(pcl2.id)
                 FROM
                     
					 PERSON_CHANGE_LOGS pcl2
					 
					 JOIN params par1
					 on par1.id = pcl2.person_center
                 WHERE
                     pcl2.PERSON_CENTER = pe.CENTER
                     AND pcl2.PERSON_ID = pe.ID
                     AND pcl2.CHANGE_ATTRIBUTE IN ('_eClub_AllowedChannelLetter',
                                                   '_eClub_InvoiceAddress1',
                                                   '_eClub_InvoiceAddress2',
                                                   '_eClub_InvoiceCity',
                                                   '_eClub_InvoiceCoName',
                                                   '_eClub_InvoiceCountry',
                                                   '_eClub_InvoiceEmail',
                                                   '_eClub_InvoiceZipCode',
                                                   '_eClub_Salutation',
                                                   'ACCEPTING_EMAIL_NEWS_LETTERS',
                                                   'ACCEPTING_THIRD_PARTY_OFFERS',
                                                   'ADDRESS_1',
                                                   'ADDRESS_2',
                                                   'ADDRESS_3',
                                                   'ALLOWED_CHANNEL_EMAIL',
                                                   'ALLOWED_CHANNEL_PHONE',
                                                   'ALLOWED_CHANNEL_SMS',
                                                   'BIRTHDATE',
                                                   'CITY',
                                                   'CO_NAME',
                                                   'COUNTRY',
                                                   'E_MAIL',
                                                   'FIRST_NAME',
                                                   'HOME_PHONE',
                                                   'LAST_NAME',
                                                   'MOB_PHONE',
                                                   'SEX',
                                                   'SSN',
                                                   'WORK_PHONE',
                                                   'ZIP_CODE
 ') ) max_change_id,
             pe.CENTER,
             pe.ID,
             pe.EXTERNAL_ID                                             "PERSONID",
             pe.EXTERNAL_ID                                             "HOMEADDRESSID",
             pe.CENTER                                                  "SITEID",
             pe.FIRST_ACTIVE_START_DATE                                   "CREATEDDATE",
             pe.FIRSTNAME                                              "FORENAME",
             pe.LASTNAME                                               "SURNAME",
             pe.BIRTHDATE                                           "DOB",
             pe.SEX                                                  "GENDER",
            -- pv.CREATED_BY_FIRST_NAME || ' ' || pv.CREATED_BY_LAST_NAME "CREATEDBY",
             comp.EXTERNAL_ID                                           "COMPANYID",
             pRef.EXTERNAL_ID                                           "REFERREDBYID",
             CASE WHEN relHOF.CENTER IS NOT NULL THEN 1 ELSE 0 END                                    "HEADOFFAMILY",
             pe.STATUS                                                      "STATUS",
             pe.persontype,
             oldId.TXTVALUE old_system_id ,
             /* should be taken from person extended atts */
             pe.CENTER || 'p' || pe.ID ExerpPersonID,
             pe.SSN,
             r.ID          ROLE_ID,
             r.ROLENAME    ROLE_NAME,
             r.DESCRIPTION ROLE_DESCRIPTION,
             je.EXPIRATION_DATE
         FROM
             PERSONS pe
         LEFT JOIN
             EMPLOYEES empP
         ON
             empP.PERSONCENTER = pe.CENTER
             AND empP.PERSONID = pe.ID
         LEFT JOIN
             EMPLOYEESROLES er
         ON
             er.CENTER = empP.CENTER
             AND er.ID = empP.ID
         LEFT JOIN
             ROLES r
         ON
             r.ID = er.ROLEID
             AND r.BLOCKED = 0
             AND r.IS_ACTION = 0
             /* The old Join for health certificates. We only want the latest
             LEFT JOIN
             JOURNALENTRIES je
             ON
             je.PERSON_CENTER = pv.CENTER
             AND je.PERSON_ID = pv.ID
             AND je.NAME = 'Medical Health Certificate'*/
         LEFT JOIN
             (
                 SELECT
                     je1.PERSON_CENTER,
                     je1.PERSON_ID,
                     je1.PERSON_SUBID,
                     je1.JETYPE,
                     MAX(je1.EXPIRATION_DATE) AS EXPIRATION_DATE
                 FROM
                     JOURNALENTRIES je1
                 WHERE
                     je1.JETYPE = 31
                 GROUP BY
                     je1.PERSON_CENTER,
                     je1.PERSON_ID,
                     je1.PERSON_SUBID,
                     je1.JETYPE) je
         ON
             je.PERSON_CENTER = pe.CENTER
             AND je.PERSON_ID = pe.ID
         LEFT JOIN
             PERSON_EXT_ATTRS oldId
         ON
             oldId.PERSONCENTER = pe.CENTER
             AND oldId.PERSONID = pe.ID
             AND oldId.NAME = '_eClub_OldSystemPersonId'
         LEFT JOIN
             RELATIVES rel
         ON
             rel.CENTER = pe.CENTER
             AND rel.ID = pe.ID
             AND rel.RTYPE = 3
             AND rel.STATUS = 1
         LEFT JOIN
             PERSONS comp
         ON
             comp.CENTER = rel.RELATIVECENTER
             AND comp.ID = rel.RELATIVEID
         LEFT JOIN
             RELATIVES relRef
         ON
             relRef.CENTER = pe.CENTER
             AND relRef.ID = pe.ID
             AND relRef.RTYPE = 13
             AND relRef.STATUS = 1
         LEFT JOIN
             PERSONS pRef
         ON
             pRef.CENTER = relRef.RELATIVECENTER
             AND pRef.ID = relRef.RELATIVEID
         LEFT JOIN
             RELATIVES relHOF
         ON
             relHOF.RELATIVECENTER = pe.CENTER
             AND relHOF.RELATIVEID = pe.ID
             AND relHOF.RTYPE = 4
             AND relHOF.STATUS = 1
   	 ) iq
 LEFT JOIN
     PERSON_CHANGE_LOGS pcl
 ON
     pcl.ID = iq.MAX_CHANGE_ID
 LEFT JOIN
     EMPLOYEES emp
 ON
     emp.CENTER = pcl.EMPLOYEE_CENTER
     AND emp.ID = pcl.EMPLOYEE_ID
 LEFT JOIN
     PERSONS cp
 ON
     cp.CENTER = emp.PERSONCENTER
     AND cp.ID = emp.PERSONID
 LEFT JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = iq.center
     AND ar.CUSTOMERID = iq.id
     AND ar.AR_TYPE = 4
 LEFT JOIN
     ACCOUNT_RECEIVABLES arCash
 ON
     arCash.CUSTOMERCENTER = iq.center
     AND arCash.CUSTOMERID = iq.id
     AND arCash.AR_TYPE = 1
     
           JOIN params par 
on par.id = arCash.CUSTOMERCENTER	
 LEFT JOIN
     AR_TRANS art
 ON
     art.CENTER = ar.CENTER
     AND art.id = ar.id
     AND (
         art.DUE_DATE IS NOT NULL
         AND art.DUE_DATE < par.today)
 LEFT JOIN
     CASHCOLLECTIONCASES cc
 ON
     cc.PERSONCENTER = ar.CUSTOMERCENTER
     AND cc.PERSONID = ar.CUSTOMERID
     AND cc.CLOSED = 0
     AND cc.SUCCESSFULL = 0
     AND cc.MISSINGPAYMENT = 1
 LEFT JOIN
     PERSON_EXT_ATTRS sal
 ON
     sal.personcenter = iq.center
     AND sal.personid = iq.id
     AND sal.name = '_eClub_Salutation'
 LEFT JOIN
     RELATIVES relCreatedBy
 ON
     relCreatedBy.CENTER = iq.CENTER
     AND relCreatedBy.ID = iq.ID
     AND relCreatedBy.RTYPE = 8
     AND relCreatedBy.STATUS = 1
 LEFT JOIN
     EMPLOYEES emp2
 ON
     emp2.CENTER = relCreatedBy.RELATIVECENTER
     AND emp2.ID = relCreatedBy.RELATIVEID
 LEFT JOIN
     PERSONS pEmpOld
 ON
     pEmpOld.CENTER = emp2.PERSONCENTER
     AND pEmpOld.ID = emp2.PERSONID
 LEFT JOIN
     PERSONS pEmp
 ON
     pEmp.CENTER = pEmpOld.CURRENT_PERSON_CENTER
     AND pEmp.ID = pEmpOld.CURRENT_PERSON_ID
 GROUP BY
     iq.old_system_id,
     iq.persontype,
     iq."HOMEADDRESSID",
     iq.ExerpPersonID,
     iq."PERSONID",
     iq."SITEID",
     iq."CREATEDDATE",
     cc.CENTER,
     pcl.ENTRY_TIME,
     iq."FORENAME",
     iq."SURNAME",
     sal.TXTVALUE,
     iq."DOB",
     iq."GENDER",
     pEmp.FULLNAME,
     cp.FULLNAME ,
     iq."COMPANYID",
     iq."REFERREDBYID",
     iq."HEADOFFAMILY",
     iq."STATUS",
     arCash.DEBIT_MAX,
     iq.SSN,
     iq.ROLE_ID ,
     iq.ROLE_NAME ,
     iq.EXPIRATION_DATE,
     iq.center
