WITH 
ProductPriviledge 
AS
        (
                SELECT
                    pp.id                                               AS ID,
                    pp.privilege_set                                    AS PRIVILEGE_SET_ID,
                    pp.price_modification_name                          AS PRICE_MOD_TYPE,
                    pp.price_modification_amount                        AS PRICE_MOD_VALUE,
                    pp.disable_min_price                                AS DISABLE_MIN_PRICE,
                    pp.purchase_right                                   AS GRANT_PURCHASE,
                    CASE
                        WHEN (pp.ref_type = 'GLOBAL_PRODUCT') THEN 'MASTER_PRODUCT'
                        ELSE pp.ref_type
                    END                                                 AS REF_TYPE,
                    CASE
                        WHEN (pp.ref_type = 'GLOBAL_PRODUCT') THEN pp.mprid
                        ELSE pp.ref_id
                    END                                                 AS REF_ID,
                    CASE
                        WHEN (pp.ref_type = 'GLOBAL_PRODUCT')
                        THEN
                            CASE
                                WHEN (pp.ref_globalid ~~ 'CREATION_%') THEN 'JOINING_FEE' 
                                WHEN (pp.ref_globalid ~~ 'PRORATA_%') THEN 'SUBS_PRORATA' 
                                WHEN (pp.ref_globalid ~~ 'FREEZE_%') THEN 'FREEZE_PERIOD' 
                                ELSE bi_decode_field('PRODUCTS' , 'PTYPE' ,pp.mpr_cached_producttype)
                            END
                        ELSE NULL 
                    END                                                 AS PRODUCT_TYPE,
                    CASE
                        WHEN (pp.valid_for ~~ 'ASS[%') THEN 'ABSOLUTE'
                        WHEN (pp.valid_for = 'LSS') THEN 'LOCAL'
                        WHEN (pp.valid_for ~~ 'RSS[%') THEN 'RELATIVE'
                        WHEN (pp.valid_for ~~ 'AG[%') THEN 'FOLLOW_ACCESS_GROUP'
                        ELSE NULL
                    END                                                 AS APPLY_TYPE,
                    CASE
                        WHEN (pp.valid_for ~~ 'ASS[%')
                        THEN
                            CASE
                                WHEN ("substring"(pp.valid_for, 5, 1) = ANY (ARRAY['G', 'T'])) THEN 'GLOBAL'
                                WHEN ("substring"(pp.valid_for, 5, 1) = 'A') THEN 'AREA'
                                WHEN ("substring"(pp.valid_for, 5, 1) = 'C') THEN 'CENTER'
                                ELSE NULL
                            END
                        WHEN (pp.valid_for ~~ 'AG[%') THEN 'ACCESS_GROUP'
                        WHEN (pp.valid_for ~~ 'RSS[%') THEN 'AREA'
                        ELSE NULL
                    END                                                 AS APPLY_REF_TYPE,
                    (
                        CASE
                            WHEN (((pp.valid_for ~~ 'ASS[%') OR (pp.valid_for ~~ 'AG[%')) AND (NOT ("substring"(pp.valid_for, 5, 1) = ANY (ARRAY['G', 'T'])))) THEN btrim(pp.valid_for, 'ARSS[]GTC')
                            WHEN (pp.valid_for ~~ 'RSS[%') THEN "substring"(pp.valid_for, 5, ("position"(pp.valid_for, ',') - 5))
                            ELSE NULL
                        END)                                            AS APPLY_REF_ID
                FROM
                    (
                        SELECT DISTINCT
                            pp_1.id,
                            pp_1.privilege_set,
                            pp_1.valid_for,
                            pp_1.valid_from,
                            pp_1.valid_to,
                            pp_1.price_modification_name,
                            pp_1.price_modification_amount,
                            pp_1.price_modification_rounding,
                            pp_1.ref_type,
                            pp_1.ref_globalid,
                            pp_1.ref_center,
                            pp_1.ref_id,
                            pp_1.disable_min_price,
                            pp_1.purchase_right,
                            mpr.id                 AS mprid,
                            mpr.cached_producttype AS mpr_cached_producttype                            
                        FROM
                            (product_privileges pp_1
                        LEFT JOIN
                            masterproductregister mpr
                        ON
                            (((
                                        mpr.globalid = pp_1.ref_globalid)
                                AND (
                                        pp_1.ref_type = 'GLOBAL_PRODUCT')
                                AND (
                                        mpr.id = mpr.definition_key))))
                        WHERE
                            ((
                                    pp_1.valid_to IS NULL)
                            AND (((
                                            "left"(pp_1.ref_globalid, 9) <> 'CREATION_')
                                    AND (
                                            "left"(pp_1.ref_globalid, 8) <> 'PRORATA_')
                                    AND (
                                            "left"(pp_1.ref_globalid, 7) <> 'FREEZE_'))
                                OR  (
                                        pp_1.ref_globalid IS NULL)))
                        UNION ALL
                        SELECT DISTINCT
                            pp_1.id,
                            pp_1.privilege_set,
                            pp_1.valid_for,
                            pp_1.valid_from,
                            pp_1.valid_to,
                            pp_1.price_modification_name,
                            pp_1.price_modification_amount,
                            pp_1.price_modification_rounding,
                            pp_1.ref_type,
                            pp_1.ref_globalid,
                            pp_1.ref_center,
                            pp_1.ref_id,
                            pp_1.disable_min_price,
                            pp_1.purchase_right,
                            mpr.id                 AS mprid,
                            mpr.cached_producttype AS mpr_cached_producttype
                        FROM
                            ((((product_privileges pp_1
                        JOIN
                            products p
                        ON
                            ((
                                    p.globalid = pp_1.ref_globalid)))
                        JOIN
                            subscriptiontypes st
                        ON
                            (((
                                        st.prorataproduct_center = p.center)
                                AND (
                                        st.prorataproduct_id = p.id))))
                        JOIN
                            products spr
                        ON
                            (((
                                        spr.center = st.center)
                                AND (
                                        spr.id = st.id))))
                        JOIN
                            masterproductregister mpr
                        ON
                            (((
                                        mpr.id = mpr.definition_key)
                                AND (
                                        spr.globalid = mpr.globalid))))
                        WHERE
                            ((
                                    pp_1.valid_to IS NULL)
                            AND (
                                    "left"(pp_1.ref_globalid, 9) = 'CREATION_'))
                        UNION ALL
                        SELECT DISTINCT
                            pp_1.id,
                            pp_1.privilege_set,
                            pp_1.valid_for,
                            pp_1.valid_from,
                            pp_1.valid_to,
                            pp_1.price_modification_name,
                            pp_1.price_modification_amount,
                            pp_1.price_modification_rounding,
                            pp_1.ref_type,
                            pp_1.ref_globalid,
                            pp_1.ref_center,
                            pp_1.ref_id,
                            pp_1.disable_min_price,
                            pp_1.purchase_right,
                            mpr.id                 AS mprid,
                            mpr.cached_producttype AS mpr_cached_producttype
                        FROM
                            ((((product_privileges pp_1
                        JOIN
                            products p
                        ON
                            ((
                                    p.globalid = pp_1.ref_globalid)))
                        JOIN
                            subscriptiontypes st
                        ON
                            (((
                                        st.productnew_center = p.center)
                                AND (
                                        st.productnew_id = p.id))))
                        JOIN
                            products spr
                        ON
                            (((
                                        spr.center = st.center)
                                AND (
                                        spr.id = st.id))))
                        JOIN
                            masterproductregister mpr
                        ON
                            (((
                                        mpr.id = mpr.definition_key)
                                AND (
                                        spr.globalid = mpr.globalid))))
                        WHERE
                            ((
                                    pp_1.valid_to IS NULL)
                            AND (
                                    "left"(pp_1.ref_globalid, 8) = 'PRORATA_'))
                        UNION ALL
                        SELECT DISTINCT
                            pp_1.id,
                            pp_1.privilege_set,
                            pp_1.valid_for,
                            pp_1.valid_from,
                            pp_1.valid_to,
                            pp_1.price_modification_name,
                            pp_1.price_modification_amount,
                            pp_1.price_modification_rounding,
                            pp_1.ref_type,
                            pp_1.ref_globalid,
                            pp_1.ref_center,
                            pp_1.ref_id,
                            pp_1.disable_min_price,
                            pp_1.purchase_right,
                            mpr.id                 AS mprid,
                            mpr.cached_producttype AS mpr_cached_producttype
                        FROM
                            ((((product_privileges pp_1
                        JOIN
                            products p
                        ON
                            ((
                                    p.globalid = pp_1.ref_globalid)))
                        JOIN
                            subscriptiontypes st
                        ON
                            (((
                                        st.freezeperiodproduct_center = p.center)
                                AND (
                                        st.freezeperiodproduct_id = p.id))))
                        JOIN
                            products spr
                        ON
                            (((
                                        spr.center = st.center)
                                AND (
                                        spr.id = st.id))))
                        JOIN
                            masterproductregister mpr
                        ON
                            (((
                                        mpr.id = mpr.definition_key)
                                AND (
                                        spr.globalid = mpr.globalid))))
                        WHERE
                            ((
                                    pp_1.valid_to IS NULL)
                            AND (
                                    "left"(pp_1.ref_globalid, 7) = 'FREEZE_'))) pp
        ) 
 

