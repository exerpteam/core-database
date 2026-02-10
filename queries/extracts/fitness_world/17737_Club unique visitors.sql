-- The extract is extracted from Exerp on 2026-02-08
-- Unique visitor count by club in the last 180 days
select ci.CHECKIN_CENTER as Center, count (distinct ci.PERSON_CENTER || 'p' || ci.PERSON_ID) as UniqueVisitor from FW.CHECKINS ci
where ci.CHECKIN_TIME > datetolong(to_char(exerpsysdate() - 180, 'YYYY-MM-DD HH24:MM'))
group by ci.CHECKIN_CENTER
having ci.CHECKIN_CENTER != 100
order by 1