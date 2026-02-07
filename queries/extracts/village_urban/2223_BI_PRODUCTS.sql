 SELECT
     biview.*
 FROM
     (
      SELECT ((p.center || 'prod'::text) || p.id) AS "PRODUCT_ID",
    (p.center)::character varying(255) AS "PRODUCT_CENTER",
    (mp.id)::character varying(255) AS "MASTER_PRODUCT_ID",
    (p.primary_product_group_id)::character varying(255) AS "PRODUCT_GROUP_ID",
    p.name AS "NAME",
    bi_decode_field('PRODUCTS'::character varying, 'PTYPE'::character varying, p.ptype) AS "PRODUCT_TYPE",
    p.external_id AS "EXTERNAL_ID",
    p.price AS "SALES_PRICE",
    p.min_price AS "MINIMUM_PRICE",
    p.cost_price AS "COST_PRICE",
        CASE
            WHEN (p.blocked = 0) THEN 'FALSE'::text
            WHEN (p.blocked = 1) THEN 'TRUE'::text
            ELSE NULL::text
        END AS "BLOCKED",
    p.sales_commission AS "SALES_COMMISSION",
    p.sales_units AS "SALES_UNITS",
    p.period_commission AS "PERIOD_COMMISSION",
        CASE
            WHEN ((max(pg.exclude_from_member_count) = 0) AND (p.ptype = 10)) THEN 'TRUE'::text
            ELSE 'FALSE'::text
        END AS "INCLUDED_MEMBER_COUNT",
    p.center AS "CENTER_ID",
    p.last_modified AS "ETS",
    p.flat_rate_commission AS "FLAT_RATE_COMMISSION"
   FROM (((products p
     LEFT JOIN masterproductregister mp ON (((mp.id = mp.definition_key) AND ((p.globalid)::text = (mp.globalid)::text))))
     LEFT JOIN product_and_product_group_link ppgl ON (((ppgl.product_center = p.center) AND (ppgl.product_id = p.id))))
     LEFT JOIN product_group pg ON ((pg.id = ppgl.product_group_id)))
  WHERE (p.ptype <> ALL (ARRAY[5, 6, 7, 12]))
  GROUP BY ((p.center || 'prod'::text) || p.id), p.center, mp.id, p.primary_product_group_id, p.name, p.ptype, p.external_id, p.price, p.min_price, p.cost_price,
        CASE
            WHEN (p.blocked = 0) THEN 'FALSE'::text
            WHEN (p.blocked = 1) THEN 'TRUE'::text
            ELSE NULL::text
        END, p.sales_commission, p.sales_units, p.period_commission, p.last_modified, p.flat_rate_commission
UNION ALL
 SELECT ((p.center || 'prod'::text) || p.id) AS "PRODUCT_ID",
    (p.center)::character varying(255) AS "PRODUCT_CENTER",
    (mp.id)::character varying(255) AS "MASTER_PRODUCT_ID",
    (p.primary_product_group_id)::character varying(255) AS "PRODUCT_GROUP_ID",
    p.name AS "NAME",
    bi_decode_field('PRODUCTS'::character varying, 'PTYPE'::character varying, p.ptype) AS "PRODUCT_TYPE",
    spr.external_id AS "EXTERNAL_ID",
    p.price AS "SALES_PRICE",
    p.min_price AS "MINIMUM_PRICE",
    p.cost_price AS "COST_PRICE",
        CASE
            WHEN (p.blocked = 0) THEN 'FALSE'::text
            WHEN (p.blocked = 1) THEN 'TRUE'::text
            ELSE NULL::text
        END AS "BLOCKED",
    p.sales_commission AS "SALES_COMMISSION",
    p.sales_units AS "SALES_UNITS",
    p.period_commission AS "PERIOD_COMMISSION",
    'FALSE'::text AS "INCLUDED_MEMBER_COUNT",
    p.center AS "CENTER_ID",
    p.last_modified AS "ETS",
    p.flat_rate_commission AS "FLAT_RATE_COMMISSION"
   FROM (((products p
     LEFT JOIN subscriptiontypes st ON (((st.productnew_center = p.center) AND (st.productnew_id = p.id))))
     LEFT JOIN products spr ON (((spr.center = st.center) AND (spr.id = st.id))))
     LEFT JOIN masterproductregister mp ON (((mp.id = mp.definition_key) AND ((spr.globalid)::text = (mp.globalid)::text))))
  WHERE (p.ptype = 5)
UNION ALL
 SELECT ((p.center || 'prod'::text) || p.id) AS "PRODUCT_ID",
    (p.center)::character varying(255) AS "PRODUCT_CENTER",
    (mp.id)::character varying(255) AS "MASTER_PRODUCT_ID",
    (p.primary_product_group_id)::character varying(255) AS "PRODUCT_GROUP_ID",
    p.name AS "NAME",
    bi_decode_field('PRODUCTS'::character varying, 'PTYPE'::character varying, p.ptype) AS "PRODUCT_TYPE",
    spr.external_id AS "EXTERNAL_ID",
    p.price AS "SALES_PRICE",
    p.min_price AS "MINIMUM_PRICE",
    p.cost_price AS "COST_PRICE",
        CASE
            WHEN (p.blocked = 0) THEN 'FALSE'::text
            WHEN (p.blocked = 1) THEN 'TRUE'::text
            ELSE NULL::text
        END AS "BLOCKED",
    p.sales_commission AS "SALES_COMMISSION",
    p.sales_units AS "SALES_UNITS",
    p.period_commission AS "PERIOD_COMMISSION",
    'FALSE'::text AS "INCLUDED_MEMBER_COUNT",
    p.center AS "CENTER_ID",
    p.last_modified AS "ETS",
    p.flat_rate_commission AS "FLAT_RATE_COMMISSION"
   FROM (((products p
     LEFT JOIN subscriptiontypes st ON (((st.freezeperiodproduct_center = p.center) AND (st.freezeperiodproduct_id = p.id))))
     LEFT JOIN products spr ON (((spr.center = st.center) AND (spr.id = st.id))))
     LEFT JOIN masterproductregister mp ON (((mp.id = mp.definition_key) AND ((spr.globalid)::text = (mp.globalid)::text))))
  WHERE (p.ptype = 7)
UNION ALL
 SELECT ((p.center || 'prod'::text) || p.id) AS "PRODUCT_ID",
    (p.center)::character varying(255) AS "PRODUCT_CENTER",
    (mp.id)::character varying(255) AS "MASTER_PRODUCT_ID",
    (p.primary_product_group_id)::character varying(255) AS "PRODUCT_GROUP_ID",
    p.name AS "NAME",
    bi_decode_field('PRODUCTS'::character varying, 'PTYPE'::character varying, p.ptype) AS "PRODUCT_TYPE",
    spr.external_id AS "EXTERNAL_ID",
    p.price AS "SALES_PRICE",
    p.min_price AS "MINIMUM_PRICE",
    p.cost_price AS "COST_PRICE",
        CASE
            WHEN (p.blocked = 0) THEN 'FALSE'::text
            WHEN (p.blocked = 1) THEN 'TRUE'::text
            ELSE NULL::text
        END AS "BLOCKED",
    p.sales_commission AS "SALES_COMMISSION",
    p.sales_units AS "SALES_UNITS",
    p.period_commission AS "PERIOD_COMMISSION",
    'FALSE'::text AS "INCLUDED_MEMBER_COUNT",
    p.center AS "CENTER_ID",
    p.last_modified AS "ETS",
    p.flat_rate_commission AS "FLAT_RATE_COMMISSION"
   FROM (((products p
     LEFT JOIN subscriptiontypes st ON (((st.prorataproduct_center = p.center) AND (st.prorataproduct_id = p.id))))
     LEFT JOIN products spr ON (((spr.center = st.center) AND (spr.id = st.id))))
     LEFT JOIN masterproductregister mp ON (((mp.id = mp.definition_key) AND ((spr.globalid)::text = (mp.globalid)::text))))
  WHERE (p.ptype = 12)
UNION ALL
 SELECT ((p.center || 'prod'::text) || p.id) AS "PRODUCT_ID",
    (p.center)::character varying(255) AS "PRODUCT_CENTER",
    (mp.id)::character varying(255) AS "MASTER_PRODUCT_ID",
    (p.primary_product_group_id)::character varying(255) AS "PRODUCT_GROUP_ID",
    p.name AS "NAME",
    bi_decode_field('PRODUCTS'::character varying, 'PTYPE'::character varying, p.ptype) AS "PRODUCT_TYPE",
    spr.external_id AS "EXTERNAL_ID",
    p.price AS "SALES_PRICE",
    p.min_price AS "MINIMUM_PRICE",
    p.cost_price AS "COST_PRICE",
        CASE
            WHEN (p.blocked = 0) THEN 'FALSE'::text
            WHEN (p.blocked = 1) THEN 'TRUE'::text
            ELSE NULL::text
        END AS "BLOCKED",
    p.sales_commission AS "SALES_COMMISSION",
    p.sales_units AS "SALES_UNITS",
    p.period_commission AS "PERIOD_COMMISSION",
    'FALSE'::text AS "INCLUDED_MEMBER_COUNT",
    p.center AS "CENTER_ID",
    p.last_modified AS "ETS",
    p.flat_rate_commission AS "FLAT_RATE_COMMISSION"
   FROM (((products p
     LEFT JOIN subscriptiontypes st ON (((st.transferproduct_center = p.center) AND (st.transferproduct_id = p.id))))
     LEFT JOIN products spr ON (((spr.center = st.center) AND (spr.id = st.id))))
     LEFT JOIN masterproductregister mp ON (((mp.id = mp.definition_key) AND ((spr.globalid)::text = (mp.globalid)::text))))
  WHERE (p.ptype = 6)
     
     )
      biview
  WHERE
     biview."ETS" BETWEEN
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 
 UNION ALL
 SELECT
         NULL AS "PRODUCT_ID",
         NULL AS "PRODUCT_CENTER",
         NULL AS "MASTER_PRODUCT_ID",
         NULL AS "PRODUCT_GROUP_ID",
         NULL AS "NAME",
         NULL AS "PRODUCT_TYPE",
         NULL AS "EXTERNAL_ID",
         NULL AS "SALES_PRICE",
         NULL AS "MINIMUM_PRICE",
         NULL AS "COST_PRICE",
         NULL AS "BLOCKED",
         NULL AS "SALES_COMMISSION",
         NULL AS "SALES_UNITS",
         NULL AS "PERIOD_COMMISSION",
         NULL AS "INCLUDED_MEMBER_COUNT",
         NULL AS "CENTER_ID",
         NULL AS "ETS",
         NULL AS "FLAT_RATE_COMMISSION"