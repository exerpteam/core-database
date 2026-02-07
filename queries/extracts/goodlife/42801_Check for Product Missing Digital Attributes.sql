
SELECT   
        p1.center AS home_center,
        (CASE
                WHEN p1.external_id IS NULL THEN p1.center || 'p' || p1.id
                ELSE p1.external_id
        END) "External Person ID",
        (CASE p1.persontype
                WHEN 0 THEN 'PRIVATE'
                WHEN 1 THEN 'STUDENT'
                WHEN 2 THEN 'STAFF'
                WHEN 3 THEN 'FRIEND'
                WHEN 4 THEN 'CORPORATE'
                WHEN 5 THEN 'ONEMANCORPORATE'
                WHEN 6 THEN 'FAMILY'
                WHEN 7 THEN 'SENIOR'
                WHEN 8 THEN 'GUEST'
                WHEN 9 THEN 'CHILD'
                WHEN 10 THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
        END) AS "Current Person Type",
        (CASE p1.STATUS
                WHEN 0 THEN 'LEAD'
                WHEN 1 THEN 'ACTIVE'
                WHEN 2 THEN 'INACTIVE'
                WHEN 3 THEN 'TEMPORARYINACTIVE'
                WHEN 4 THEN 'TRANSFERRED'
                WHEN 5 THEN 'DUPLICATE'
                WHEN 6 THEN 'PROSPECT'
                WHEN 7 THEN 'DELETED'
                WHEN 8 THEN 'ANONYMIZED'
                WHEN 9 THEN 'CONTACT'
                ELSE 'Undefined'
        END) AS "Current Person State",
        (CASE
                WHEN p1.basicAtHome_attr_exerp IS NULL OR p1.basicAtHome_attr_exerp != p1.basicathomeworkouts_file THEN p1.basicathomeworkouts_file
                ELSE NULL
        END) AS basicAtHome_attr_shouldbe,
        (CASE
                WHEN p1.basicInClub_attr_exerp IS NULL OR p1.basicInClub_attr_exerp != p1.basicinclubworkouts_file THEN p1.basicinclubworkouts_file
                ELSE NULL
        END) AS basicInClub_attr_shouldbe,
        (CASE
                WHEN p1.basicOnDemand_attr_exerp IS NULL OR p1.basicOnDemand_attr_exerp != p1.basicondemandcontent_file THEN basicondemandcontent_file
                ELSE NULL
        END) AS basicOnDemand_attr_shouldbe,
        (CASE
                WHEN p1.basicTraining_attr_exerp IS NULL OR p1.basicTraining_attr_exerp != p1.basictrainingplans_file THEN basictrainingplans_file
                ELSE NULL
        END) AS basicTraining_attr_shouldbe,
        (CASE
                WHEN p1.fullAtHome_attr_exerp IS NULL OR p1.fullAtHome_attr_exerp != p1.fullathomeworkouts_file THEN fullathomeworkouts_file
                ELSE NULL
        END) AS fullAtHome_attr_shouldbe,
        (CASE
                WHEN p1.fullInClub_attr_exerp IS NULL OR p1.fullInClub_attr_exerp != p1.fullinclubworkouts_file THEN fullinclubworkouts_file
                ELSE NULL
        END) AS fullInClub_attr_shouldbe,
        (CASE
                WHEN p1.fullOnDemand_attr_exerp IS NULL OR p1.fullOnDemand_attr_exerp != p1.fullondemandcontent_file THEN fullondemandcontent_file
                ELSE NULL
        END) AS fullOnDemand_attr_shouldbe,
        (CASE
                WHEN p1.fullTraining_attr_exerp IS NULL OR p1.fullTraining_attr_exerp != p1.fulltrainingplans_file THEN fulltrainingplans_file
                ELSE NULL
        END) AS fullTraining_attr_shouldbe,
        (CASE
                WHEN p1.premiumTraining_attr_exerp IS NULL OR p1.premiumTraining_attr_exerp != p1.premiumtrainingplans_file THEN premiumtrainingplans_file
                ELSE NULL
        END) AS premiumTraining_attr_shouldbe,
         (CASE
                WHEN p1.teenFitness_attr_exerp IS NULL OR p1.teenFitness_attr_exerp != p1.teenfitnesscontent_file THEN teenfitnesscontent_file
                ELSE NULL
        END) AS teenFitness_attr_shouldbe
