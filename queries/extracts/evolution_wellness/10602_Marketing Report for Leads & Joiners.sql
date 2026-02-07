-- Add new column "Tag" #194930
-- Add new column "External ID","Signed Guest Waiver" and show the latest subscription #194930
With
    pmp_xml AS
    (
        SELECT
            sp.id,
            CAST(convert_from(sp.mimevalue, 'UTF-8') AS XML) AS pxml
        FROM
            evolutionwellness.systemproperties sp
        WHERE
            sp.globalid = 'DYNAMIC_EXTENDED_ATTRIBUTES'
    )
    ,
    second_Table AS
    (
        SELECT
            UNNEST(xpath('attributes/attribute',px.pxml))::text AS xml_content,
			px.pxml
	     FROM
            pmp_xml px
        JOIN
            evolutionwellness.systemproperties sp
        ON
            sp.id = px.id
    )
    ,
    third_Table AS
    (
        SELECT
            split_part(xml_content,'"',2) AS Attribute, 
			unnest(string_to_array(xml_content, 'possibleValue id=')) AS Value,
			split_part(unnest(string_to_array(xml_content, 'possibleValue id=')),'"',2) AS Source,
			split_part(unnest(string_to_array(xml_content, 'possibleValue id=')),'>',2) AS tmp_SourceName
        FROM
            second_Table
     ),
	SourceValues AS
	(
		select 
			Attribute,
			Source,
			SUBSTRING(tmp_SourceName, 1, POSITION('<' IN tmp_SourceName)-1) AS Source_Name
		from 
			third_table
		where attribute = 'Source' and Source != 'Source'
	),
m_Persons AS
(
select
	COALESCE(current_person_center, persons.center) AS center,
	COALESCE(current_person_id, persons.id) AS id,
	longtodatec(je.creation_time,persons.center) AS CreationDate
	
FROM
	persons
JOIN
        journalentries je
        ON
            je.person_center = persons.center
        AND je.person_id = persons.id
        AND je.name = 'Person created'

WHERE
	persons.status NOT IN (2,5,7,8)   --Exclude Inactive, Duplicate, Deleted and Anomymized
	AND persons.center IN (:Scope)
	AND CAST(longToDateC(je.Creation_time, persons.center) as Date) >= cast(:From AS Date)
	AND CAST(longToDateC(je.Creation_time, persons.center) as Date) <= cast(:To AS Date)
)

select
    CASE
    	WHEN c.Name like 'FF%'
        THEN 'Fitness First'
	WHEN c.Name like 'CF%'
	THEN 'Celebrity Fitness'
	WHEN c.Name like 'GF%'
	THEN 'GoFit'
        WHEN c.org_code like 'FF%' OR c.org_code like 'Fitness First%'
        THEN 'Fitness First'
        WHEN c.org_code like 'CF%' OR c.org_code like 'Celebrity Fitness%'
        THEN 'Celebrity Fitness'
        ELSE 'Unknown'
        END AS Brand,
c.country 		AS Country,
c.name 			AS Center,
p.CENTER || 'p' || p.id AS memberid,
p.external_id   AS External_id,
p.firstname		AS FirstName,
p.lastname		AS LastName,
p.FULLNAME		AS FullName,
pea_email.TXTVALUE    	AS Email,
pea_mobile.TXTVALUE   	AS Phone,
COALESCE(sv.Source_Name, pea_source.txtvalue) AS Source,
pea_campaign.txtvalue 	AS Campaign,
pea_tag.txtvalue 		AS Tag,
CASE p.PERSONTYPE
                WHEN 0
                THEN 'PRIVATE'
                WHEN 1
                THEN 'STUDENT'
                WHEN 2
                THEN 'STAFF'
                WHEN 3
                THEN 'FRIEND'
                WHEN 4
                THEN 'CORPORATE'
                WHEN 5
                THEN 'ONEMANCORPORATE'
                WHEN 6
                THEN 'FAMILY'
                WHEN 7
                THEN 'SENIOR'
                WHEN 8
                THEN 'GUEST'
                WHEN 9
                THEN 'CHILD'
                WHEN 10
                THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
            END AS Person_Type,
  CASE p.STATUS
                WHEN 0
                THEN 'LEAD'
                WHEN 1
                THEN 'ACTIVE'
                WHEN 2
                THEN 'INACTIVE'
                WHEN 3
                THEN 'TEMPORARYINACTIVE'
                WHEN 4
                THEN 'TRANSFERRED'
                WHEN 5
                THEN 'DUPLICATE'
                WHEN 6
                THEN 'PROSPECT'
                WHEN 7
                THEN 'DELETED'
                WHEN 8
                THEN 'ANONYMIZED'
                WHEN 9
                THEN 'CONTACT'
                ELSE CAST(p.status AS varchar)
            END                    AS Person_Status,
