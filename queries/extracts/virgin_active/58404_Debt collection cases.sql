 SELECT distinct
    case cc.hold when 0 then 'no' when 1 then 'yes' end as "on pause?",
    c.name as clubname,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID as memberid,
   cc.STARTDATE,
  cc.amount as cc_amount,
     cc.CURRENTSTEP_DATE,
     cc.CURRENTSTEP,  Case cc.CURRENTSTEP_TYPE When 0 Then 'MESSAGE' When 1 Then 'REMINDER' When 2 Then 'BLOCK' When 3 Then 'REQUESTANDSTOP' When 4 Then 'CASHCOLLECTION' When 5 Then 'CLOSE' When 6 Then 'WAIT' When 7 Then 'REQUESTBUYOUTANDSTOP' When 8 Then 'PUSH' Else 'Undefined' End as currentstep_description,
 cc.NEXTSTEP_DATE,
 Case cc.NEXTSTEP_TYPE When 0 Then 'MESSAGE' When 1 Then 'REMINDER' When 2 Then 'BLOCK' When 3 Then 'REQUESTANDSTOP' When 4 Then 'CASHCOLLECTION' When 5 Then 'CLOSE' When 6 Then 'WAIT' When 7 Then 'REQUESTBUYOUTANDSTOP' When 8 Then 'PUSH' Else 'Undefined' END AS NEXSTEP_DESCRIPTION,
     longToDate(cc.CLOSED_DATETIME) as Closedate,
 s.end_date as "subscription end date"
 FROM
 CASHCOLLECTIONCASES cc
 JOIN
 ACCOUNT_RECEIVABLES ar on
         ar.CUSTOMERCENTER = cc.PERSONCENTER
         and ar.CUSTOMERID = cc.PERSONID
 JOIN
         PERSONS p on p.center= ar.CUSTOMERCENTER and p.id=ar.CUSTOMERID
 join
 subscriptions s
 on
 s.owner_center = p.center
 and
 s.owner_id = p.id
 join
 centers c
 on
 c.id = ar.CUSTOMERCENTER
 Where
    p.CENTER IN (:scope)
 and
 cc.closed = 0
 and
 cc.amount > 0
