 SELECT
     comp.lastname,
     comp.address1,
     comp.address2,
     comp.zipcode,
     comp.city,
     comp.ssn as CVR,
     comp.center || 'p' ||comp.id as CompanyID,
     contact.fullname as contact_name,
 --    contact.CENTER||'p'||contact.id as contactID
     contact_phone.TxtValue AS Contact_Phone,
     manager.fullname as manager_name,
     Manager_phone.Txtvalue as Manager_Phone,
 --    manager.center||'p'||manager.id as managerID,
     comp_pea.TxtValue as company_comment
 FROM
      persons comp
 join person_ext_attrs comp_pea
     on
         comp.center = comp_pea.personCenter
     and comp.id = comp_pea.personId
     and comp_pea.Name = '_eClub_Comment'
 left join  relatives rel
     on comp.center = rel.center
        and comp.id = rel.id
        and rel.rtype = 7  -- contact
        and rel.status <> 3
 left join persons contact
     on contact.center = rel.RELATIVECENTER
        and contact.id = rel.RELATIVEID
 left join relatives rel2
     on comp.center = rel2.center
        and comp.id = rel2.id
        and rel2.rtype = 10 -- manager
        and rel2.status <> 3
 left join persons manager
     on manager.center = rel2.RELATIVECENTER
        and manager.id = rel2.RELATIVEID
 left join person_Ext_Attrs Manager_phone
     on Manager.center = Manager_phone.personCenter
        and Manager.id =  Manager_phone.personId
        and Manager_phone.Name = '_eClub_PhoneWork'
 join  companyagreements ca
     on
        ca.center = comp.center
        and ca.id = comp.id
        and ca.state = 1 -- active
 left join person_Ext_Attrs Contact_phone
     on
            contact.center = contact_phone.personCenter
        and contact.id = contact_phone.personId
        and contact_phone.Name = '_eClub_PhoneWork'
 WHERE
        comp.sex = 'C'
 group by
     comp.lastname,
     comp.address1,
     comp.address2,
     comp.zipcode,
     comp.city,
     comp.ssn,
     comp.center,
     comp.id,
     contact.fullname,
     contact_phone.TxtValue,
     manager.fullname,
     Manager_phone.Txtvalue,
     comp_pea.TxtValue
