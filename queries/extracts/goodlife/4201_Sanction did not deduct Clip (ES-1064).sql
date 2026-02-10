-- The extract is extracted from Exerp on 2026-02-08
-- This extract is used to audit for Sanctions that did not deduct a Clipcard for a Booking No Show.
SELECT
    p.participant_center || 'p' || p.participant_id pid
  , p.center
  ,TO_CHAR(longtoDateC(p.start_time,p.center),'YYYY-MM-DD') start_time
  ,p.state
  ,p.cancelation_reason
  ,p.no_show_up_punish_state
  , act.name
  ,'->' priv_usage
  , pu.state
  ,pu.misuse_state
  ,pu.punishment_key
  ,trainer.center || 'emp' || trainer.id trainer_emp
FROM
    goodlife.participations p
JOIN
    goodlife.bookings book
ON
    book.center = p.booking_center
    AND book.id = p.booking_id
LEFT JOIN
    goodlife.staff_usage su
ON
    su.booking_center = book.center
    AND su.booking_id = book.id
LEFT JOIN
    goodlife.employees trainer
ON
    trainer.personcenter = su.person_center
    AND trainer.personid = su.person_id
JOIN
    goodlife.activity act
ON
    act.id = book.activity
LEFT JOIN
    goodlife.privilege_usages pu
ON
    pu.target_center = p.center
    AND pu.target_id = p.id
    AND pu.target_service = 'Participation'
WHERE
    p.cancelation_reason IN ('NO_SHOW'
                           ,'USER_CANCEL_LATE')