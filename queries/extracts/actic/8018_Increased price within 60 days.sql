-- The extract is extracted from Exerp on 2026-02-08
-- ..on subscriptions with enddate set.
select
    s.owner_center,
    s.owner_center||'p'||s.owner_id as customer,
    p.fullname as customer_name,
--    spp.subscription_price as subscription_price,
--    spp.from_date,
    MobilePhone.TxtValue AS MobilePhone,
    Emails.TxtValue as Email,
    COUNT (distinct c.checkin_time) as CheckinCount
from 
      persons p
join subscriptions s
    on
        p.center = s.owner_center
    and p.id = s.owner_id
join subscriptionperiodparts spp
    on
    s.center = spp.center
    and s.id = spp.id
left join checkins c
    on
    p.center = c.person_center
    and p.id = c.person_id
LEFT JOIN 
    Person_Ext_Attrs MobilePhone 
    ON 
    p.center       = MobilePhone.PersonCenter 
    AND p.id       = MobilePhone.PersonId 
    AND MobilePhone.Name = '_eClub_PhoneSMS' 
LEFT JOIN 
    Person_Ext_Attrs Emails 
    ON 
    p.center  = Emails.PersonCenter 
    AND p.id  = Emails.PersonId 
    AND Emails.Name = '_eClub_Email' 
where
        spp.subscription_price <>
        (select
                max(spp2.subscription_price)
         from
                subscriptionperiodparts spp2
         where
                    spp2.center = s.center
                and spp2.id = s.id
                and to_char(spp.from_date, 'yyyy-mm-dd')  > to_char(exerpsysdate() - 60, 'yyyy-mm-dd')
                and spp.subscription_price >  spp2.subscription_price
                and spp.period_number -1 = spp2.period_number
        )
    and s.end_date between (:sub_end_from_date) and (:sub_end_to_Date)
    and s.owner_center in (:scope)
    and c.checkin_time between (:check_in_from) and (:check_in_to)
group by
    s.owner_center,
    s.owner_center,
    s.owner_id,
    p.fullname,
    MobilePhone.TxtValue,
    Emails.TxtValue