SELECT DISTINCT    
        p.center||'p'||p.id AS "Company id"
        ,p.fullname AS "Company name"       
        ,CASE
                WHEN p.ssn LIKE 'SA-%' THEN ltrim(p.ssn,'SA-')
                WHEN p.ssn LIKE 'AE-%' THEN ltrim(p.ssn,'AE-') 
        END AS "Company CR"
        ,extbillingNo.txtvalue AS "Company VAT"
        ,empp.fullname AS "Created by"
        ,emppam.fullname AS "Key account manager"
        ,ppart.fullname AS "Parent company"
        ,relpart.txtvalue AS "Related party"
        ,CASE ctype.txtvalue
                WHEN 'PRIV' THEN 'Private'
                WHEN 'GOV' THEN 'Government'
                ELSE NULL
        END AS "Company type"
        ,CRExpiry.txtvalue AS "CR Expiry date"
        ,ar.debit_max AS "Credit limit"
        ,ch.name AS "Bank account"
        ,pcc.name AS "Payment terms"
        ,cp.center||'p'||cp.id||'rpt'||cp.subid AS "Agreement id"
        ,cp.name AS "Agreement name"
        ,cp.creation_date AS "Agreement creation date"
        ,CASE 
            WHEN cp.state = 0 THEN 'Under target' 
            WHEN cp.state = 1 THEN 'Active' 
            WHEN cp.state = 2 THEN 'Stop new' 
            WHEN cp.state = 3 THEN 'Old' 
            WHEN cp.state = 4 THEN 'Awaiting activation' 
            WHEN cp.state = 5 THEN 'Blocked' 
            WHEN cp.state = 6 THEN 'Deleted' 
        END AS "Company Agreement State"  
        ,CASE cp.blocked
                WHEN false THEN 'Not blocked'
                WHEN true THEN 'blocked'
        END AS "Agreement blocked status"
        ,cp.start_date AS "Agreement start date"
        ,cp.activation_date AS "Agreement active from"
        ,cp.stop_new_date AS "Agreement active to"
        ,CASE
                WHEN pg.sponsorship_name IS NULL THEN 'NONE'
                ELSE pg.sponsorship_name 
        END AS "Sponsorship"
        ,cp.terms AS "Terms"
        ,ps.name AS "Priviledge Set Name"
        ,mp.cached_productname AS "Product name"
        ,CASE
                WHEN pp.APPLY_REF_TYPE = 'CENTER' THEN cc.shortname
                WHEN pp.APPLY_REF_TYPE = 'AREA' THEN a.name
                ELSE pp.APPLY_REF_TYPE 
        END AS "Scope"
        ,CASE
                WHEN PRICE_MOD_TYPE = 'OVERRIDE' THEN pp.PRICE_MOD_VALUE 
                WHEN PRICE_MOD_TYPE = 'FREE' THEN 0
                WHEN PRICE_MOD_TYPE = 'PERCENTAGE_REBATE' THEN ROUND(COALESCE(prodc.price,proda.price,prodg.price) - (COALESCE(prodc.price,proda.price,prodg.price) * pp.PRICE_MOD_VALUE),2)
                WHEN PRICE_MOD_TYPE = 'FIXED_REBATE' THEN COALESCE(prodc.price,proda.price,prodg.price) - pp.PRICE_MOD_VALUE
                ELSE NULL
        END AS "Agreement price"
        ,COALESCE(prodc.price,proda.price,prodg.price) AS "Normal Price"       
