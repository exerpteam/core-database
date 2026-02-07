SELECT
    p.CENTER||'p'||p.ID as customer,
    p.fullname,
    e.identity as RF_number,
    DECODE(e.entitystatus,1,'OK',2,'Stolen',
3,'Missing',4,'Blocked',5,'Broken',6,'Returned') AS Card_STATUS,
    pro.name,
    pro.globalid
FROM
     eclub2.persons p
join eclub2.subscriptions sub
  ON 
     p.center = sub.owner_center
     and p.id = sub.owner_id
join eclub2.subscriptiontypes st
  on
     sub.subscriptiontype_center = st.center
     and sub.subscriptiontype_id = st.id
join eclub2.products pro
  on
     st.center = pro.center
     and st.id = pro.id
JOIN eclub2.entityidentifiers e
  ON
    e.REF_CENTER = p.center
    AND e.REF_ID = p.id
WHERE
    e.IDMETHOD = 4  -- RFID_CARD 
AND e.REF_TYPE = 1  -- Person
and p.center in (:scope)
and pro.globalid in ('YOUTH LOCAL TT EFT', 'YOUTH_LOCAL_TT_CASH')