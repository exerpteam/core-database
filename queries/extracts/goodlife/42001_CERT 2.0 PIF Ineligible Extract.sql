WITH RECURSIVE subs (center,id,transferred_center,transferred_id)  AS (

        -- Get original subscription id if transferred to get person id at time of sale

        SELECT

        s.center
        ,s.id
	,s.transferred_center
	,s.transferred_id

        FROM

        subscriptions s

        JOIN subscriptiontypes st
        ON st.center = s.subscriptiontype_center 
        AND st.id = s.subscriptiontype_id
	
	JOIN product_and_product_group_link ppgl
        ON st.center = ppgl.product_center 
        AND st.id = ppgl.product_id
        AND ppgl.product_group_id IN (12601,12603) -- CERT 1.0 AND 2.0 Products

        JOIN persons p
        ON p.center = s.owner_center
        AND p.id = s.owner_id
        AND p.persontype != 4 -- Not Corporate

        WHERE
        st.st_type = 0 -- Cash/PIF
        AND s.end_date = CURRENT_DATE + $$days$$
        AND s.state IN (2,4) -- Active, Frozen

        UNION

        SELECT

        s.center
        ,s.id
        ,s.transferred_center
	,s.transferred_id

        FROM subs su

        JOIN subscriptions s

        ON s.transferred_center = su.center
        AND s.transferred_id = su.id

), original_owner AS (

        -- person id at time of sale, to get company relations at time of sale

        SELECT

        s.center
        ,s.id
        ,s.owner_center
        ,s.owner_id
        ,p.current_person_center
        ,p.current_person_id


        FROM

        subs su

        JOIN subscriptions s USING (center,id)

        JOIN persons p
        ON s.owner_center = p.center
        AND s.owner_id = p.id

        WHERE

        NOT EXISTS (

                -- do not include subscriptions if a previous subscription exists transferring to that subscription - i.e. is not the original subscription

                SELECT

                1

                FROM subs sx

                WHERE

                s.center = sx.transferred_center
                AND s.id = sx.transferred_id

        )

), active_subs AS (

        -- Actve subscription and member details

        SELECT

        s.center
        ,s.id
        ,s.subscription_price            AS FullRate
        ,s.end_date                      AS ExpiryDate
        ,bi_decode_field('SUBSCRIPTIONS', 'STATE', s.state) AS State
        ,bi_decode_field('SUBSCRIPTIONS', 'SUB_STATE', s.sub_state) AS Sub_state
        ,companyperson.center||'p'||companyperson.id AS CompanyID
        ,companyperson.lastname As CompanyName
        ,companyperson.center AS companypersoncenter
        ,companyperson.id AS companypersonid
        ,pu.use_time AS use_time
        ,p.current_person_center
        ,p.current_person_id
        ,p.external_ID AS ExternalID
        ,p.fullname AS MemberName
        ,p.center||'p'||p.id AS MembersNumber
        ,p.firstname
        ,p.lastname


        FROM

        subs su

        JOIN subscriptions s USING (center,id)

        JOIN privilege_usages pu
        ON s.invoiceline_center	= pu.target_center
        AND s.invoiceline_id = pu.target_id
        AND s.invoiceline_subid = pu.target_subid
        AND pu.target_service = 'InvoiceLine'

        JOIN privilege_grants pg
        ON pg.id = pu.grant_id
        AND pg.granter_service = 'CompanyAgreement'

	JOIN persons companyperson
        ON pg.granter_center = companyperson.center
        AND pg.granter_id = companyperson.id

        JOIN persons p
        ON s.owner_center = p.center
        AND s.owner_id = p.id

        WHERE

        su.transferred_center IS NULL -- Exclude previous instances of subscription that have since been transferred

), reltemp AS (

         SELECT

        r.center
        ,r.id
        ,r.subid
        ,ac.current_person_center
        ,ac.current_person_id
     

    FROM

    original_owner oo

JOIN active_subs ac USING (current_person_center,current_person_id)

    JOIN relatives r
    ON r.relativecenter = oo.owner_center
    AND r.relativeid = oo.owner_id
    AND r.rtype = 2 -- Employee of company
    AND r.center = ac.companypersoncenter -- target company that granted purchase privilege for this subscription
    AND r.id = ac.companypersonid


), relFamTemp AS (

    SELECT

    r.center
    ,r.id
    ,r.subid
        
        ,ac.current_person_center
        ,ac.current_person_id

    FROM

    original_owner oo

JOIN active_subs ac USING (current_person_center,current_person_id)

    JOIN relatives r
    ON r.center = oo.owner_center
    AND r.id = oo.owner_id
    AND r.rtype = 17 -- Company my family is employed at - only exists for family of employee
    AND r.relativecenter = ac.companypersoncenter
    AND r.relativeid = ac.companypersonid
        AND (ac.current_person_center,ac.current_person_id) NOT IN (SELECT current_person_center,current_person_id FROM reltemp)



), fofetemp AS (

        SELECT

        r.current_person_center
        ,r.current_person_id    
        ,r2.relativecenter
        ,r2.relativeid
        ,r2.subid
        ,COUNT(*) OVER (PARTITION BY r.current_person_center,r.current_person_id) AS count_fam
    
    FROM

relFamTemp r

        JOIN relatives r2       
    ON r.center = r2.center
    AND r.id = r2.id
    AND r2.rtype = 16 -- primary employee at company  


), relscn AS (

        SELECT

        ac.current_person_center
        ,ac.current_person_id
        ,ac.use_time
        ,CASE
                WHEN r.current_person_center IS NOT NULL AND rf.current_person_center IS NULL
                THEN 'EMPLOYEE'
                WHEN r.current_person_center IS NULL AND rf.current_person_center IS NOT NULL
                THEN 'FAMILY'
                WHEN r.current_person_center IS NOT NULL AND rf.current_person_center IS NOT NULL
                THEN 'LOOKUP'
                ELSE 'ERROR'
        END AS scenario
        ,rf.center
        ,rf.id
        ,rf.subid
        

        FROM

        active_subs ac

        LEFT JOIN reltemp r
        ON r.current_person_center = ac.current_person_center
        AND r.current_person_id = ac.current_person_id

        LEFT JOIN relFamTemp rf
        ON rf.current_person_center = ac.current_person_center
        AND rf.current_person_id = ac.current_person_id
        

), lookupsTemp AS (

        SELECT

        r.current_person_center
        ,r.current_person_id
        ,r.use_time
        ,r.center
        ,r.id
        ,r.subid
        ,17 AS rtype
        ,0 AS relativecenter
        ,0 AS relativeid


        FROM

        relscn r

        WHERE

        r.scenario = 'LOOKUP'

        UNION

        SELECT

        r.current_person_center
        ,r.current_person_id
        ,r.use_time
        ,r.center
        ,r.id
        ,f.subid
        ,16 AS rtype
        ,f.relativecenter
        ,f.relativeid


        FROM

        relscn r

        JOIN fofetemp f USING (current_person_center,current_person_id)

        WHERE

        r.scenario = 'LOOKUP'

        UNION

          SELECT

        r.current_person_center
        ,r.current_person_id
        ,r.use_time
        ,r.center
        ,r.id
        ,f.subid
        ,16 AS rtype
        ,f.relativecenter
        ,f.relativeid


        FROM

        relscn r

        JOIN fofetemp f USING (current_person_center,current_person_id)

        WHERE

        r.scenario = 'FAMILY'
        AND f.count_fam > 1


), lookups AS (
SELECT

r.*



FROM

lookupsTemp r

JOIN state_change_log scl
    ON r.center = scl.center
    AND r.id = scl.id
    AND r.subid = scl.subid
    AND scl.entry_type = 4 -- Relation
    AND scl.stateid = 1 -- Active
    AND r.use_time BETWEEN scl.entry_start_time AND scl.entry_end_time

), who_is_emp AS (

        SELECT

        r.current_person_center
        ,r.current_person_id
        ,r.current_person_center AS emp_center
        ,r.current_person_id AS emp_id

        FROM

        relscn r

        WHERE

        r.scenario = 'EMPLOYEE'

        UNION

        SELECT

        r.current_person_center
        ,r.current_person_id
        ,f.relativecenter AS emp_center
        ,f.relativeid AS emp_id


        FROM

        relscn r

        JOIN fofetemp f
        ON f.current_person_center = r.current_person_center
        AND f.current_person_id = r.current_person_id
        AND f.count_fam = 1
        AND r.scenario = 'FAMILY'

        UNION

        SELECT

        r.current_person_center
        ,r.current_person_id
        ,l16.relativecenter AS emp_center
        ,l16.relativeid AS emp_id


        FROM

        (
                SELECT DISTINCT

                current_person_center
                ,current_person_id
                ,scenario

                FROM

                relscn
        ) r

        JOIN fofetemp f
        ON f.current_person_center = r.current_person_center
        AND f.current_person_id = r.current_person_id
        AND f.count_fam > 1
        AND r.scenario = 'FAMILY'

        JOIN lookups l16
        ON l16.current_person_center = r.current_person_center
        AND l16.current_person_id = r.current_person_id
        AND l16.rtype = 16
        
        UNION

        SELECT

        r.current_person_center
        ,r.current_person_id
        ,r.current_person_center AS emp_center
        ,r.current_person_id AS emp_id

        FROM

        relscn r

        WHERE

        r.scenario = 'LOOKUP'

        AND NOT EXISTS (

                SELECT

                1

                FROM

                lookups l17

                WHERE
                l17.current_person_center = r.current_person_center
                AND l17.current_person_id = r.current_person_id
        )
        
        UNION

        SELECT

        r.current_person_center
        ,r.current_person_id
        ,l16.relativecenter AS emp_center
        ,l16.relativeid AS emp_id

        FROM

        relscn r

        JOIN lookups l16
        ON l16.current_person_center = r.current_person_center
        AND l16.current_person_id = r.current_person_id
        AND l16.rtype = 16
        AND r.scenario = 'LOOKUP'

)
   

