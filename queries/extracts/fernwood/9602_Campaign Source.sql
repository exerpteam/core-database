-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        c.name as Club
        ,pea.personcenter||'p'||pea.personid AS PersonID 
        ,pea.txtvalue AS "Lead source"
        ,CASE
                p.status
                WHEN 0 THEN 'Lead'
                WHEN 1 THEN 'Active'
                WHEN 2 THEN 'Inactive'
                WHEN 3 THEN 'Temporary Inactive'
                WHEN 4 THEN 'Transferred'
                WHEN 5 THEN 'Duplicate'
                WHEN 6 THEN 'Prospect'
                WHEN 7 THEN 'Deleted'
                WHEN 8 THEN 'Anonymized'
                WHEN 9 THEN 'Contact'
        END AS "Person Status"
		,CASE
			p.persontype
			WHEN 0 THEN 'Private'
			WHEN 1 THEN 'Student'
			WHEN 2 THEN 'Staff'
			WHEN 3 THEN 'Friend'
			WHEN 4 THEN 'Corporate'
			WHEN 5 THEN 'One Man Corporate'
		 	WHEN 6 THEN 'Family'
			WHEN 7 THEN 'Senior'
			WHEN 8 THEN 'Guest'
			WHEN 9 THEN 'Child'
			WHEN 10 THEN 'External Staff' 
		END AS "Person type"               
FROM 
        person_ext_attrs pea
join 
        persons p 
        on p.center = pea.personcenter 
        and p.id = pea.personid
join 
        centers c 
        on c.id = p.center 
where 
        pea.name = 'CampaignSource'
        and p.center in (:Scope) 