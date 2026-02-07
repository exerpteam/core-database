select
p.center || 'p' || p.id as Kundnummer,
p.ssn as Personnummer,
p.FIRSTNAME as Namn,
p.LASTNAME as Efternamn,
home.txtvalue as Telefonnummer,
mobile.txtvalue as Mobiltelefonnummer,
email.txtvalue as "E-postadress",
p.ADDRESS1 as Adress1,
p.ADDRESS2 as Adress2,
p.ZIPCODE as Postnummer,
p.CITY as Ort,
'' as Anteckningar,

case when comp.center is not null and priv.SPONSORSHIP_NAME = 'FULL' then comp.ssn when st.ST_TYPE = 1 and op.center is not null then op.ssn when st.ST_TYPE = 1 and op.center is null then p.ssn else null end as "Kontoinnehavares Personnummer",
case when comp.center is not null and priv.SPONSORSHIP_NAME = 'FULL' then comp.lastname when st.ST_TYPE = 1 and op.center is not null then op.FULLNAME when st.ST_TYPE = 1 and op.center is null then p.FULLNAME else null end as "Kontoinnehavare namn",
case when st.ST_TYPE = 1 then case when comp.center is not null and priv.SPONSORSHIP_NAME = 'FULL' then comp_pa.BANK_REGNO when op.center is not null then op_pa.BANK_REGNO when pa.center is not null then pa.BANK_REGNO else null end else null end as Clearingnummer,
case when st.ST_TYPE = 1 then case when comp.center is not null and priv.SPONSORSHIP_NAME = 'FULL' then comp_pa.BANK_ACCNO when op.center is not null then op_pa.BANK_ACCNO when pa.center is not null then pa.BANK_ACCNO else null end else null end as Bankkontonummer,

