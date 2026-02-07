WITH vevents AS
(
  SELECT -1 eventid, 'All' eventtype FROM DUAL UNION
  SELECT 0 eventid, ' Reminder student documentation' eventtype FROM DUAL UNION
  SELECT 1 eventid, ' Reminder friend documentation' eventtype FROM DUAL UNION
  SELECT 2 eventid, ' Reminder corporate documentation' eventtype FROM DUAL UNION
  SELECT 3 eventid, ' Reminder family documentation' eventtype FROM DUAL UNION
  SELECT 4 eventid, ' Reminder senior documentation' eventtype FROM DUAL UNION
  SELECT 5 eventid, ' Expired student documentation' eventtype FROM DUAL UNION
  SELECT 6 eventid, ' Expired friend documentation' eventtype FROM DUAL UNION
  SELECT 7 eventid, ' Expired corporate documentation' eventtype FROM DUAL UNION
  SELECT 8 eventid, ' Expired family documentation' eventtype FROM DUAL UNION
  SELECT 9 eventid, ' Expired senior documentation' eventtype FROM DUAL UNION
  SELECT 10 eventid, ' Staff to customer' eventtype FROM DUAL UNION
  SELECT 11 eventid, ' Cash subscription renewal reminder' eventtype FROM DUAL UNION
  SELECT 12 eventid, ' Subscription price change' eventtype FROM DUAL UNION
  SELECT 15 eventid, ' Send password' eventtype FROM DUAL UNION
  SELECT 16 eventid, ' Started paying by EFT for other person' eventtype FROM DUAL UNION
  SELECT 17 eventid, ' Stop paying for other person by eft' eventtype FROM DUAL UNION
  SELECT 19 eventid, ' Debt collection reminder' eventtype FROM DUAL UNION
  SELECT 20 eventid, ' Debt collection notification' eventtype FROM DUAL UNION
  SELECT 21 eventid, ' Debt collection request remaining and stop' eventtype FROM DUAL UNION
  SELECT 22 eventid, ' Todo completed' eventtype FROM DUAL UNION
  SELECT 23 eventid, ' Web sales' eventtype FROM DUAL UNION
  SELECT 24 eventid, ' Debt collection block' eventtype FROM DUAL UNION
  SELECT 25 eventid, ' Newsletter' eventtype FROM DUAL UNION
  SELECT 26 eventid, ' Web sales subscription contract' eventtype FROM DUAL UNION
  SELECT 27 eventid, ' Web create customer' eventtype FROM DUAL UNION
  SELECT 28 eventid, ' Sanction service product punishment' eventtype FROM DUAL UNION
  SELECT 29 eventid, ' Sanction day block punishment' eventtype FROM DUAL UNION
  SELECT 30 eventid, ' Sanction clip punishment' eventtype FROM DUAL UNION
  SELECT 31 eventid, ' Sanction booking restriction punishment' eventtype FROM DUAL UNION
  SELECT 32 eventid, ' Sanction service product warning' eventtype FROM DUAL UNION
  SELECT 33 eventid, ' Sanction day block warning' eventtype FROM DUAL UNION
  SELECT 34 eventid, ' Sanction clip warning' eventtype FROM DUAL UNION
  SELECT 35 eventid, ' Sanction booking restriction warning' eventtype FROM DUAL UNION
  SELECT 36 eventid, ' Participation cancellation by staff' eventtype FROM DUAL UNION
  SELECT 37 eventid, ' Participation moved up' eventtype FROM DUAL UNION
  SELECT 38 eventid, ' Subscription sale' eventtype FROM DUAL UNION
  SELECT 39 eventid, ' Staff cancelation' eventtype FROM DUAL UNION
  SELECT 40 eventid, ' Participation creation' eventtype FROM DUAL UNION
  SELECT 41 eventid, ' Participation move' eventtype FROM DUAL UNION
  SELECT 42 eventid, ' Booking reminder court' eventtype FROM DUAL UNION
  SELECT 43 eventid, ' Booking reminder staff' eventtype FROM DUAL UNION
  SELECT 44 eventid, ' Booking reminder class' eventtype FROM DUAL UNION
  SELECT 45 eventid, ' Participation confirmation class' eventtype FROM DUAL UNION
  SELECT 46 eventid, ' Participation confirmation court' eventtype FROM DUAL UNION
  SELECT 47 eventid, ' Participation confirmation staff' eventtype FROM DUAL UNION
  SELECT 48 eventid, ' Freeze creation' eventtype FROM DUAL UNION
  SELECT 49 eventid, ' Freeze end' eventtype FROM DUAL UNION
  SELECT 50 eventid, ' Subscription termination' eventtype FROM DUAL UNION
  SELECT 51 eventid, ' Birthday' eventtype FROM DUAL UNION
  SELECT 52 eventid, ' Password expiration warning' eventtype FROM DUAL UNION
  SELECT 53 eventid, ' Payment request notification' eventtype FROM DUAL UNION
  SELECT 54 eventid, ' Advanced agreement notification' eventtype FROM DUAL UNION
  SELECT 55 eventid, ' Todo assigned' eventtype FROM DUAL UNION
  SELECT 56 eventid, ' Participation confirmation child care' eventtype FROM DUAL UNION
  SELECT 57 eventid, ' Participation cancellation by member' eventtype FROM DUAL UNION
  SELECT 58 eventid, ' Booking staff change' eventtype FROM DUAL UNION
  SELECT 59 eventid, ' Booking staff change for staff' eventtype FROM DUAL UNION
  SELECT 60 eventid, ' Todo deleted' eventtype FROM DUAL UNION
  SELECT 61 eventid, ' Payment agreement creation' eventtype FROM DUAL UNION
  SELECT 62 eventid, ' Credit card agreement finish online' eventtype FROM DUAL UNION
  SELECT 63 eventid, ' Check-in' eventtype FROM DUAL UNION
  SELECT 64 eventid, ' Attend' eventtype FROM DUAL UNION
  SELECT 65 eventid, ' Person created' eventtype FROM DUAL UNION
  SELECT 66 eventid, ' Person details changed' eventtype FROM DUAL UNION
  SELECT 67 eventid, ' Person state changed' eventtype FROM DUAL UNION
  SELECT 68 eventid, ' Person transferred' eventtype FROM DUAL UNION
  SELECT 69 eventid, ' Company details changed' eventtype FROM DUAL UNION
  SELECT 70 eventid, ' Company agreement details changed' eventtype FROM DUAL UNION
  SELECT 71 eventid, ' Participation state changed' eventtype FROM DUAL UNION
  SELECT 72 eventid, ' EFT agreement finish externally' eventtype FROM DUAL UNION
  SELECT 73 eventid, ' Booking created' eventtype FROM DUAL UNION
  SELECT 74 eventid, ' Booking cancelled' eventtype FROM DUAL UNION
  SELECT 75 eventid, ' Booking changed' eventtype FROM DUAL UNION
  SELECT 76 eventid, ' Payment agreement expiration warning' eventtype FROM DUAL UNION
  SELECT 77 eventid, ' Lead Online Sales Discontinued' eventtype FROM DUAL UNION
  SELECT 78 eventid, ' Product sale' eventtype FROM DUAL UNION
  SELECT 79 eventid, ' Credit Product sale' eventtype FROM DUAL UNION
  SELECT 80 eventid, ' Calendar Failure' eventtype FROM DUAL UNION
  SELECT 81 eventid, ' Create task' eventtype FROM DUAL UNION
  SELECT 82 eventid, ' Extended attribute changed' eventtype FROM DUAL UNION
  SELECT 83 eventid, ' New active members' eventtype FROM DUAL UNION
  SELECT 84 eventid, ' Member card assigned' eventtype FROM DUAL UNION
  SELECT 85 eventid, ' Member card blocked' eventtype FROM DUAL UNION
  SELECT 86 eventid, ' Member card unblocked' eventtype FROM DUAL UNION
  SELECT 88 eventid, ' Questionnaire answered' eventtype FROM DUAL UNION
  SELECT 89 eventid, ' Journal note created' eventtype FROM DUAL UNION
  SELECT 90 eventid, ' Suspension status changed' eventtype FROM DUAL UNION
  SELECT 91 eventid, ' Subscription changed' eventtype FROM DUAL UNION
  SELECT 92 eventid, ' Clipcard sold' eventtype FROM DUAL UNION
  SELECT 93 eventid, ' Clipcard clips adjusted' eventtype FROM DUAL UNION
  SELECT 94 eventid, ' Add-on started' eventtype FROM DUAL UNION
  SELECT 95 eventid, ' Add-on stopped' eventtype FROM DUAL UNION
  SELECT 96 eventid, ' Advance notice of direct debit' eventtype FROM DUAL UNION
  SELECT 97 eventid, ' SQL Event Job' eventtype FROM DUAL UNION
  SELECT 98 eventid, ' Payment agreement created' eventtype FROM DUAL UNION
  SELECT 99 eventid, ' Reject Reason Codes' eventtype FROM DUAL UNION
  SELECT 100 eventid, ' Task action performed' eventtype FROM DUAL UNION
  SELECT 101 eventid, ' Failed payment request notification' eventtype FROM DUAL UNION
  SELECT 102 eventid, ' Task change (for assignee)' eventtype FROM DUAL UNION
  SELECT 103 eventid, ' Task transition manually   SELECTed' eventtype FROM DUAL UNION
  SELECT 104 eventid, ' Subscription Cancelled' eventtype FROM DUAL UNION
  SELECT 105 eventid, ' Lead created' eventtype FROM DUAL UNION
  SELECT 106 eventid, ' Participation reminder' eventtype FROM DUAL UNION
  SELECT 107 eventid, ' Participation cancellation' eventtype FROM DUAL UNION
  SELECT 108 eventid, ' Person state duration' eventtype FROM DUAL UNION
  SELECT 109 eventid, ' Payment request delivery' eventtype FROM DUAL UNION
  SELECT 110 eventid, ' Paid state changed' eventtype FROM DUAL UNION
  SELECT 111 eventid, ' Paid state inactivity period' eventtype FROM DUAL UNION
  SELECT 112 eventid, ' Paid state total' eventtype FROM DUAL UNION
  SELECT 113 eventid, ' Person transferred and subscription changed' eventtype FROM DUAL UNION
  SELECT 114 eventid, ' Send password token' eventtype FROM DUAL UNION
  SELECT 115 eventid, ' Subscription state changed' eventtype FROM DUAL UNION
  SELECT 116 eventid, ' Custom subscription price change' eventtype FROM DUAL UNION
  SELECT 117 eventid, ' Participation seat changed' eventtype FROM DUAL UNION
  SELECT 118 eventid, ' Health certificate expiration' eventtype FROM DUAL UNION
  SELECT 119 eventid, ' Notificér før automatisk stop ved bindings periode udløb' eventtype FROM DUAL UNION
  SELECT 120 eventid, ' Attend failure' eventtype FROM DUAL UNION
  SELECT 121 eventid, ' Payment request notification with invoice' eventtype FROM DUAL UNION
  SELECT 122 eventid, ' Participation activity changed' eventtype FROM DUAL UNION
  SELECT 123 eventid, ' Controller offline' eventtype FROM DUAL UNION
  SELECT 124 eventid, ' Controller back online' eventtype FROM DUAL UNION
  SELECT 125 eventid, ' Controller stopped' eventtype FROM DUAL UNION
  SELECT 126 eventid, ' Clipcard out of clips' eventtype FROM DUAL 
)
, v0 AS
(
SELECT decode($$extractlevel$$, 0, NULL, centers.id) id
     , decode($$extractlevel$$, 0, 'Scope', centers.name) name
     , to_char(exerpro.longtodateTZ(messages.senttime, 'Europe/London'), 'YYYY-MM-DD') senttime 
     , vevents.eventtype     
     , 1 totalgenerated
     , decode(deliverymethod, 5, 1, 0) totalletter
     , decode(deliverymethod, 5, decode(deliverycode, 8, 1, 0), 0) successletter
     , decode(deliverymethod, 5, decode(deliverycode, 9, 1, 0), 0) failedletter
     , decode(deliverymethod, 5, decode(deliverycode, 7, 1, 0), 0) cxlletter
     , decode(deliverymethod, 5, decode(deliverycode, 0, 1, 0), 0) unsentletter     
     , decode(deliverymethod, 5, decode(deliverycode, 8, 0, 9, 0, 7, 0, 0, 0, 1), 0) otherletter     
     , decode(deliverymethod, 1, 1, 0) totalemail
     , decode(deliverymethod, 1, decode(deliverycode, 2, 1, 0), 0) successemail
     , decode(deliverymethod, 1, decode(deliverycode, 9, 1, 0), 0) failedemail
     , decode(deliverymethod, 1, decode(deliverycode, 7, 1, 0), 0) cxlemail
     , decode(deliverymethod, 1, decode(deliverycode, 0, 1, 0), 0) unsentemail        
     , decode(deliverymethod, 1, decode(deliverycode, 2, 0, 9, 0, 7, 0, 0, 0, 1), 0) otheremail
     , decode(deliverymethod, 2, 1, 0) totalsms
     , decode(deliverymethod, 2, decode(deliverycode, 6, 1, 0), 0) successsms
     , decode(deliverymethod, 2, decode(deliverycode, 9, 1, 0), 0) failedsms
     , decode(deliverymethod, 2, decode(deliverycode, 7, 1, 0), 0) cxlsms
     , decode(deliverymethod, 2, decode(deliverycode, 0, 1, 0), 0) unsentsms     
     , decode(deliverymethod, 2, decode(deliverycode, 6, 0, 9, 0, 7, 0, 0, 0, 1), 0) othersms              
  FROM messages
    JOIN centers    
      ON messages.center = centers.id
     AND centers.id in ($$scope$$)
     AND messages.senttime >= $$startdate$$
     AND messages.senttime < $$enddate$$ + (86400 * 1000)   
     AND messages.deliverymethod in (1, 2, 5)  
     AND (:eventtype = -1 OR messages.message_type_id = :eventtype)       
    JOIN vevents
      ON messages.message_type_id = vevents.eventid   
)
SELECT  v0.id                  AS "Club Id"
      , v0.name                AS "Club Name"
      , v0.senttime            AS "Created Date"
      , v0.eventtype           AS "Subject"
      , sum(v0.totalgenerated) AS "Total generated"
      , sum(v0.totalletter)    AS "Total letter"
      , sum(v0.successletter)  AS "Letter delivered"      
      , sum(v0.unsentletter)   AS "Letter undelivered"        
      , sum(v0.cxlletter)      AS "Letter cancelled"
      , sum(v0.failedletter)   AS "Letter failed"
      , sum(v0.otherletter)    AS "Letter Others"     
      , sum(v0.totalemail)     AS "Total email"
      , sum(v0.successemail)   AS "Email delivered"      
      , sum(v0.unsentemail)    AS "Email undelivered"        
      , sum(v0.cxlemail)       AS "Email cancelled"
      , sum(v0.failedemail)    AS "Email failed"
      , sum(v0.otheremail)     AS "Email Others"        
      , sum(v0.totalsms)       AS "Total SMS"
      , sum(v0.successsms)     AS "SMS delivered"      
      , sum(v0.unsentsms)      AS "SMS undelivered"        
      , sum(v0.cxlsms)         AS "SMS cancelled"
      , sum(v0.failedsms)      AS "SMS failed"
      , sum(v0.othersms)       AS "SMS Others"   
FROM
      v0
GROUP BY 
        v0.id             
      , v0.name           
      , v0.senttime       
      , v0.eventtype      
ORDER BY 1, 2, 3, 4 