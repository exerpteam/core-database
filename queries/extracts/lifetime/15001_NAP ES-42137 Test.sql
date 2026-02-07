SELECT
    p.external_id                                                             AS "EXTERNAL_ID"                                                     
FROM
    persons p
where p.center IN ($$scope$$)