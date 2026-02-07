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
 "COMPANY_ID",
 "HOME_CENTER_ID",
 "NAME",
 "COUNTRY_ID",
 "POSTAL_CODE",
 "CITY",
 "ACCOUNT_MANAGER_ID",
 "STATUS",
 "COUNTY",
 "STATE"
 FROM
     params,
     ( SELECT p.external_id AS "COMPANY_ID", (p.center)::character varying(255) AS "HOME_CENTER_ID", p.fullname AS "NAME", p.country AS "COUNTRY_ID", p.zipcode AS "POSTAL_CODE", p.city AS "CITY", account_manager.external_id AS "ACCOUNT_MANAGER_ID", CASE WHEN (p.status = 7) THEN 'DELETED'::text ELSE 'ACTIVE'::text END AS "STATUS", z.county AS "COUNTY", z.province AS "STATE", mother_comapny.external_id AS "PARENT_COMPANY_ID", p.ssn AS "COMPANY_EXTERNAL_ID", p.last_modified AS "ETS" FROM (((((persons p LEFT JOIN relatives rel ON (((rel.center = p.center) AND (rel.id = p.id) AND (rel.rtype = 10) AND (rel.status = 1)))) LEFT JOIN persons account_manager ON (((rel.relativecenter = account_manager.center) AND (rel.relativeid = account_manager.id)))) LEFT JOIN zipcodes z ON ((((z.country)::text = (p.country)::text) AND ((z.zipcode)::text = (p.zipcode)::text) AND ((z.city)::text = (p.city)::text)))) LEFT JOIN relatives mother_comapny_rel ON (((mother_comapny_rel.relativecenter = p.center) AND (mother_comapny_rel.relativeid = p.id) AND (mother_comapny_rel.rtype = 6) AND (mother_comapny_rel.status = 1)))) LEFT JOIN persons mother_comapny ON (((mother_comapny.center = mother_comapny_rel.center) AND (mother_comapny.id = mother_comapny_rel.id)))) WHERE ((p.sex)::text = 'C'::text) ) biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
         and biview."COUNTRY_ID" = 'GB'
