-- The extract is extracted from Exerp on 2026-02-08
-- Works for any value not 0 or 0.00 or empty. Validated 1 June 25. Dont get for 1 club only...always by region.
WITH
    latest_coa_sale AS
    (
        SELECT
            ptrans.CURRENT_PERSON_CENTER,
            ptrans.CURRENT_PERSON_ID,
            MAX(i.TRANS_TIME) AS TRANS_TIME
        FROM
            HP.INVOICELINES il
        JOIN
            HP.INVOICES i
        ON
            i.center = il.center
            AND i.id = il.id
        JOIN
            HP.PRODUCTS pd
        ON
            pd.CENTER = il.productCENTER
            AND pd.ID = il.productid
        JOIN
            HP.PERSONS ptrans
        ON
            il.PERSON_CENTER = ptrans.center
            AND il.person_id = ptrans.id
        WHERE (
            pd.GLOBALID = 'BODYSCAN_SUBSCRIPTION_6'
	OR	pd.GLOBALID IN('COA','BODY_SCAN_FEE'))
            AND ptrans.CURRENT_PERSON_CENTER IN ( $$Scope$$ )
        GROUP BY
            ptrans.CURRENT_PERSON_CENTER,
            ptrans.CURRENT_PERSON_ID
    )
SELECT
    /*+ NO_BIND_AWARE */
    *
