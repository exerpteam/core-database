WITH
     params AS 
     (
         SELECT 
            CAST($$startDate$$ AS BIGINT) AS start_date,
            CAST($$endDate$$ AS BIGINT) + 24*3600*1000 AS end_date
     ) , 
     table1 as
     (
     SELECT
                 p.CENTER,
                 p.ID,
                 p.FULLNAME,
                 p.PINCODE,
                 ch.CHECKIN_CENTER,
                 ch.CHECKIN_TIME,
                 ch.CHECKOUT_TIME,ch.id as chid
         FROM
                 params,
                 PERSONS p
         JOIN STATE_CHANGE_LOG stl ON p.CENTER = stl.CENTER AND p.ID = stl.ID AND stl.ENTRY_TYPE=3 AND stl.STATEID=4
         JOIN CHECKINS ch ON ch.PERSON_CENTER = p.CENTER AND ch.PERSON_ID = p.ID
         WHERE
                 ch.CHECKIN_TIME >= params.start_date
                 AND ch.CHECKIN_TIME < params.end_date
                 AND ch.CHECKIN_TIME > stl.ENTRY_START_TIME
                 AND (stl.ENTRY_END_TIME IS NULL OR ch.CHECKIN_TIME < stl.ENTRY_END_TIME)
         ) 
 SELECT
         company.FULLNAME as "Company name",
         c.NAME as "Visit Club name",
         to_char(longToDateTZ(table1.CHECKIN_TIME, 'Europe/London'), 'HH24:MI:SS') as "Visit Club Time",
         to_char(longToDateTZ(table1.CHECKIN_TIME, 'Europe/London'), 'YYYY-MM-DD') as "Visit Club Date",
         to_char(longToDateTZ(table1.CHECKOUT_TIME, 'Europe/London'), 'HH24:MI:SS') as "Checkout Time",
         to_char(longToDateTZ(table1.CHECKOUT_TIME, 'Europe/London'), 'YYYY-MM-DD') as "Checkout Date",
         homeclub.NAME as "Home Club name",
         table1.FULLNAME as "Member name",
         pin.IDENTITY as "Pin number",
table1.chid
 FROM
     table1
 LEFT JOIN RELATIVES comp_rel ON comp_rel.CENTER = table1.CENTER AND comp_rel.ID = table1.ID AND comp_rel.RTYPE = 3 --AND comp_rel.STATUS < 3
 LEFT JOIN PERSONS company on company.CENTER = comp_rel.RELATIVECENTER and company.ID = comp_rel.RELATIVEID
 JOIN CENTERS c ON c.ID = table1.CHECKIN_CENTER
 JOIN CENTERS homeclub ON homeclub.ID = table1.CENTER
 LEFT JOIN ENTITYIDENTIFIERS pin ON pin.REF_CENTER=table1.CENTER AND pin.REF_ID=table1.ID AND pin.IDMETHOD=5 and pin.ENTITYSTATUS = 1
 ORDER BY
         pin.IDENTITY,
         table1.CHECKIN_TIME