p.Sex AS Gender,
	p.First_Active_Start_date AS "Conversion Date",
pr.Name				   AS "Subscription_Name",
CASE s.state 
                WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' 
                WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE CAST(s.state as varchar)
        END 			   AS Subscription_Status,
CASE S.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 
        'AWAITING ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 
        'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' 
        WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 
        'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE CAST(s.sub_state as varchar) END 
				       AS "Subscription_Sub-State",
--longtodatec(je.creation_time,p.center) AS Person_Creation,
m_Persons.CreationDate AS Person_Creation,
longtodatec(s.creation_time, s.center) AS Subscription_Creation,
s.start_date 			       AS Subscription_Start,
s.end_date 			       AS Subscription_End,
--s.subscription_price
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM journalentries je
            WHERE je.person_center = p.center
	AND je.person_id = p.id
	AND je.name = 'Guest Waiver'
        ) 
        THEN 'Yes' 
        ELSE 'No' 
    END AS "Signed Guest Waiver"
from 
	m_Persons
JOIN persons p
	ON
	    p.center = m_Persons.center
	    AND p.id = m_Persons.id	
    JOIN
            CENTERS c
        ON
            c.id = p.CENTER
    LEFT JOIN
            PERSON_EXT_ATTRS pea_source
        ON
            pea_source.PERSONCENTER = p.center
        AND pea_source.PERSONID = p.id
        AND pea_source.NAME = 'Source'
    LEFT JOIN
	    SourceValues sv
	ON
	    sv.Source = pea_source.txtvalue
    LEFT JOIN
            PERSON_EXT_ATTRS pea_campaign
        ON
            pea_campaign.PERSONCENTER = p.center
        AND pea_campaign.PERSONID = p.id
        AND pea_campaign.NAME = 'Campaign'
	LEFT JOIN
            PERSON_EXT_ATTRS pea_tag
        ON
            pea_tag.PERSONCENTER = p.center
        AND pea_tag.PERSONID = p.id
        AND pea_tag.NAME = 'THCampaign'
    LEFT JOIN
            PERSON_EXT_ATTRS pea_email
        ON
            pea_email.PERSONCENTER = p.center
        AND pea_email.PERSONID = p.id
        AND pea_email.NAME = '_eClub_Email'
    LEFT JOIN
            PERSON_EXT_ATTRS pea_mobile
        ON
            pea_mobile.PERSONCENTER = p.center
        AND pea_mobile.PERSONID = p.id
        AND pea_mobile.NAME = '_eClub_PhoneSMS'
--	LEFT JOIN Subscriptions s
--		ON s.owner_center = p.center
--		AND s.owner_id = p.id
	--	AND s.sub_state != 8
	LEFT JOIN LATERAL (
			SELECT s1.*
			FROM subscriptions s1
			WHERE s1.sub_state <> 8
			AND s1.owner_center = p.center
			AND s1.owner_id = p.id
			AND CAST(longToDateC(s1.Creation_time, s1.center) as Date) <= cast(:To AS Date)
		ORDER BY s1.start_date DESC, s1.creation_time desc
		LIMIT 1
		) s ON TRUE
    LEFT JOIN
        subscriptiontypes st
    ON
        st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
    LEFT JOIN
        PRODUCTS pr
    ON
        pr.center = st.center
        AND pr.id = st.id
where 
	p.status NOT IN (2,5,7,8)   --Exclude Inactive, Duplicate, Deleted and Anomymized
	AND p.center IN (:Scope)