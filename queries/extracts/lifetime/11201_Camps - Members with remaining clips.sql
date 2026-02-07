--ST-16433
SELECT DISTINCT
    t.person_center || 'p' || t.person_id AS "Person Number",
    t."Parent_external_id",
    t."Parent_name"
FROM
    (
        SELECT
            cc.*,
            il.*,
            p.external_id                                     AS "Parent_external_id",
            p.fullname                                        AS "Parent_name",
            longtodatec(cc.valid_from, cc.invoiceline_center)    AS "CC Valid From",
            longtodatec(cc.valid_until, cc.invoiceline_center)   AS "CC Valid Until",
            longtodatec(cc.last_modified, cc.invoiceline_center) AS "CC Last Modified"
													

        FROM
            clipcards cc,
            invoice_lines_mt il,
            persons p
        WHERE
            cc.invoiceline_center = il.center
        AND cc.invoiceline_id=il.id
        AND il.text LIKE '%Camp%'
        AND clips_left > 0
        AND il.person_center = p.center
        AND il.person_id = p.id
        ORDER BY
            valid_from DESC ) t