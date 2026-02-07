/**
* Creator: Mikael Ahlberg
* Modified by: Exerp
* Purpose: Display Transactioninformation for a given period. Account is given as TEXT input.
*/
SELECT
    club.SHORTNAME clubname,
    act.EXTERNAL_ID,
    TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') book_date,
    art.TEXT,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID member_id,
    art.AMOUNT
FROM
    ACCOUNT_RECEIVABLES ar
JOIN ACCOUNTS act
ON
    ar.ASSET_ACCOUNTCENTER = act.CENTER
    AND ar.ASSET_ACCOUNTID = act.ID
JOIN AR_TRANS art
ON
    ar.center = art.center
    AND ar.id = art.id
JOIN CENTERS club
ON
    act.center = club.ID
WHERE
    ar.center IN (:Scope)
    AND art.AMOUNT <> 0
    AND art.AMOUNT IS NOT NULL
    AND act.EXTERNAL_ID = :Account
    AND art.TRANS_TIME >= :FromDate
    AND art.TRANS_TIME < :ToDate + 1000 * 3600 * 24 