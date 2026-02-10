-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS
     (
         SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH24:MI'
                    ) )
            END                                                                       AS FROMDATE,
            datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI') ) AS TODATE
     )
 SELECT
 "CENTER_ID",
 "CENTER_EA_NAME",
 "CENTER_EA_VALUE"
 FROM
     params,
     	( SELECT cea.id AS "ID", cea.center_id AS "CENTER_ID", cea.name AS "CENTER_EA_NAME", cea.txt_value AS "CENTER_EA_VALUE", cea.last_edit_time AS "ETS" FROM center_ext_attrs cea ) biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
         and biview."CENTER_ID" in ($$scope$$)