'' as Bank,
case when st.ST_TYPE = 1 then case when (sub.BINDING_END_DATE is not null and sub.BINDING_END_DATE > to_date('2011-07-31', 'YYYY-MM-DD')) then sub.BINDING_PRICE else sub.SUBSCRIPTION_PRICE end else null end as Månadsbelopp,
to_char(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY') as "Kort köpt",
to_char(sub.END_DATE, 'DD-MM-YYYY') as "Kortets Gilltighetstid",
to_char(sub.BINDING_END_DATE, 'DD-MM-YYYY') as "Prislåst t.o.m.",
fh.FreezeFrom as "Fryst från ",
fh.FreezeTo as "Fryst till",
decode(p.PERSONTYPE, 4, 'Company', 'Private') as "Avtalstyp",
null as "Betalningshistorik",
comp.lastname as "Företagskoppling",
pg.NAME as "ProductGroup",
priv.SPONSORSHIP_NAME
--,priv.SPONSORSHIP_AMOUNT

from ECLUB2.persons p
join ECLUB2.SUBSCRIPTIONS sub on p.center = sub.OWNER_CENTER and p.id = sub.OWNER_ID and sub.STATE in (2,4,8)
join ECLUB2.SUBSCRIPTIONTYPES st on st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER and st.id = sub.SUBSCRIPTIONTYPE_ID
join
    ECLUB2.PRODUCTS pd on st.center=pd.center and st.id=pd.id
join 
    ECLUB2.PRODUCT_GROUP pg on pg.ID = pd.PRIMARY_PRODUCT_GROUP_ID

left join   
    ECLUB2.PERSON_EXT_ATTRS home on p.center=home.PERSONCENTER and p.id=home.PERSONID and home.name='_eClub_PhoneHome'
left join   
    ECLUB2.PERSON_EXT_ATTRS mobile on p.center=mobile.PERSONCENTER and p.id=mobile.PERSONID and mobile.name='_eClub_PhoneSMS'
left join   
    ECLUB2.PERSON_EXT_ATTRS workphone on p.center=workphone.PERSONCENTER and p.id=workphone.PERSONID and workphone.name='_eClub_PhoneWork'
left join   
    ECLUB2.PERSON_EXT_ATTRS email on p.center=email.PERSONCENTER and p.id=email.PERSONID and email.name='_eClub_Email'
left join   
    ECLUB2.PERSON_EXT_ATTRS personcomment on p.center=personcomment.PERSONCENTER and p.id=personcomment.PERSONID and personcomment.name='_eClub_Comment'
left join
    ECLUB2.ACCOUNT_RECEIVABLES account on account.CUSTOMERCENTER=p.center and account.CUSTOMERID=p.id and account.AR_TYPE=4
left JOIN 
    ECLUB2.PAYMENT_ACCOUNTS paymentaccount 
    ON 
    paymentaccount.center = account.center 
    and paymentaccount.id = account.id 
left JOIN 
    ECLUB2.PAYMENT_AGREEMENTS pa 
    ON 
    paymentaccount.ACTIVE_AGR_CENTER    = pa.center 
    and paymentaccount.ACTIVE_AGR_ID    = pa.id 
    and paymentaccount.ACTIVE_AGR_SUBID = pa.subid 
    and pa.STATE in (1,2,4,14)
left join
    ECLUB2.RELATIVES op_rel on op_rel.relativecenter=p.center and op_rel.relativeid=p.id and op_rel.RTYPE = 12 and op_rel.STATUS < 3
left join
    ECLUB2.PERSONS op  on op.center = op_rel.center and op.id = op_rel.id
left join
    ECLUB2.ACCOUNT_RECEIVABLES op_account on op_account.CUSTOMERCENTER=op.center and op_account.CUSTOMERID=op.id and op_account.AR_TYPE=4
left JOIN 
    ECLUB2.PAYMENT_ACCOUNTS op_paymentaccount 
    ON 
    op_paymentaccount.center = op_account.center 
    and op_paymentaccount.id = op_account.id 
left JOIN 
    ECLUB2.PAYMENT_AGREEMENTS op_pa 
    ON 
    op_paymentaccount.ACTIVE_AGR_CENTER    = op_pa.center 
    and op_paymentaccount.ACTIVE_AGR_ID    = op_pa.id 
    and op_paymentaccount.ACTIVE_AGR_SUBID = op_pa.subid 
    and op_pa.STATE in (1,2,4,14)
left join (
    select  fr.subscription_center, fr.subscription_id, to_char(min(fr.START_DATE), 'DD-MM-YYYY') as FreezeFrom, to_char(max(fr.END_DATE), 'DD-MM-YYYY') as FreezeTo, min(fr.text) as FreezeReason 
    from ECLUB2.SUBSCRIPTION_FREEZE_PERIOD fr where fr.subscription_center in (559) and fr.END_DATE > to_date('2011-07-31', 'YYYY-MM-DD') group by fr.subscription_center, fr.subscription_id
) fh on fh.subscription_center = sub.center and fh.subscription_id = sub.id
left join
    ECLUB2.RELATIVES comp_rel on comp_rel.center=p.center and comp_rel.id=p.id and comp_rel.RTYPE = 3 and comp_rel.STATUS < 3
left join ECLUB2.COMPANYAGREEMENTS cag on cag.center= comp_rel.RELATIVECENTER and cag.id=comp_rel.RELATIVEID and cag.subid = comp_rel.RELATIVESUBID
left join eclub2.persons comp on comp.center = cag.center and comp.id=cag.id

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
    and comp_pa.STATE in (1,2,4,14)

left join (select distinct pgr.GRANTER_CENTER, pgr.granter_id, pgr.GRANTER_SUBID, pgr.SPONSORSHIP_NAME, pgr.SPONSORSHIP_AMOUNT, pp.ref_globalid
from ECLUB2.PRIVILEGE_GRANTS pgr 
join 
    ECLUB2.PRODUCT_PRIVILEGES pp on pp.PRIVILEGE_SET = pgr.PRIVILEGE_SET 
    where pgr.GRANTER_SERVICE='CompanyAgreement' and pgr.SPONSORSHIP_NAME!= 'NONE' and (pgr.VALID_TO is null or pgr.VALID_TO > eclub2.datetolong(to_char(exerpsysdate(), 'YYYY-MM-DD HH24:MM'))))
priv on priv.GRANTER_CENTER=cag.center and priv.granter_id=cag.id and priv.GRANTER_SUBID = cag.SUBID and priv.REF_GLOBALID = pd.globalid 

where 
p.center = 559
--and ((pgr.PRIVILEGE_SET is not null and pp.PRIVILEGE_SET is not null) or (pgr.PRIVILEGE_SET is null and pp.PRIVILEGE_SET is null))
--and pg.name not in ('Flex Memberships','EFT Memberships', 'Cash Memberships', 'Free Memberships')




