-- This is the version from 2026-02-05
--  
SELECT (pg.id)::character varying(255) AS "PRODUCT_GROUP_ID", pg.name AS "NAME", pg.external_id AS "EXTERNAL_ID", (pg.parent_product_group_id)::character varying(255) AS "PARENT_PRODUCT_GROUP_ID", (pg.dimension_product_group_id)::character varying(255) AS "DIMENSION_PRODUCT_GROUP_ID" FROM product_group pg WHERE (pg.top_node_id IS NULL) 