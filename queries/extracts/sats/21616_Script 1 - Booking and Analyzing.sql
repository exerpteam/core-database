SELECT
    COUNT(br.center) cnt,
    DECODE(br.USER_INTERFACE_TYPE, 0,'OTHER', 1,'CLIENT',2,'WEB',3,'KIOSK',4,'SCRIPT','UNKNOWN') AS USER_INTERFACE_TYPE,
    TO_CHAR(longtodate(br.START_TIME),'YYYY') YEAR,
    TO_CHAR(longtodate(br.START_TIME),'IW') week
FROM
    BOOKING_RESTRICTIONS br
where 
br.center in(:scope) and 
br.START_TIME between :restrictionStart and :restrictionEnd
GROUP BY
    br.USER_INTERFACE_TYPE,
    TO_CHAR(longtodate(br.START_TIME),'YYYY'),
    TO_CHAR(longtodate(br.START_TIME),'IW')
order by 3,4