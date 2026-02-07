SELECT 
  ID                                        AS "ID",
  agreement_center||'ar'||agreement_id||'agr'||agreement_subid AS "PAYMENT_AGREEMENT_ID",
  log_date                                  AS "LOG_DATE",
  CASE 	WHEN STATE = 1 THEN 'CREATED'
        WHEN STATE = 2 THEN 'SENT'
        WHEN STATE = 3 THEN 'FAILED'
        WHEN STATE = 4 THEN 'OK'
        WHEN STATE = 5 THEN 'ENDED, BANK'
        WHEN STATE = 6 THEN 'ENDED, CLEARING HOUSE'
        WHEN STATE = 7 THEN 'ENDED, DEBTOR'
        WHEN STATE = 8 THEN 'CANCELLED, NOT SENT'
        WHEN STATE = 9 THEN 'CANCELLED, SENT'
        WHEN STATE = 10 THEN 'ENDED, CREDITOR'
        WHEN STATE = 11 THEN 'NO AGREEMENT'
        WHEN STATE = 12 THEN 'CASH PAYMENT'
        WHEN STATE = 13 THEN 'AGREEMENT NOT NEEDED'
        WHEN STATE = 14 THEN 'AGREEMENT INFORMATION INCOMPLETE'
        WHEN STATE = 15 THEN 'TRANSFER'
        WHEN STATE = 16 THEN 'AGREEMENT RECREATED'
        WHEN STATE = 17 THEN 'SIGNATURE MISSING'
        ELSE 'UNDEFINED'
  END 				            AS "STATE",	
  clearing_in                   AS "CLEARING_IN_ID",
  text                          AS "DESCRIPTION",
  entry_time                    AS "ETS"
FROM
 agreement_change_log 