SELECT

pea_email.txtvalue AS Email
, pn.firstname AS PayorFirstName
, pn.lastname AS PayorLastName
, p.MemberName	
, p.MembersNumber
, p.ExternalID
, p.FullRate
, pn.current_person_center||'p'||pn.current_person_id AS PayorNumber
, p.ExpiryDate
,  CASE 
        WHEN (LENGTH(TRIM(BOTH FROM pea_mphone.txtvalue)) = '12' AND LEFT(TRIM(BOTH FROM pea_mphone.txtvalue), 1) = '+')
        THEN RIGHT(TRIM(BOTH FROM pea_mphone.txtvalue), 10)
        ELSE pea_mphone.txtvalue
END AS CellNumber
, CASE 
        WHEN (LENGTH(TRIM(BOTH FROM pea_hphone.txtvalue)) = '12' AND LEFT(TRIM(BOTH FROM pea_hphone.txtvalue), 1) = '+')
        THEN RIGHT(TRIM(BOTH FROM pea_hphone.txtvalue), 10)
        ELSE pea_hphone.txtvalue
END AS HomeNumber    
, CASE 
        WHEN (LENGTH(TRIM(BOTH FROM pea_wphone.txtvalue)) = '12' AND LEFT(TRIM(BOTH FROM pea_wphone.txtvalue), 1) = '+')
        THEN RIGHT(TRIM(BOTH FROM pea_wphone.txtvalue), 10)
        ELSE pea_wphone.txtvalue
