SELECT
    pr.center || 'prod' || pr.id          AS "PRODUCTID",	
    pr.NAME                               AS "NAME",
    replace(replace(pr.GLOBALID, chr(10), ''), chr(13), '') AS "GLOBALID",	
    pr.external_id                        AS "PRODUCTEXTERNALID",
    TO_CHAR(longtodatetz(pr.LAST_MODIFIED,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "LASTMODIFIEDDATE",
    pr.PRICE
FROM
    PRODUCTS pr
WHERE
    pr.center in ($$scope$$)