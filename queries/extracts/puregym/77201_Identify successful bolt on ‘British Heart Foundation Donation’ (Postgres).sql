WITH
    params AS MATERIALIZED
    (
        SELECT
            CAST (dateToLongTZ(TO_CHAR(CAST(:fromDate AS DATE), 'YYYY-MM-dd HH24:MI'), 'Europe/London') AS BIGINT)                  AS StartDateLong,
            CAST((dateToLongTZ(TO_CHAR(CAST(:toDate AS DATE), 'YYYY-MM-dd HH24:MI'), 'Europe/London')+ 86400 * 1000)-1 AS BIGINT) AS EndDateLong
    )


Select
il.PERSON_CENTER ||'p'|| PERSON_id as personid,
il.text,
longtodate(i.ENTRY_TIME) as entrytime,
il.total_amount,
art.STATUS as paidstatus

From
 invoice_lines_mt il
 
join invoices i
on
il.center = i.center
and
il.id = i.id 

cross join
params


JOIN ar_trans art 
ON art.REF_CENTER = i.center 
AND art.REF_ID = i.id 
and art.ref_type = 'INVOICE'
and art.ENTRY_TIME >= params.StartDateLong 
and art.ENTRY_TIME <= params.EndDateLong

JOIN ART_MATCH arm
ON
arm.ART_PAID_CENTER = art.CENTER
AND arm.ART_PAID_ID = art.ID
AND arm.ART_PAID_SUBID = art.SUBID
AND arm.CANCELLED_TIME IS NULL
 
 
 
 where
il.text = 'British Heart Foundation Donation'
and i.entry_time >= params.StartDateLong
and i.entry_time <= params.EndDateLong
and art.STATUS = 'CLOSED'