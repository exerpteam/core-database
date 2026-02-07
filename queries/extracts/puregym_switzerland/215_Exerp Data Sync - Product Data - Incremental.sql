WITH
    any_club_in_scope AS
    (
        SELECT
            id
        FROM
            (
                SELECT
                    id,
                    row_number() over () AS rownum
                FROM
                    centers
                WHERE
                    id IN ($$scope$$) ) x
        WHERE
            rownum =1
    )
     , params AS
     (
         SELECT
             /*+ materialize  */
             datetolongC(TO_CHAR(date_trunc('day', CURRENT_TIMESTAMP)-INTERVAL '5 days', 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS FROMDATE,
             datetolongC(TO_CHAR(date_trunc('day', CURRENT_TIMESTAMP+ INTERVAL '1 days'), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE
         FROM any_club_in_scope
     )
 SELECT
     pr.center || 'prod' || pr.id          AS "PRODUCTID",
     pr.NAME                               AS "NAME",
     replace(replace(pr.GLOBALID, chr(10), ''), chr(13), '') AS "GLOBALID",
     pr.external_id                        AS "PRODUCTEXTERNALID",
     TO_CHAR(longtodatetz(pr.LAST_MODIFIED,'Europe/Zurich'),'YYYY-MM-DD HH24:MI:SS') AS "LASTMODIFIEDDATE",
     TO_CHAR(pr.PRICE, 'FM999999990.00') as price
 FROM
     PRODUCTS pr
 CROSS JOIN PARAMS
 WHERE
     pr.CENTER in ($$scope$$)
     AND pr.LAST_MODIFIED >= PARAMS.FROMDATE
     AND pr.LAST_MODIFIED < PARAMS.TODATE