FROM
        leejam.persons p
JOIN
        leejam.companyagreements cp
                ON cp.center = p.center
                AND cp.id = p.id
                --AND  cp.state NOT IN (2,3,6)
LEFT JOIN
        leejam.person_ext_attrs extbillingNo
                ON extbillingNo.personcenter = p.center
                AND extbillingNo.personid = p.id
                AND extbillingNo.name = '_eClub_BillingNumber'
JOIN
        leejam.privilege_grants pg
                ON pg.granter_center = cp.center
                AND pg.granter_id = cp.ID
                AND pg.granter_subid = cp.subID
                AND pg.sponsorship_name IS NOT NULL   
                --AND pg.sponsorship_name != 'NONE' 
                AND (pg.valid_to IS NULL OR pg.valid_to > datetolongC(TO_CHAR(CAST(current_date AS DATE), 'YYYY-MM-dd HH24:MI'),pg.granter_center))
LEFT JOIN
        leejam.privilege_sets ps
                ON ps.id = pg.privilege_set
LEFT JOIN
        ProductPriviledge pp
                ON pp.PRIVILEGE_SET_ID = ps.id
                AND PRODUCT_TYPE NOT IN ('JOINING_FEE','SUBS_PRORATA','FREEZE_PERIOD','SERVICE')               
