-- This is the version from 2026-02-05
--  
Select
cc.PERSONCENTER ||'p'|| cc.PERSONID,
eclub2.longToDate(cc.START_DATETIME) as Cash_Collection_start,
eclub2.longToDate(cc.CLOSED_DATETIME) as Cash_Collection_start,
ccj.step

from
CASHCOLLECTIONCASES cc


where
cc.CLOSED_DATETIME between :starttime and :endtime

AND cc.START_DATETIME is datetolong(TO_CHAR(cc.CLOSED_DATETIME-30,'yyyy-mm-dd') || ' 00:00') 
