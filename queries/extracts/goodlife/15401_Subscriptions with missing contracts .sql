-- The extract is extracted from Exerp on 2026-02-08
--  

select 
p.external_id
,p.center || 'p' || p.id as PersonID
,p.firstname
,p.lastname
,p.center as ClubNumber
,pr.name as ProductName
,pr.globalid as ProductGlobalID
,TO_CHAR(longtodatec(s.creation_time, 100),'YYYY-MM-DD') as SubscriptionCreationDate
,s.start_date as SubscriptionStartDate
,s.creator_center || 'emp' || s.creator_id As SalesPerson

from subscriptions s
	join products pr
		on s.subscriptiontype_center = pr.center
		and s.subscriptiontype_id = pr.id
	join persons p
		on p.center = s.owner_center
		and p.id = s.owner_id
		and p.persontype!=4
	left join journalentries j
		on s.owner_center = j.person_center
		and s.owner_id = j.person_id
		and TO_CHAR(longtodatec(s.creation_time, 100), 'YYYY-MM-DD') = TO_CHAR(longtodatec(j.creation_time, 100), 'YYYY-MM-DD')
		and (j.name='Customer contract' or j.name='Clipcard contract' or j.name like 'Apply: Change subscription%' or j.name like 'Apply: Transfer%')
where 
	  j.person_center is null
	 and TO_CHAR(longtodatec(s.creation_time, 100), 'YYYY-MM-DD')>'20170701'
	 and s.start_date>'20170701'
	 and s.state=2
	and pr.name not like '%legacy%'
	and pr.name not like '%Legacy'
	and pr.name not like '%reinstatement%'
	and pr.name not like '%Former Corporate%'
	and pr.name not like '%CERT%'
	and pr.name not like '%Limited Offer'
	and s.creator_center || 'emp' || s.creator_id  not in
(
'990emp255',
'990emp2',
'990emp9811',
'990emp254'
)
and p.center not in (319, 239)
and s.center in ($$scope$$) 