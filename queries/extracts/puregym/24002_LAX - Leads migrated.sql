select leads.NEWPERSONCENTER as Center, leads.FIRSTNAME, leads.LASTNAME, leads.EMAIL, leads.MOBILEPHONE
, to_char(leads.PREVIOUSMEMBERSHIPSTARTDATE,'YYYY-MM-DD') PREVIOUSMEMBERSHIPSTARTDATE
, to_char(leads.PREVIOUSMEMBERSHIPENDDATE,'YYYY-MM-DD') PREVIOUSMEMBERSHIPENDDATE
, leads.CONSENTDIRECT
, leads.CONSENTTHIRDPARTY
from LAF_LEADS leads
left join PERSON_EXT_ATTRS mob on mob.name = '_eClub_PhoneSMS' and mob.txtvalue = leads.MobilePhone
left join PERSON_EXT_ATTRS email on email.name = '_eClub_Email' and email.txtvalue = leads.Email
where (mob.PERSONCENTER is null and email.PERSONCENTER is null) and leads.NEWPERSONCENTER = $$center$$

union all

SELECT
    per.center,
    per.FIRSTNAME,
    per.LASTNAME,
    mobile.txtvalue as MOBILEPHONE,
    email.txtvalue as EMAIL
    ,to_char(sub.START_DATE,'YYYY-MM-DD') as PREVIOUSMEMBERSHIPSTARTDATE
    ,to_char(sub.END_DATE,'YYYY-MM-DD') as PREVIOUSMEMBERSHIPENDDATE
    , nvl(newsletter.txtvalue, 'false') as CONSENTDIRECT
    , nvl(thirdparty.txtvalue, 'false') as CONSENTTHIRDPARTY
FROM
    persons per
JOIN
    converter_entity_state ces
ON
    per.center = ces.newentitycenter
    AND per.id = ces.newentityid
    AND ces.oldentityid LIKE 'LAXITX_%'
    AND ces.writername = 'ClubLeadPersonWriter'
JOIN SUBSCRIPTIONS sub on sub.OWNER_CENTER = per.center and sub.OWNER_ID = per.ID
JOIN PRODUCTS pd on pd.center = sub.SUBSCRIPTIONTYPE_CENTER and pd.ID = sub.SUBSCRIPTIONTYPE_ID and pd.globalid = 'LA_FITNESS_EXMEMBER'
LEFT JOIN SUBSCRIPTIONS sub_new on sub_new.OWNER_CENTER = per.center and sub_new.OWNER_ID = per.ID
LEFT JOIN PRODUCTS pd_new on pd_new.center = sub_new.SUBSCRIPTIONTYPE_CENTER and pd_new.ID = sub_new.SUBSCRIPTIONTYPE_ID and pd_new.globalid != 'LA_FITNESS_EXMEMBER'

LEFT JOIN
    person_ext_attrs mobile
ON
    mobile.personcenter = per.center
    AND mobile.personid = per.id
    AND mobile.name = '_eClub_PhoneSMS'
    AND mobile.txtvalue IS NOT NULL
LEFT JOIN
    person_ext_attrs email
ON
    email.personcenter = per.center
    AND email.personid = per.id
    AND email.name = '_eClub_Email'
    AND email.txtvalue IS NOT NULL
LEFT JOIN
    person_ext_attrs newsletter
ON
    newsletter.personcenter = per.center
    AND newsletter.personid = per.id
    AND newsletter.name = 'eClubIsAcceptingEmailNewsLetters'
LEFT JOIN
    person_ext_attrs thirdparty
ON
    thirdparty.personcenter = per.center
    AND thirdparty.personid = per.id
    AND thirdparty.name = 'eClubIsAcceptingThirdPartyOffers'
where per.STATUS in (0,2) 
        -- no other membership since the migration
        and pd_new.center is null
        and per.center = $$center$$
        
        