FROM
    (
        SELECT
            dat.*,
            dat.center || 'p' || dat.id AS MemberId,
            (
                SELECT DISTINCT
                    floor(SUM(extract(YEAR FROM age(F_START, F_END)) * 12 + extract(MONTH FROM age (F_START, F_END)))) AS freeze_months
                FROM
                    (
                        SELECT
                            least(spp1.TO_DATE + 1, $$deduction_date$$)         AS F_START,
                            greatest(spp1.FROM_DATE, dat.LatestCOASale) AS F_END
                        FROM
                            HP.PERSONS p1
                        JOIN
                            HP.SUBSCRIPTIONS sub1
                        ON
                            sub1.OWNER_CENTER = p1.center
                            AND sub1.OWNER_ID = p1.id
                            AND sub1.REFMAIN_CENTER IS NULL
						
                        JOIN
                            hp.SUBSCRIPTIONTYPES st1
                        ON
                            st1.CENTER = sub1.SUBSCRIPTIONTYPE_CENTER
                            AND st1.id = sub1.SUBSCRIPTIONTYPE_ID
                            AND st1.ST_TYPE = 1
                            AND st1.IS_ADDON_SUBSCRIPTION = False
						JOIN
							PRODUCTS spr1
						ON
							spr1.CENTER = sub1.SUBSCRIPTIONTYPE_CENTER
							AND spr1.id = sub1.SUBSCRIPTIONTYPE_ID
                        JOIN
                            HP.SUBSCRIPTIONPERIODPARTS spp1
                        ON
                            spp1.CENTER = sub1.center
                            AND spp1.id = sub1.id
                            AND spp1.SPP_STATE = 1
                            AND spp1.SPP_TYPE IN (2,7)
                        WHERE
                            spp1.TO_DATE >= dat.LatestCOASale
                            AND p1.CURRENT_PERSON_CENTER = dat.CENTER
                            AND p1.CURRENT_PERSON_ID = dat.id )subq) freeze_months,
            (
                SELECT
                    1
                FROM
                    HP.SUBSCRIPTIONS cc_sub
                JOIN
                    SUBSCRIPTIONTYPES cc_st
                ON
                    cc_st.CENTER = cc_sub.SUBSCRIPTIONTYPE_CENTER
                    AND cc_st.id = cc_sub.SUBSCRIPTIONTYPE_ID
                    AND cc_st.ST_TYPE = 2
                JOIN
                    PRODUCT_AND_PRODUCT_GROUP_LINK cc_ppgl
                ON
                    cc_ppgl.PRODUCT_CENTER = cc_sub.SUBSCRIPTIONTYPE_CENTER
                    AND cc_ppgl.PRODUCT_ID = cc_sub.SUBSCRIPTIONTYPE_ID
                JOIN
                    product_group cc_pg
                ON
                    cc_pg.id = cc_ppgl.PRODUCT_GROUP_ID
                    AND cc_pg .name = 'NOSALEAPPLYSTEP'
                WHERE
                    cc_sub.OWNER_CENTER = dat.center
                    AND cc_sub.OWNER_ID = dat.id
                    AND (
                    cc_sub.END_DATE IS NULL
                    OR  (
                    cc_sub.end_date >= $$deduction_date$$))
                    AND cc_sub.state IN (2,4,8) limit 1 ) AS HAS_REC_CC,
CAST($$deduction_date$$ AS DATE) deduction_date
        FROM
            (
                SELECT DISTINCT
                    p.center,
                    p.id,                      
					p.center ||'p'|| p.id    AS	 PersonID,
                    p.center                     AS CenterId,
                    p.fullname                   AS fullname,
					spr1.NAME  					AS Membership,
					sub.start_date 				AS SubStart,
					sub.binding_end_date		AS BindingEnd,
					sub.subscription_price	AS	MembershipPrice,
                    pea_email.txtvalue           AS email ,
                    pea_coaching_date.txtvalue   AS CO_DATE,
                    bsamount.txtvalue   AS CHARGE_BS_FEE ,
					pea_osd.txtvalue AS OSD,
                    MIN(
                        CASE
                            WHEN (ces.LASTUPDATED IS NULL
                                    OR sub.creation_time >= (COALESCE(datetolong(TO_CHAR (ces.LASTUPDATED, 'YYYY-MM-DD HH24:MI')), 1) + 24*60*60000))
                            THEN add_months(sub.START_DATE, 1)
                            ELSE to_date('2000-01-01', 'YYYY-MM-DD')
                        END)                                       earliest_newsub_deduction_date ,
                    longtodate(MAX(latest_coa_sale.TRANS_TIME)) AS LatestCOASale
                FROM
                    HP.PERSONS p
                JOIN
                    HP.SUBSCRIPTIONS sub
                ON
                    sub.OWNER_CENTER = p.center
                    AND sub.OWNER_ID = p.id
                    AND (
                        sub.END_DATE IS NULL
                        OR (
                            sub.end_date >= $$deduction_date$$))
                    AND sub.REFMAIN_CENTER IS NULL
                    AND sub.state IN (2,4,8)
                    AND sub.START_DATE <= $$deduction_date$$
                JOIN
                    hp.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
                    AND st.id = sub.SUBSCRIPTIONTYPE_ID
                    AND st.ST_TYPE = 1
                    AND st.IS_ADDON_SUBSCRIPTION = 0

			
				JOIN
					PRODUCTS spr1
				ON
					spr1.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
					AND spr1.id = sub.SUBSCRIPTIONTYPE_ID

				
                JOIN
                    hp.SUBSCRIPTION_PRICE sp
                ON
                    sp.SUBSCRIPTION_CENTER = sub.center
                    AND sp.SUBSCRIPTION_ID = sub.id
                    AND sp.FROM_DATE <= $$deduction_date$$
                    AND sp.CANCELLED = 0
                    AND (
                        sp.TO_DATE IS NULL
                        OR sp.TO_DATE >= $$deduction_date$$ )
                LEFT JOIN
                    PERSON_EXT_ATTRS pea_email
                ON
                    pea_email.PERSONCENTER = p.center
                    AND pea_email.PERSONID = p.id
                    AND pea_email.NAME = '_eClub_Email'
                
                LEFT JOIN
                    HP.PERSON_EXT_ATTRS pea_coaching_date
                ON
                    pea_coaching_date.PERSONCENTER = p.center
                    AND pea_coaching_date.PERSONID = p.id
                    AND pea_coaching_date.name = 'BODYSCANFEEDATE'
			
                LEFT JOIN
                    HP.CONVERTER_ENTITY_STATE ces
                ON
                    ces.NEWENTITYCENTER = p.center
                    AND ces.NEWENTITYID = p.id
                    AND ces.WRITERNAME = 'ClubLeadSubscriptionWriter'
                
		LEFT JOIN
                    HP.PERSON_EXT_ATTRS bsamount
                ON
                    bsamount.PERSONCENTER = p.center
                    AND bsamount.PERSONID = p.id
                    AND bsamount.name = 'CHARGEBSDE'

		LEFT JOIN
                    HP.PERSON_EXT_ATTRS pea_osd
                ON
                    pea_osd.PERSONCENTER = p.center
                    AND pea_osd.PERSONID = p.id
                    AND pea_osd.name = 'OriginalStartDate'			

                LEFT JOIN
                    HP.RELATIVES rel
                ON
                    rel.RELATIVECENTER = p.center
                    AND rel.RELATIVEID = p.id
                    AND rel.RTYPE = 12
                    AND rel.STATUS < 3
                LEFT JOIN
                    HP.SUBSCRIPTION_FREEZE_PERIOD csfp
                ON
                    csfp.SUBSCRIPTION_CENTER = sub.CENTER
                    AND csfp.SUBSCRIPTION_ID = sub.ID
                    AND csfp.STATE = 'ACTIVE'
                    AND csfp.START_DATE <= $$deduction_date$$
                    AND csfp.END_DATE >= $$deduction_date$$
                LEFT JOIN
                    latest_coa_sale
                ON
                    latest_coa_sale.CURRENT_PERSON_CENTER = COALESCE(rel.center, p.center)
                    AND latest_coa_sale.CURRENT_PERSON_ID = COALESCE(rel.id,p.id)
                    --                ON
                    --                    ( (
                    --                            rel.center IS NULL
                    --                            AND latest_coa_sale.CURRENT_PERSON_CENTER = p.center
                    --                            AND latest_coa_sale.CURRENT_PERSON_ID = p.id)
                    --                        OR (
                    --                            rel.center IS NOT NULL
                    --                            AND latest_coa_sale.CURRENT_PERSON_CENTER = rel.center
                    --                            AND latest_coa_sale.CURRENT_PERSON_ID = rel.id) )
                WHERE
                    p.center IN ( $$Scope$$ )
                    AND p.PERSONTYPE NOT IN (2)
					---taken out sub price > 0
                    AND csfp.id IS NULL -- exclude members on freeze on deduction date
--exclude members with free memberhips
	            AND NOT EXISTS
            (
                SELECT  1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppg
                WHERE
                    ppg.product_center = sub.SUBSCRIPTIONTYPE_CENTER
                    AND ppg.product_id = sub.SUBSCRIPTIONTYPE_ID
                    AND ppg.PRODUCT_GROUP_ID = (1201) )


                    /*AND NOT EXISTS -- exclude members with recurring clipcard subscription in
                    group
                    -- NOSALEAPPLYSTEP
                    (
                    SELECT
                    1
                    FROM
                    HP.SUBSCRIPTIONS cc_sub
                    JOIN
                    SUBSCRIPTIONTYPES cc_st
                    ON
                    cc_st.CENTER = cc_sub.SUBSCRIPTIONTYPE_CENTER
                    AND cc_st.id = cc_sub.SUBSCRIPTIONTYPE_ID
                    AND cc_st.ST_TYPE = 2
                    JOIN
                    PRODUCT_AND_PRODUCT_GROUP_LINK cc_ppgl
                    ON
                    cc_ppgl.PRODUCT_CENTER = cc_sub.SUBSCRIPTIONTYPE_CENTER
                    AND cc_ppgl.PRODUCT_ID = cc_sub.SUBSCRIPTIONTYPE_ID
                    JOIN
                    product_group cc_pg
                    ON
                    cc_pg.id = cc_ppgl.PRODUCT_GROUP_ID
                    AND cc_pg .name = 'NOSALEAPPLYSTEP'
                    WHERE
                    cc_sub.OWNER_CENTER = p.center
                    AND cc_sub.OWNER_ID = p.id
                    AND (
                    cc_sub.END_DATE IS NULL
                    OR  (
                    cc_sub.end_date >= $$deduction_date$$))
                    AND cc_sub.state IN (2,4,8)
                    AND cc_sub.START_DATE <= $$deduction_date$$ )*/
                GROUP BY
                    p.center,
                    p.id,
                    p.center,
					bsamount.txtvalue,
					pea_osd.txtvalue,	
                    p.fullname,
					spr1.name,
					sub.binding_end_date,
					sub.start_date,
					sub.subscription_price,
                    pea_coaching_date.txtvalue,
                    
                    pea_email.txtvalue ) dat ) dat2
					
WHERE
    (CHARGE_BS_FEE IS NOT NULL AND CHARGE_BS_FEE NOT IN ('0','0.00'))
    AND earliest_newsub_deduction_date <= $$deduction_date$$
    AND (
        LatestCOASale IS NULL
        OR dat2.LatestCOASale + interval '6 month' <= $$deduction_date$$)