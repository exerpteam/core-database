-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     pr.center || 'prod' || pr.id          AS "PRODUCTID",
     pr.NAME                               AS "NAME",
     replace(replace(pr.GLOBALID, chr(10), ''), chr(13), '') AS "GLOBALID",
     pr.external_id                        AS "PRODUCTEXTERNALID",
     TO_CHAR(longtodatetz(pr.LAST_MODIFIED,'Europe/Zurich'),'YYYY-MM-DD HH24:MI:SS') AS "LASTMODIFIEDDATE",
     TO_CHAR(pr.PRICE, 'FM999999990.00') as price
 FROM
     PRODUCTS pr
 WHERE
     pr.CENTER in ($$scope$$)

