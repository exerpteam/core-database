WITH
    params AS
    (
        SELECT
            /*+ materialize */
                  $$centerFrom$$ as centerFrom,
$$centerTo$$ as centerTo,      
           datetolongC(TO_CHAR($$from_date$$,'yyyy-MM-dd hh24:mi'),c.id) AS fromDate,
            datetolongC(TO_CHAR($$to_date$$,'yyyy-MM-dd hh24:mi'),c.id) + 24*3600*1000 AS toDate,
            c.id                                                 AS centerid
        FROM
            centers c
    )
SELECT
   per.center||'p' ||per.id  PersonId,
    Firstname,
    Lastname,
    SSN,
    c.Checkin_Center,
    TO_DATE('01-01-1970','dd-mm-yyyy ') + Checkin_Time /(24*3600*1000) + 2/24 AS CheckinTime,
    per.address1,
    per.address2,
    per.zipcode,
    z.city
FROM
    Checkins c
JOIN
    Persons per
ON
    c.person_center = per.Center
AND c.person_id = per.Id
JOIN
    zipcodes z
ON
    z.zipcode=per.zipcode
AND z.country =per.country
join params par
on par.centerid=c.checkin_center
WHERE
     c.checkin_Center >=$$centerFrom$$
AND  c.checkin_Center <=$$centerTo$$
AND c.CHECKIN_TIME BETWEEN  par.fromDate+$$starthour$$ and par.toDate+$$endhour$$


            
ORDER BY
    c.CHECKIN_TIME 