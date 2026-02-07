 SELECT
     TO_CHAR(longtodateTZ(bok.starttime, 'Europe/Rome'),'Day') "Booking Day" ,
     TO_CHAR(longtodateTZ(bok.starttime, 'Europe/Rome'),'DD Mon YYYY') "Booking Date" ,
     TO_CHAR(longtodateTZ(bok.starttime, 'Europe/Rome'),'HH24:MI') || '-' || TO_CHAR(longtodateTZ
     (bok.stoptime, 'Europe/Rome'),'HH24:MI')"Booking Time" ,
     bok.name "Booking Name" ,
     per.FIRSTNAME ||' '||per.lastname "Booking Staff" ,
     per1.FIRSTNAME ||' '||per1.lastname "Booking Participant",
     par.PARTICIPANT_CENTER||'p'||par.PARTICIPANT_ID "Participant ID",
     bok.description "Booking Description",
     bok.state "Booking  State",
     bok.CANCELLATION_REASON "Booking Cancellation Reason",
     bok.center "Booking Center" ,
     prd.name "Clip card product name",
     prd.center || 'c' || prd.id "Clip card product ID",
     TO_CHAR(longtodateTZ(inv.entry_time, 'Europe/Rome'),'DD Mon YYYY  HH24:MI')
     "Clip card sale time",
     inl.total_amount "Clip Card cost" ,
     par.state "Participation Status" ,
     pru.misuse_state "Misuse state"
 FROM
     bookings bok
 JOIN
     participations par
 ON
     par.booking_id = bok.id
 AND par.booking_center = bok.center
 JOIN
     persons per1
 ON
     per1. id = par.participant_id
 AND per1.center = par.participant_center
 JOIN
     STAFF_USAGE su
 ON
     su.BOOKING_CENTER = bok.center
 AND su.BOOKING_ID = bok.id
 join persons per
 on su.person_center=per.center and su.person_id =per.id
 JOIN
     privilege_usages pru
 ON
     pru.target_center = par.center
 AND pru.target_id = par.id
 AND pru.target_service ='Participation'
 JOIN
     activity act
 ON
     bok.activity = act.id
 JOIN
     activity_group acg
 ON
     act.activity_group_id = acg.id
 JOIN
     clipcards clc
 ON
     pru.source_id = clc.id
 AND pru.source_center = clc.center
 AND pru.source_subid = clc.subid
 LEFT JOIN
     CLIPCARDTYPES cct
 ON
     cct.center = clc.CENTER
 AND cct.ID = clc.ID
 JOIN
     PRODUCTS prd
 ON
     prd.CENTER = cct.CENTER
 AND prd.ID = cct.ID
 LEFT JOIN
     INVOICE_LINES_mt inl
 ON
     clc.INVOICELINE_CENTER = inl.CENTER
 AND clc.INVOICELINE_ID = inl.ID
 AND clc.INVOICELINE_SUBID = inl.SUBID
 JOIN
     invoices inv
 ON
     inv.center = inl.center
 AND inv.id = inl.id
 WHERE
 bok.starttime BETWEEN $$from_date$$ AND $$to_date$$
 and bok.center in ($$scope$$)
 and acg.id = 7001
