WITH params AS MATERIALIZED
(
        SELECT
                dateToLongC(getCenterTime(c.id), c.id) AS today,
                TO_CHAR(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 months'),'YYYY-MM-DD') AS cutdate,
                c.id AS center_id
        FROM
                centers c
)
SELECT DISTINCT
        c.center as "companyId/center",
        c.id  AS "companyId/ID",
        c.ssn as "cbrId",
        c.address1 as "address/address1",
        c.zipcode as "address/zip",
        c.city as "address/zipname",
        c.country as "address/country",
        c.fullname as "name",
        createdbyp.external_id as "createdById/externalId",
        createdby.relativecenter as "createdById/center", 
        createdby.relativeid     as "createdById/id",
        contact.external_id as "keayaccountmanagerId/externalId",
        contact.center as "keayaccountmanagerId/center",
        contact.id as "keyaccountmanagerId/id",
        'INVOICE'  as "paymentType",
        'SPECIFIED' as "invoiceType",
        t2.numberofemployees,
        par.cutdate as "nextInvoiceDate",
        contact.fullname as "keyAccountManagerName",
        COMPREL.name as "extendedAttributes/name",
        COMPREL.txtvalue as "extendedAttributes/value",
        CREXPIRY.name as "extendedAttributes/name",
        CREXPIRY.txtvalue as "extendedAttributes/value",
        maildo.name as "extendedAttributes/name",
        maildo.txtvalue as "extendedAttributes/value",
        Typeext.name as "extendedAttributes/name",
        Typeext.txtvalue as "extendedAttributes/value",
        AccountManagerEmail.name as "extendedAttributes/name",
        AccountManagerEmail.txtvalue as "extendedAttributes/value"  
FROM  
        persons c

JOIN
        params par
                ON par.center_id = c.center
LEFT JOIN
        relatives rel
                ON c.center = rel.center
                AND c.id = rel.id
                AND rel.rtype = 10 -- accountmanager
                AND rel.status = 1
LEFT JOIN
        persons contact
                ON contact.center = rel.RELATIVECENTER
                AND contact.id = rel.RELATIVEID
LEFT JOIN
        person_Ext_Attrs Contact_phone
                ON contact.center = contact_phone.personCenter
                AND contact.id = contact_phone.personId
                AND contact_phone.Name = '_eClub_PhoneWork'
LEFT JOIN
        person_Ext_Attrs Contact_email
                ON contact.center = contact_email.personCenter
                AND contact.id = contact_email.personId
                AND contact_email.Name = '_eClub_Email'
LEFT JOIN
        person_Ext_Attrs Comp_comment
                ON c.center = Comp_comment.personCenter
                AND c.id = Comp_comment.personId
                AND Comp_comment.Name = '_eClub_Comment'
LEFT JOIN
        person_Ext_Attrs COMPREL
                ON c.center = COMPREL.personCenter
                AND c.id = COMPREL.personId
                AND COMPREL.Name = 'COMPREL'
LEFT JOIN
        person_Ext_Attrs CREXPIRY
                ON c.center = CREXPIRY.personCenter
                AND c.id = CREXPIRY.personId
                AND CREXPIRY.Name = 'CREXPIRY'    
LEFT JOIN
        person_Ext_Attrs Typeext
                ON c.center = Typeext.personCenter
                AND c.id = Typeext.personId
                AND typeext.Name = 'Type'
LEFT JOIN
        person_Ext_Attrs maildo
                ON c.center = maildo.personCenter
                AND c.id = maildo.personId
                AND maildo.Name = 'EmailDomain' 
LEFT JOIN
        person_Ext_Attrs AccountManagerEmail
                ON c.center = AccountManagerEmail.personCenter
                AND c.id = AccountManagerEmail.personId
                AND AccountManagerEmail.Name = 'AccountManagerEmail'                        
LEFT JOIN
        relatives createdby
                ON c.center = createdby.center
                AND c.id = createdby.id
                AND createdby.rtype = 8-- createdby
                AND createdby.status = 1   
LEFT JOIN
        persons createdbyp
                ON createdby.relativecenter = createdbyp.center                       
                AND createdby.relativeid =  createdbyp.id             
left JOIN
        account_receivables ar
                ON ar.customercenter = c.center
                AND ar.customerid = c.id
left JOIN
        payment_accounts pa
                ON pa.center = ar.center
                AND pa.id = ar.id
left JOIN
        payment_agreements pag
                ON pag.center = pa.active_agr_center
                AND pag.id = pa.active_agr_id
left JOIN
        PAYMENT_CYCLE_CONFIG conf
                ON pag.PAYMENT_CYCLE_CONFIG_ID = conf.ID        
LEFT JOIN
        clearinghouses cl
                ON cl.id = pag.clearinghouse  
                AND cl.state = 'ACTIVE'   
LEFT JOIN
        (
        SELECT
                t1.company,
                t1.center,
                t1.id,
                count(t1.employee) as numberofemployees
        FROM
                (
                SELECT
                        p.center,
                        p.id,
                        p.center ||'p'|| p.id as company,
                        comrel.relativecenter ||'p'|| comrel.relativeid as employee
                FROM 
                        persons p 
                LEFT JOIN
                        relatives comrel
                                ON p.center = comrel.center
                                AND p.id = comrel.id
                                AND comrel.rtype = 2 -- company
                                AND comrel.status != 3
                WHERE
                        p.sex = 'C'
        
                ) t1
        GROUP BY
                t1.company,
                t1.center,
                t1.id 
        )t2
                ON t2.center = c.center
                AND t2.id = c.id 
WHERE
        c.sex = 'C'
        AND
        c.country in (:country)    