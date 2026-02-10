-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    par.CENTER || 'par' || par.ID "BOOKINGID",
    p.EXTERNAL_ID "PERSONID",
    par.BOOKING_CENTER || 'book' || par.BOOKING_ID "BOOKINGPRODUCTID",
    par.STATE "Status",
    to_char(longToDateC(par.START_TIME,par.center),'YYYY-MM-dd HH24:MI') "BOOKINGSTART",
    to_char(longToDateC(par.STOP_TIME,par.center),'YYYY-MM-dd HH24:MI') "BOOKINGEND",
    to_char(longToDateC(par.CREATION_TIME,par.center),'YYYY-MM-dd HH24:MI') "BOOKINGDATE",
    DECODE(par.USER_INTERFACE_TYPE, 0,'OTHER', 1,'CLIENT',2,'WEB',3,'KIOSK',4,'SCRIPT','UNKNOWN') "BOOKINGMETHOD",
    0 "INDUCTION",
    0 "FIRSTMEETING"
FROM
    PARTICIPATIONS par
JOIN PERSONS oldP
ON
    oldP.CENTER = par.PARTICIPANT_CENTER
    AND oldP.ID = par.PARTICIPANT_ID
JOIN PERSONS p
ON
    p.CENTER = oldP.CURRENT_PERSON_CENTER
    AND p.ID = oldP.CURRENT_PERSON_ID
	and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')