SELECT
	trans.center,
	trans.id,
	trans.subid,
TO_CHAR(longtodatec(trans.trans_time, ar.CENTER),'YYYY-MM-DD') AS "TransactionTime",
TO_CHAR(longtodatec(trans.entry_time, ar.CENTER),'YYYY-MM-DD') AS "EntryTime",
	trans.status as Status,
    trans.ref_type as RefType,
    ar.ar_type as AccountReceivableType,
	trans.text,
	trans.amount as TotalAmount,
    trans.unsettled_amount,
	settlements.art_paid_center AS RequestedPaymentCenter,
	settlements.art_paid_id AS RequestedPaymentId,
	settlements.art_paid_subid AS RequestedPaymentSubId,
	trans.entry_time as "ETS"

FROM		ACCOUNT_RECEIVABLES ar

			JOIN PERSONS p
				ON p.ID = ar.CUSTOMERID 
				AND p.CENTER = ar.CUSTOMERCENTER
								
			JOIN PERSONS cp ON 
				cp.center = p.transfers_current_prs_center 
				AND cp.id = p.transfers_current_prs_id
				AND cp.external_ID = :ExternalId

			JOIN AR_TRANS trans
				ON trans.ID = ar.ID 
				AND trans.CENTER = ar.CENTER
				AND CAST(TO_CHAR(longtodateC(trans.entry_time, trans.CENTER), 'YYYY-MM-DD') AS DATE) 
BETWEEN :StartDate AND CAST(:EndDate AS Timestamp) + INTERVAL '1 DAY'
				--AND collected = 2

			JOIN ART_MATCH settlements
				ON settlements.art_paying_center = trans.center
				AND settlements.art_paying_id = trans.id
				AND settlements.art_paying_subid = trans.subid