LEFT JOIN
        leejam.centers cc
                ON cc.id = CAST(pp.APPLY_REF_ID AS INT)
                AND pp.APPLY_REF_TYPE = 'CENTER' 
LEFT JOIN
        leejam.areas a
                ON a.id = CAST(pp.APPLY_REF_ID AS INT)
                AND pp.APPLY_REF_TYPE = 'AREA'
LEFT JOIN
        leejam.area_centers ac
                ON ac.area = a.id                
LEFT JOIN
        leejam.masterproductregister mp
                ON mp.id = pp.REF_ID
                AND pp.REF_TYPE = 'MASTER_PRODUCT'
LEFT JOIN
        leejam.products prodc
                ON prodc.globalid = mp.globalid
                AND prodc.center = CAST(pp.APPLY_REF_ID AS INT)
                AND pp.APPLY_REF_TYPE = 'CENTER'  
LEFT JOIN
        leejam.products proda
                ON proda.globalid = mp.globalid
                AND proda.center = ac.center
                AND pp.APPLY_REF_TYPE = 'AREA'
LEFT JOIN
        leejam.products prodg
                ON prodg.globalid = mp.globalid

                AND pp.APPLY_REF_TYPE = 'GLOBAL'                                                                                                               
LEFT JOIN       
        leejam.relatives CreatedBy
                ON CreatedBy.center = p.center
                AND CreatedBy.id = p.id
                AND CreatedBy.rtype = 8
                AND CreatedBy.status = 1
                AND (CreatedBy.expiredate IS NULL OR CreatedBy.expiredate > Current_Date)
LEFT JOIN
        leejam.employees emp
                ON emp.center = CreatedBy.relativecenter
                AND emp.id = CreatedBy.relativeid
LEFT JOIN
        leejam.persons empp
                ON empp.center = emp.personcenter
                AND empp.id = emp.personid
LEFT JOIN
        leejam.relatives AccountMGR
                ON AccountMGR.center = p.center
                AND AccountMGR.id = p.id
                AND AccountMGR.rtype = 10
                AND AccountMGR.status = 1
                AND (AccountMGR.expiredate IS NULL OR AccountMGR.expiredate > Current_Date)
LEFT JOIN
        leejam.persons emppam
                ON emppam.center = AccountMGR.relativecenter
                AND emppam.id = AccountMGR.relativeid        
LEFT JOIN
        leejam.relatives part
                ON part.relativecenter = p.center
                AND part.relativeid = p.id
                AND part.rtype = 6 
                AND part.status = 1 
                AND (part.expiredate IS NULL OR part.expiredate > Current_Date)
LEFT JOIN
        leejam.persons ppart
                ON ppart.center = part.center
                AND ppart.id = part.id
                and ppart.persontype = 4    
LEFT JOIN
        leejam.person_ext_attrs relpart
                ON relpart.personcenter = p.center
                AND relpart.personid = p.id
                AND relpart.name = 'COMPREL'
LEFT JOIN
        leejam.person_ext_attrs ctype
                ON ctype.personcenter = p.center
                AND ctype.personid = p.id
                AND ctype.name = 'Type'  
LEFT JOIN
        leejam.account_receivables ar
                ON ar.customercenter = p.center
                AND ar.customerid = p.id
                AND ar.ar_type = 4 
LEFT JOIN
        leejam.payment_agreements pag
                ON ar.center = pag.center 
                AND ar.id = pag.id
                AND pag.active = true
LEFT JOIN 
        leejam.clearinghouses ch
                ON ch.id = pag.clearinghouse  
LEFT JOIN
        leejam.payment_cycle_config pcc
                ON pcc.id = pag.payment_cycle_config_id  
LEFT JOIN
        leejam.person_ext_attrs CRExpiry
                ON CRExpiry.personcenter = p.center
                AND CRExpiry.personid = p.id
                AND CRExpiry.name = 'CREXPIRY'                                                                                          
WHERE 
        p.persontype = 4
        AND
        p.center in (:Scope)
        AND
        cp.state in (:State)
        AND
        (
        cp.stop_new_date IS NULL
        OR
        cp.stop_new_date BETWEEN :Stopnewfrom AND :Stopnewto
        )
                     