 SELECT
     sub.owner_center||'p'||sub.owner_id as customer,
     sub.saved_free_days as free_days,
     sub.saved_free_months as free_months,
 --    utl_raw.cast_to_varchar2(dbms_lob.substr(j.BIG_TEXT,1000)) as journal_text,
     j.creatorcenter||'emp'||j.creatorid as staff_awarding,
     longtodate(j.creation_time) as staff_time_change
 FROM
      pulse.subscriptions sub
 join pulse.journalentries j
   on
      sub.owner_center = j.person_center
      and sub.owner_id = j.person_id
      and j.jetype = 3
      and convert_from(j.BIG_TEXT, 'UTF-8') like 'The number of saved free days%'
 join pulse.persons per
         on
         sub.owner_center = per.center
         and sub.owner_id = per.id
 where
     (
         (sub.saved_free_days <> 0)
     OR
         (sub.saved_free_months is not null)
     )
     and sub.owner_center in (:scope)
         and per.status in (:person_status)
         and sub.state in (:subscription_status)
 order by
         sub.saved_free_days,
         sub.owner_center,
         sub.owner_id
 asc
