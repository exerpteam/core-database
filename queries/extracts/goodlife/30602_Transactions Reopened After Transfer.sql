-- The extract is extracted from Exerp on 2026-02-08
-- This extract looks for collected transactions that will be resent to the bank after a transfer is completed.
Approved in:
ISSUE-35208
ST-10717
-- Transfer Transactions Re-Opened

SELECT

p.center||'p'||p.id AS current_person_id
,p2.center||'p'||p2.id AS pre_transfer_person_id
,p.fullname
,TO_CHAR(LONGTODATEC(scl.entry_start_time,scl.center),'YYYY-MM-DD HH:MM:SS') AS transfer_time
,TO_CHAR(LONGTODATEC(art.entry_time,art.center),'YYYY-MM-DD HH:MM:SS') AS new_transaction_time
,TO_CHAR(LONGTODATEC(art3.entry_time,art3.center),'YYYY-MM-DD HH:MM:SS') AS original_transaction_time
,art.text
,art.amount

FROM

state_change_log scl

-- Transferred persons
JOIN persons p
ON scl.center = p.center
AND scl.id = p.id
AND scl.entry_type = 1
AND scl.stateid = 4
AND scl.entry_start_time >(CAST((CURRENT_DATE-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)-:Offset)*24*3600*1000 -- Within last x days

-- pre-transfer person record
JOIN persons p2
ON p2.transfers_current_prs_center = p.center
AND p2.transfers_current_prs_id = p.id
AND p.center != p2.center
AND p.id != p2.id

JOIN account_receivables ar
ON ar.customercenter = p.center
AND ar.customerid = p.id

-- transactions entered within + or - 10 seconds of transfer
JOIN ar_trans art
ON ar.center = art.center
AND ar.id = art.id
AND art.entry_time BETWEEN scl.entry_start_time - 10000 AND scl.entry_start_time + 10000
AND art.collected = 0
AND art.amount < 0

JOIN account_receivables ar2
ON ar2.customercenter = p2.center
AND ar2.customerid = p2.id


-- transactions entered on pre-transfer receivable account matching new transactions on post-transfer receivable account
JOIN ar_trans art2
ON ar2.center = art2.center
AND ar2.id = art2.id
AND art.text = art2.text
AND art.amount = (art2.amount * -1)
AND art.employeecenter = art2.employeecenter
AND art.employeeid = art2.employeeid

-- original transaction
JOIN ar_trans art3
ON art3.center = art2.center
AND art3.id = art2.id 
AND art3.subid != art2.subid -- prevent join same transaction to itself
AND art3.text = art2.text
AND art3.amount = (art2.amount * -1)
AND art3.payreq_spec_center IS NOT NULL -- transactions was originally collected in a payment request

-- original transactions was settled within 10 seconds of the transfer
AND EXISTS (

    SELECT
    
    1
    
    FROM
    
    art_match s
    
    WHERE
    
    art_paid_center = art3.center
    AND art_paid_id = art3.id
    AND (
        art_paid_subid = art3.subid
        OR art_paying_subid = art3.subid
    )
    AND (s.cancelled_time IS NULL OR s.cancelled_time = 0)
    AND s.entry_time BETWEEN scl.entry_start_time - 10000 AND scl.entry_start_time + 10000

)

