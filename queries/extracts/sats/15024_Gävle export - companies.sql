
select
comp.center || 'p' || comp.id as CompanyMemberId,
comp.SSN as Organisationsnummer,
comp.lastname as Företagsnamn,
k.fullname as Kontaktperson,
comp.ADDRESS1 as Adress1,
comp.ADDRESS2 as Adress2,
comp.ZIPCODE as Postnummer,
comp.CITY as Ort,
phone.TxtValue           as Telefon, 
Emails.TxtValue          as "E-post",
p.center || 'p' || p.id as "Kopplade Kunder",
Kommentar.TxtValue as Anteckningar,
case when priv.SPONSORSHIP_NAME = 'FULL' and comp_pa.center is not null and comp_pa.state != 13 then 'Monthly' when priv.SPONSORSHIP_NAME = 'FULL' and comp_pa.center is not null and comp_pa.state = 13 then 'Yearly' else 'Monthly' end as Betalningsintervall,
case when priv.SPONSORSHIP_NAME = 'FULL' and comp_pa.center is not null and comp_pa.state in (1,2,4,14) then comp_pa.BANK_REGNO else null end as Clearingnummer,
case when priv.SPONSORSHIP_NAME = 'FULL' and comp_pa.center is not null and comp_pa.state in (1,2,4,14) then comp_pa.BANK_ACCNO else null end as Bankkontonummer,
'' as Bank,
pg.NAME as "ProductGroup",
priv.SPONSORSHIP_NAME

from ECLUB2.persons p
join ECLUB2.SUBSCRIPTIONS sub on p.center = sub.OWNER_CENTER and p.id = sub.OWNER_ID and sub.STATE in (2,4,8)
join ECLUB2.SUBSCRIPTIONTYPES st on st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER and st.id = sub.SUBSCRIPTIONTYPE_ID
join
    ECLUB2.PRODUCTS pd on st.center=pd.center and st.id=pd.id
join 
    ECLUB2.PRODUCT_GROUP pg on pg.ID = pd.PRIMARY_PRODUCT_GROUP_ID

join
    ECLUB2.RELATIVES comp_rel on comp_rel.center=p.center and comp_rel.id=p.id and comp_rel.RTYPE = 3 and comp_rel.STATUS < 3
join ECLUB2.COMPANYAGREEMENTS cag on cag.center= comp_rel.RELATIVECENTER and cag.id=comp_rel.RELATIVEID and cag.subid = comp_rel.RELATIVESUBID
join eclub2.persons comp on comp.center = cag.center and comp.id=cag.id

LEFT JOIN 
    ECLUB2.RELATIVES cc 
    ON 
    cc.CENTER = comp.CENTER 
    AND cc.ID = comp.ID 
    AND cc.RTYPE      = 7
    and cc.status < 3
    /*contact person for company */ 
LEFT JOIN 
    ECLUB2.PERSONS k 
    ON 
    cc.RELATIVECENTER = k.CENTER 
    AND cc.RELATIVEID = k.ID 
LEFT JOIN 
    ECLUB2.PERSON_EXT_ATTRS Kommentar 
    ON 
    Kommentar.personcenter = comp.center 
    and Kommentar.personid = comp.id 
    and Kommentar.name     = '_eClub_Comment' 
left join eclub2.Person_Ext_Attrs Emails 
    ON 
    k.center  = Emails.PersonCenter 
    AND k.id  = Emails.PersonId 
    AND Emails.Name = '_eClub_Email'
left join eclub2.Person_Ext_Attrs phone 
    ON 
    k.center  = phone.PersonCenter 
    AND k.id  = phone.PersonId 
    AND phone.Name = '_eClub_PhoneWork'


left join
    ECLUB2.ACCOUNT_RECEIVABLES comp_account on comp_account.CUSTOMERCENTER=comp.center and comp_account.CUSTOMERID=comp.id and comp_account.AR_TYPE=4
left JOIN 
    ECLUB2.PAYMENT_ACCOUNTS comp_paymentaccount 
    ON 
    comp_paymentaccount.center = comp_account.center 
    and comp_paymentaccount.id = comp_account.id 
left JOIN 
    ECLUB2.PAYMENT_AGREEMENTS comp_pa 
    ON 
    comp_paymentaccount.ACTIVE_AGR_CENTER    = comp_pa.center 
    and comp_paymentaccount.ACTIVE_AGR_ID    = comp_pa.id 
    and comp_paymentaccount.ACTIVE_AGR_SUBID = comp_pa.subid 
    and comp_pa.STATE in (1,2,4,14,13)

left join (select distinct pgr.GRANTER_CENTER, pgr.granter_id, pgr.GRANTER_SUBID, pgr.SPONSORSHIP_NAME, pgr.SPONSORSHIP_AMOUNT, pp.ref_globalid
from ECLUB2.PRIVILEGE_GRANTS pgr 
join 
    ECLUB2.PRODUCT_PRIVILEGES pp on pp.PRIVILEGE_SET = pgr.PRIVILEGE_SET 
    where pgr.GRANTER_SERVICE='CompanyAgreement' and pgr.SPONSORSHIP_NAME!= 'NONE' and (pgr.VALID_TO is null or pgr.VALID_TO > eclub2.datetolong(to_char(exerpsysdate(), 'YYYY-MM-DD HH24:MM'))))
priv on priv.GRANTER_CENTER=cag.center and priv.granter_id=cag.id and priv.GRANTER_SUBID = cag.SUBID and priv.REF_GLOBALID = pd.globalid 

where 
p.center = 559 and comp.center is not null
order by comp.center, comp.id