FROM
(
        SELECT
                t1.center,
                t1.id,
                t1.status,
                t1.persontype,
                t1.external_id,
                (CASE
                        WHEN basicAtHome.txtvalue IS NULL THEN false
                        WHEN UPPER(basicAtHome.txtvalue) = 'TRUE' THEN true 
                        WHEN UPPER(basicAtHome.txtvalue) = 'FALSE' THEN false
                        ELSE NULL
                END) AS basicAtHome_attr_exerp,     
                (CASE
                        WHEN basicInClub.txtvalue IS NULL THEN false
                        WHEN UPPER(basicInClub.txtvalue) = 'TRUE' THEN true
                        WHEN UPPER(basicInClub.txtvalue) = 'FALSE' THEN false                   
                        ELSE NULL
                END) AS basicInClub_attr_exerp, 
                (CASE
                        WHEN basicOnDemand.txtvalue IS NULL THEN false
                        WHEN UPPER(basicOnDemand.txtvalue) = 'TRUE' THEN true
                        WHEN UPPER(basicOnDemand.txtvalue) = 'FALSE' THEN false
                        ELSE NULL
                END) AS basicOnDemand_attr_exerp, 
                (CASE
                        WHEN basicTraining.txtvalue IS NULL THEN false
                        WHEN UPPER(basicTraining.txtvalue) = 'TRUE' THEN true
                        WHEN UPPER(basicTraining.txtvalue) = 'FALSE' THEN false
                        ELSE NULL
                END) AS basicTraining_attr_exerp, 
                (CASE
                        WHEN fullAtHome.txtvalue IS NULL THEN false
                        WHEN UPPER(fullAtHome.txtvalue) = 'TRUE' THEN true 
                        WHEN UPPER(fullAtHome.txtvalue) = 'FALSE' THEN false                    
                        ELSE NULL
                END) AS fullAtHome_attr_exerp, 
                (CASE
                        WHEN fullInClub.txtvalue IS NULL THEN false
                        WHEN UPPER(fullInClub.txtvalue) = 'TRUE' THEN true
                        WHEN UPPER(fullInClub.txtvalue) = 'FALSE' THEN false                       
                        ELSE NULL
                END) AS fullInClub_attr_exerp, 
                (CASE
                        WHEN fullOnDemand.txtvalue IS NULL THEN false
                        WHEN UPPER(fullOnDemand.txtvalue) = 'TRUE' THEN true 
                        WHEN UPPER(fullOnDemand.txtvalue) = 'FALSE' THEN false
                        ELSE NULL
                END) AS fullOnDemand_attr_exerp, 
                (CASE
                        WHEN fullTraining.txtvalue IS NULL THEN false
                        WHEN UPPER(fullTraining.txtvalue) = 'TRUE' THEN true 
                        WHEN UPPER(fullTraining.txtvalue) = 'FALSE' THEN false 
                        ELSE NULL
                END) AS fullTraining_attr_exerp, 
                (CASE
                        WHEN premiumTraining.txtvalue IS NULL THEN false                       
                        WHEN UPPER(premiumTraining.txtvalue) = 'TRUE' THEN true
                        WHEN UPPER(premiumTraining.txtvalue) = 'FALSE' THEN false 
                        ELSE NULL
                END) AS premiumTraining_attr_exerp,
                (CASE
                        WHEN teenFitness.txtvalue IS NULL THEN false                       
                        WHEN UPPER(teenFitness.txtvalue) = 'TRUE' THEN true
                        WHEN UPPER(teenFitness.txtvalue) = 'FALSE' THEN false 
                        ELSE NULL
                END) AS teenFitness_attr_exerp,
                t1.basicathomeworkouts AS basicathomeworkouts_file,
                t1.basicinclubworkouts AS basicinclubworkouts_file,
                t1.basicondemandcontent AS basicondemandcontent_file,
                t1.basictrainingplans AS basictrainingplans_file,
                t1.fullathomeworkouts AS fullathomeworkouts_file,
                t1.fullinclubworkouts AS fullinclubworkouts_file,
                t1.fullondemandcontent AS fullondemandcontent_file,
                t1.fulltrainingplans AS fulltrainingplans_file,
                t1.premiumtrainingplans AS premiumtrainingplans_file,
                t1.teenondemandcontent AS teenfitnesscontent_file
        FROM
        (
                SELECT
                        r1.center,
                        r1.id,
                        r1.status,
                        r1.persontype,
                        r1.external_id,
                        bool_or(r1.basicathomeworkouts) AS basicathomeworkouts,
                        bool_or(r1.basicinclubworkouts) AS basicinclubworkouts,
                        bool_or(r1.basicondemandcontent) AS basicondemandcontent,
                        bool_or(r1.basictrainingplans) AS basictrainingplans,
                        bool_or(r1.fullathomeworkouts) AS fullathomeworkouts,
                        bool_or(r1.fullinclubworkouts) AS fullinclubworkouts,
                        bool_or(r1.fullondemandcontent) AS fullondemandcontent,
                        bool_or(r1.fulltrainingplans) AS fulltrainingplans,
                        bool_or(r1.premiumtrainingplans) AS premiumtrainingplans,
                        bool_or(r1.teenondemandcontent) AS teenondemandcontent
                FROM
                (
                        SELECT 
                                p.center,
                                p.id,
                                p.status,
                                p.persontype, 
                                p.external_id,
                                (CASE
                                        WHEN s.state IN (4) THEN false
                                        ELSE sman.basicathomeworkouts
                                END) basicathomeworkouts,
                                (CASE
                                        WHEN s.state IN (4) THEN false
                                        ELSE sman.basicinclubworkouts
                                END) basicinclubworkouts,
                                (CASE
                                        WHEN s.state IN (4) THEN false
                                        ELSE sman.basicondemandcontent
                                END) basicondemandcontent,
                                (CASE
                                        WHEN s.state IN (4) THEN false
                                        ELSE sman.basictrainingplans
                                END) basictrainingplans,
                                (CASE
                                        WHEN s.state IN (4) THEN false
                                        ELSE sman.fullathomeworkouts
                                END) fullathomeworkouts,
                                (CASE
                                        WHEN s.state IN (4) THEN false
                                        ELSE sman.fullinclubworkouts
                                END) fullinclubworkouts,
                                (CASE
                                        WHEN s.state IN (4) THEN false
                                        ELSE sman.fullondemandcontent
                                END) fullondemandcontent,
                                (CASE
                                        WHEN s.state IN (4) THEN false
                                        ELSE sman.fulltrainingplans
                                END) fulltrainingplans,
                                (CASE
                                        WHEN s.state IN (4) THEN false
                                        ELSE sman.premiumtrainingplans
                                END) premiumtrainingplans,
                                (CASE
                                        WHEN s.state IN (4) THEN false
                                        ELSE sman.teenondemandcontent
                                END) teenondemandcontent   
                        FROM goodlife.subscriptions s
                        JOIN goodlife.persons p
                                ON p.center = s.owner_center
                                AND p.id = s.owner_id
                        JOIN goodlife.subscriptiontypes st 
                                ON s.subscriptiontype_center = st.center
                                AND s.subscriptiontype_id = st.id
                        JOIN goodlife.products pr
                                ON st.center = pr.center
                                AND st.id = pr.id
                        JOIN public.sync_member_attr_new sman
                                ON sman.globalproductid = pr.globalid
                        WHERE
                                p.persontype NOT IN (2) 
                                AND s.state IN (2,4) -- Active & Temporary Inactive
                                AND p.status NOT IN (4,5,7,8)
                                AND p.center IN (:Scope)
                        UNION ALL
                        SELECT 
                                p.center,
                                p.id,
                                p.status,
                                p.persontype, 
                                p.external_id,
                                true AS basicathomeworkouts,
                                true AS basicinclubworkouts,
                                true AS basicondemandcontent,
                                true AS basictrainingplans,
                                true AS fullathomeworkouts,
                                true AS fullinclubworkouts,
                                true AS fullondemandcontent,
                                true AS fulltrainingplans,
                                false AS premiumtrainingplans,
                                true AS teenondemandcontent
                                  
                        FROM goodlife.subscriptions s
                        JOIN goodlife.persons p
                                ON p.center = s.owner_center
                                AND p.id = s.owner_id
                        WHERE
                                p.persontype IN (2) 
                                --AND s.state IN (2,4) -- Active & Temporary Inactive
                                AND p.status NOT IN (4,5,7,8)
                                AND p.center IN (:Scope)
                ) r1
                GROUP BY 
                        r1.center,
                        r1.id,
                        r1.status,
                        r1.persontype,
                        r1.external_id
        ) t1
        LEFT JOIN goodlife.person_ext_attrs basicAtHome
                ON basicAtHome.personcenter = t1.center
                AND basicAtHome.personid = t1.id
                AND basicAtHome.name = 'DCABasicAtHomeWorkouts'
        LEFT JOIN goodlife.person_ext_attrs basicInClub
                ON basicInClub.personcenter = t1.center
                AND basicInClub.personid = t1.id
                AND basicInClub.name = 'DCABasicInClubWorkouts'
        LEFT JOIN goodlife.person_ext_attrs basicOnDemand
                ON basicOnDemand.personcenter = t1.center
                AND basicOnDemand.personid = t1.id
                AND basicOnDemand.name = 'DCABasicOnDemandContent'
        LEFT JOIN goodlife.person_ext_attrs basicTraining
                ON basicTraining.personcenter = t1.center
                AND basicTraining.personid = t1.id
                AND basicTraining.name = 'DCABasicTrainingPlans'
        LEFT JOIN goodlife.person_ext_attrs fullAtHome
                ON fullAtHome.personcenter = t1.center
                AND fullAtHome.personid = t1.id
                AND fullAtHome.name = 'DCAFullAtHomeWorkouts'
        LEFT JOIN goodlife.person_ext_attrs fullInClub
                ON fullInClub.personcenter = t1.center
                AND fullInClub.personid = t1.id
                AND fullInClub.name = 'DCAFullInClubWorkouts'
        LEFT JOIN goodlife.person_ext_attrs fullOnDemand
                ON fullOnDemand.personcenter = t1.center
                AND fullOnDemand.personid = t1.id
                AND fullOnDemand.name = 'DCAFullOnDemandContent'
        LEFT JOIN goodlife.person_ext_attrs fullTraining
                ON fullTraining.personcenter = t1.center
                AND fullTraining.personid = t1.id
                AND fullTraining.name = 'DCAFullTrainingPlans'
        LEFT JOIN goodlife.person_ext_attrs premiumTraining
                ON premiumTraining.personcenter = t1.center
                AND premiumTraining.personid = t1.id
                AND premiumTraining.name = 'DCAPremiumTrainingPlans'
        LEFT JOIN goodlife.person_ext_attrs teenFitness
                ON teenFitness.personcenter = t1.center
                AND teenFitness.personid = t1.id
                AND teenFitness.name = 'DCATeenFitness'
) p1
WHERE
        p1.basicAtHome_attr_exerp IS NULL OR p1.basicAtHome_attr_exerp != p1.basicathomeworkouts_file
        OR
        p1.basicInClub_attr_exerp IS NULL OR p1.basicInClub_attr_exerp != p1.basicinclubworkouts_file
        OR
        p1.basicOnDemand_attr_exerp IS NULL OR p1.basicOnDemand_attr_exerp != p1.basicondemandcontent_file
        OR
        p1.basicTraining_attr_exerp IS NULL OR p1.basicTraining_attr_exerp != p1.basictrainingplans_file
        OR
        p1.fullAtHome_attr_exerp IS NULL OR p1.fullAtHome_attr_exerp != p1.fullathomeworkouts_file
        OR
        p1.fullInClub_attr_exerp IS NULL OR p1.fullInClub_attr_exerp != p1.fullinclubworkouts_file
        OR
        p1.fullOnDemand_attr_exerp IS NULL OR p1.fullOnDemand_attr_exerp != p1.fullondemandcontent_file
        OR
        p1.fullTraining_attr_exerp IS NULL OR p1.fullTraining_attr_exerp != p1.fulltrainingplans_file
        OR
        p1.premiumTraining_attr_exerp IS NULL OR p1.premiumTraining_attr_exerp != p1.premiumtrainingplans_file
         OR
        p1.teenFitness_attr_exerp IS NULL OR p1.teenFitness_attr_exerp != p1.teenfitnesscontent_file