SELECT
    s.owner_center || 'p' || s.owner_id AS PersonId,
    s.center || 'ss' || s.id            AS SubscriptionId,
    DECODE(s.STATE,2,'ACTIVE',3,'ENDED',4,'FROZEN',7,'WINDOW',8,'CREATED','Undefined') AS SUBSTATE,
    s.start_date,
    s.end_date
   
    From
    subscriptions s
 join licenses l
 on s.owner_center=l.center_id 
    WHERE s.state !=3 and l.FEATURE = 'clubLead' and l.stop_date is not NULL 