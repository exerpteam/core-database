-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT distinct
     per.center||'p'||per.id            AS customer,
         s.owner_center as owner_center,
         sa.center_id                                                              as add_on_scope,
     prod.name                                    AS add_on_name,
     s.CENTER ||'ss'|| s.id as main_subscription,
     sa.id,
     sa.ADDON_PRODUCT_ID,
     sa.START_DATE,
     sa.END_DATE,
     sa.INDIVIDUAL_PRICE_PER_UNIT,
     per.firstname,
     per.lastname,
     per.Address1|| ' ' ||per.Address2 AS adress,
     per.zipcode,
     per.city,
     Emails.TxtValue AS Email
 FROM
 persons per
 JOIN subscriptions s
 ON
     per.CENTER = s.center
 AND per.id = s.id
 join SUBSCRIPTION_ADDON sa
 ON
     sa.SUBSCRIPTION_CENTER = s.center
 AND sa.SUBSCRIPTION_id = s.id
 JOIN masterproductregister m
 ON
     sa.addon_product_id = m.id
 JOIN products prod
 ON
     m.globalid = prod.globalid
 LEFT JOIN Person_Ext_Attrs Emails
 ON
     per.center = Emails.PersonCenter
 AND per.id = Emails.PersonId
 AND Emails.Name = '_eClub_Email'
 WHERE
     sa.SUBSCRIPTION_CENTER  in (:scope)
 and sa.cancelled = 0
 AND sa.INDIVIDUAL_PRICE_PER_UNIT > 0
 and (sa.end_date > current_timestamp or sa.end_date is null)
