WITH
  params AS materialized
     (
         SELECT
             id   AS  center,
			CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')-interval '3' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS FROMDATE,
			CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')+interval '1' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS TODATE,
             'YYYY-MM-dd HH24:MI:SS' DATETIMEFORMAT,
             time_zone  AS       TZFORMAT
         FROM 
             centers 
     )
 SELECT
     pr.center || 'prod' || pr.id          AS "PRODUCTID",
     pr.NAME                               AS "NAME",
     replace(replace(pr.GLOBALID, chr(10), ''), chr(13), '') AS "GLOBALID",
     pr.external_id                        AS "PRODUCTEXTERNALID",
     TO_CHAR(longtodatetz(pr.LAST_MODIFIED,params.TZFORMAT),params.DATETIMEFORMAT) AS "LASTMODIFIEDDATE",
     pr.PRICE AS "PRICE"
 FROM
     PRODUCTS pr
 JOIN 
     PARAMS
 ON
     pr.center = params.center    
 WHERE
     pr.CENTER in ($$scope$$)
     AND pr.LAST_MODIFIED >= PARAMS.FROMDATE
     AND pr.LAST_MODIFIED < PARAMS.TODATE
UNION ALL
     SELECT 
        NULL AS "PRODUCTID",
        NULL AS "NAME",
        NULL AS "GLOBALID",
        NULL AS "PRODUCTEXTERNALID",
        NULL AS "LASTMODIFIEDDATE",
        NULL AS "PRICE"