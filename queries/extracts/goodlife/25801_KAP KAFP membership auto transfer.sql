SELECT
        DISTINCT
        s.center || 'ss' || s.id AS "Subscription Key",
        p.center AS "Destination center id",
        p.center || 'p' || p.ID AS "Person ID",
        p.firstname AS "First name",
        p.lastname AS "Last name",
        c.name AS "Current home club name",
		TRUE AS "Keep Cash Prices",
		TRUE AS "Keep Pre-Authorized Payment Prices Inside Binding",
		TRUE AS "Keep Pre-Authorized Payment Prices Outside Binding",
		TRUE AS "Keep Subscription Add-On Prices",
		FALSE AS "Issue New Contract",
		TRUE AS "Override Product Availability",
		TRUE AS "Ignore System Properties To Recalculate Prices"
		
FROM 
        goodlife.persons p
        
JOIN goodlife.subscriptions s 
ON p.center = s.owner_center
AND p.id = s.owner_id

JOIN goodlife.subscriptiontypes st 
ON s.subscriptiontype_center = st.center 
AND s.subscriptiontype_id = st.id

JOIN goodlife.products pr 
ON st.center = pr.center 
AND st.id = pr.id

JOIN goodlife.product_and_product_group_link plink 
ON plink.product_center = pr.center 
AND plink.product_id = pr.ID

JOIN goodlife.centers c 
ON p.center = c.id

WHERE   
        plink.product_group_id = 4201
        AND p.persontype = 4
        AND s.center IN (:Scope)
        AND s.state IN (2,4,8)
        AND s.center IN (870,871,872,873,874,875,876,877,878,879)
        AND p.center NOT IN (870,871,872,873,874,875,876,877,878,879)
        AND EXISTS (    
                        SELECT
                                1
                        FROM
                                goodlife.subscriptions ind
                   
                        JOIN goodlife.product_and_product_group_link plink2 
                        ON plink2.product_center = ind.subscriptiontype_center 
                        AND plink2.product_id = ind.subscriptiontype_id
                        AND plink2.product_group_id = 9601 -- 'Configuration-Corporate Eligible for Auto-Transfer' Product Group
                                             
                        WHERE
                                p.center = ind.owner_center 
                                AND p.id = ind.owner_id
                       )
        AND
        ( 
                st.st_type = 0
                OR
                EXISTS ( -- Members whose main membership subscription is EFT and the subscription period start date is NOT 'today'
                        SELECT 
                                1
                        FROM goodlife.subscriptionperiodparts spp
                        WHERE
                                s.center = spp.center 
                                AND s.id = spp.id
                               AND ((s.renewal_policy_override IN (6,10)
                                    AND spp.to_date = CURRENT_DATE - INTERVAL '1 DAY')
                                    OR
                                    spp.from_date = current_date

                                 )                                                                                                                            
 AND spp.cancellation_time=0
                                     )                             
                        )                      