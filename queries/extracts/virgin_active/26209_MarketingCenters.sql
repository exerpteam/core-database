-- The extract is extracted from Exerp on 2026-02-08
--  
 ------------------------------- BI_CENTERS MODIFIED --------------------------------------------------------------
 SELECT
 "CENTER_ID",
 "EXTERNAL_ID",
 replace(replace(replace(replace(replace("NAME", CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS "NAME",
 replace(replace(replace(replace(replace("SHORTNAME",CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS "SHORTNAME",
 "STARTUP_DATE",
 "COUNTRY_CODE",
 "POSTAL_CODE",
 replace(replace(replace(replace(replace("ADDRESS1",CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS "ADDRESS1",
 replace(replace(replace(replace(replace("ADDRESS2",CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS "ADDRESS2",
 replace(replace(replace(replace(replace("ADDRESS3",CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS "ADDRESS3",
 "PHONE_NUMBER",
 replace(replace(replace(replace(replace("CITY",CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS "CITY",
 "LATITUDE",
 "LONGITUDE",
 "MIGRATION_DATE",
 "TIME_ZONE",
 "MANAGER_PERSON_ID",
 replace(replace(replace(replace(replace("COUNTY",CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS "COUNTY",
 replace(replace(replace(replace(replace("STATE", CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),'"','[qt]'), '''' , '') AS "STATE"
 FROM
     	( SELECT DISTINCT (c.id)::character varying(255) AS "CENTER_ID", c.external_id AS "EXTERNAL_ID", c.name AS "NAME", c.shortname AS "SHORTNAME", to_char((c.startupdate)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "STARTUP_DATE", c.country AS "COUNTRY_CODE", c.zipcode AS "POSTAL_CODE", c.address1 AS "ADDRESS1", c.address2 AS "ADDRESS2", c.address3 AS "ADDRESS3", c.phone_number AS "PHONE_NUMBER", c.city AS "CITY", (c.latitude)::character varying(255) AS "LATITUDE", (c.longitude)::character varying(255) AS "LONGITUDE", migrations.migration_date AS "MIGRATION_DATE", c.time_zone AS "TIME_ZONE", p.external_id AS "MANAGER_PERSON_ID", z.county AS "COUNTY", z.province AS "STATE" FROM (((centers c LEFT JOIN persons p ON (((p.center = c.manager_center) AND (p.id = c.manager_id)))) LEFT JOIN ( SELECT ces.newentitycenter, max(ces.lastupdated) AS migration_date FROM converter_entity_state ces GROUP BY ces.newentitycenter) migrations ON ((migrations.newentitycenter = c.id))) LEFT JOIN zipcodes z ON ((((z.country)::text = (c.country)::text) AND ((z.zipcode)::text = (c.zipcode)::text) AND ((z.city)::text = (c.city)::text)))) ) biview
