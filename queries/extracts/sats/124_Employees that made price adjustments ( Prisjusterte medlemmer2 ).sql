select distinct j.creatorcenter, j.creatorid from persons p, journalentries j, 
subscriptions s where p.center = j.center and p.id = j.id and 
s.owner_center=p.center and s.owner_id=p.id and s.subscription_price <> 
s.binding_price and lower(j.name) like '%subscription%' and j.name 
<> '_eClub2_Subscription contract
AND j.center BETWEEN  :center_from and 
 :center_last
