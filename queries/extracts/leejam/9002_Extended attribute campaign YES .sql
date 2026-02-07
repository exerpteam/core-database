select
p.center ||'p'|| p.id,
pea.name,
pea.txtvalue

from persons p

join person_ext_attrs pea
on 
p.center = pea.personcenter
and
p.id = pea.personid
and
pea.name = 'SFD22FreeDaysCampaign'
where
pea.txtvalue = 'YES'