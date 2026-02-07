SELECT
    ei.identity,
    ei.ref_globalid,
    p.name
FROM
    entityidentifiers ei
JOIN
    products p
ON
    ei.REF_GLOBALID = p.globalid
WHERE
    ei.ref_type = :transScope
and p.center in (:scope)
ORDER BY
    ei.identity