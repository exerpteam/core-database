-- This is the version from 2026-02-05
--  
SELECT
    part.participant_center||'p'||part.participant_id as customer,
    book.name as class_booked,
    longtodate(part.START_TIME) as participated,
    pea_to.TXTVALUE as new_customerID
FROM
     fw.participations part
JOIN fw.BOOKINGS book
ON
    book.center=part.BOOKING_CENTER
    AND book.id=part.BOOKING_ID
JOIN fw.SUBSCRIPTIONS sub
    on sub.OWNER_CENTER = part.PARTICIPANT_CENTER
    and sub.OWNER_ID = part.PARTICIPANT_ID
JOIN fw.PRODUCTS pd
    ON
       pd.CENTER=sub.SUBSCRIPTIONTYPE_CENTER
        AND pd.id=sub.SUBSCRIPTIONTYPE_ID
        AND pd.GLOBALID='EVENT_GIRO_D_ITALIA'
JOIN FW.STATE_CHANGE_LOG scl 
    on 
        scl.CENTER = sub.center 
    and scl.id = sub.id and scl.ENTRY_TYPE = 2 
    and scl.BOOK_START_TIME <= part.START_TIME 
    and (scl.BOOK_END_TIME is null or scl.BOOK_END_TIME >= part.START_TIME)
    and scl.STATEID in (2,4)

left join fw.activity ac
    on
       book.activity = ac.id
     
left join fw.person_ext_attrs pea_to
  on
       part.PARTICIPANT_CENTER = pea_to.PERSONCENTER and part.PARTICIPANT_ID = pea_to.PERSONID
       and pea_to.name = '_eClub_TransferredToId'
WHERE
    part.START_TIME >= datetolong('2012-05-01 00:00')
-- and part.START_TIME < datetolong('2011-05-29 00:00')
AND part.STATE = 'PARTICIPATION'
AND
    (
        (book.NAME LIKE 'Giro% Italia - Bjergetape')
        OR
        (book.NAME LIKE 'Giro% Italia - Enkeltstart')
        OR
        (book.NAME LIKE 'Giro% Italia - Sprinteretape')
        OR
        (ac.activity_group_id = 2) -- ='BODYBIKE'
    )
--AND part.PARTICIPANT_CENTER = 150 and part.PARTICIPANT_ID = 22676
ORDER BY
    part.participant_center,
    part.participant_id