END AS WorkNumber
, p.State
, p.Sub_State
, p.CompanyID
, p.CompanyName
, ei.identity AS barcode

FROM

active_subs p

JOIN who_is_emp emp USING (current_person_center,current_person_id)

-- get person details for primary employee
JOIN persons pn
ON pn.center = emp.emp_center
AND pn.id = emp.emp_id

LEFT JOIN person_ext_attrs pea_email
        ON pea_email.personcenter = pn.current_person_center 
        AND pea_email.personid = pn.current_person_id 
        AND pea_email.name IN ('_eClub_Email')
LEFT JOIN person_ext_attrs pea_hphone
        ON pea_hphone.personcenter = pn.current_person_center 
        AND pea_hphone.personid = pn.current_person_id 
        AND pea_hphone.name IN ('_eClub_PhoneHome')
LEFT JOIN person_ext_attrs pea_wphone
        ON pea_wphone.personcenter = pn.current_person_center 
        AND pea_wphone.personid = pn.current_person_id 
        AND pea_wphone.name IN ('_eClub_PhoneWork')
LEFT JOIN person_ext_attrs pea_mphone
        ON pea_mphone.personcenter = pn.current_person_center 
        AND pea_mphone.personid = pn.current_person_id 
        AND pea_mphone.name IN ('_eClub_PhoneSMS')


LEFT JOIN entityidentifiers ei
ON ei.ref_center||'p'||ei.ref_id = p.MembersNumber
AND ei.ref_type = 1 -- Person
AND ei.idmethod = 1 -- Barcode
AND ei.entitystatus = 1 -- OK
