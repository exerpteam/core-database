select distinct OLD_CARDS.ref_center "VAClubID", OLD_CARDS.ref_center || 'p' || OLD_CARDS.ref_id "MemberID", 
EI.IDENTITY "Current_Swipe", OLD_CARDS.IDENTITY "Old_Swipe",
cast(timestamp '1970-01-01 00:00:00' + numtodsinterval(SUBSTR(OLD_CARDS.STOP_TIME, 0, 10), 'second') as date) "End_Date"
from ENTITYIDENTIFIERS EI
inner join 
(select *  
from ENTITYIDENTIFIERS where REF_TYPE = 1
and ref_center in (405, 407) -- CTA clubs only
and ENTITYSTATUS <> 1) OLD_CARDS on EI.ref_center = OLD_CARDS.ref_center
 								and EI.ref_id = OLD_CARDS.ref_id
where EI.REF_TYPE = 1 -- Member card
and EI.ENTITYSTATUS = 1 -- Current card
order by OLD_CARDS.ref_center, 
cast(timestamp '1970-01-01 00:00:00' + numtodsinterval(SUBSTR(OLD_CARDS.STOP_TIME, 0, 10), 'second') as date)
