-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    details AS
    (
        SELECT
            pa.*,
            upload.medlemsid,
            ch.name AS current_clearing_house,
            CASE
                WHEN pa.clearinghouse = 1816
                AND upload.clearinghouse = 'Elixia Vest Invoice Person' --  Elixia Vest EFT Person
                THEN 1818 --Elixia Vest Invoice Person
                WHEN pa.clearinghouse = 1812
                AND upload.clearinghouse = 'HFN Norway Invoice Person' -- HFN Norway EFT Person
                THEN 1814 -- HFN Norway Invoice Person
            END AS new_clearinghouse,
            CASE
                WHEN pa.clearinghouse = 1816 --  Elixia Vest EFT Person
                THEN 'ELIX VEST INV P'
                WHEN pa.clearinghouse = 1812 -- HFN Norway EFT Person
                THEN 'NO HFN INV P'
            END                                             AS new_creditor_id,
            dateToLongC(getCenterTime(ar.center),ar.center) AS new_last_modified
        FROM
            public.ec7763_clearinghouse_change upload
        JOIN
            sats.account_receivables ar
        ON
            upload.medlemsid = ar.customercenter||'p'||ar.customerid
        JOIN
            sats.payment_agreements pa
        ON
            pa.center = ar.center
        AND pa.id = ar.id
        JOIN
            sats.clearinghouses ch
        ON
            ch.id = pa.clearinghouse
        WHERE
            ar.ar_type = 4
        AND pa.clearinghouse IN(1816,1812)
        AND pa.state != 4
    )
SELECT
    medlemsid,
    details.center||'ar'||details.ID||'agr'||details.subid AS agreement_id,
    CASE
        WHEN details.state = 1
        THEN 'CREATED'
        WHEN details.state = 2
        THEN 'SENT'
        WHEN details.state = 3
        THEN 'FAILED'
        WHEN details.state = 4
        THEN 'OK'
        WHEN details.state = 5
        THEN 'ENDED, BANK'
        WHEN details.state = 6
        THEN 'ENDED, CLEARING HOUSE'
        WHEN details.state = 7
        THEN 'ENDED, DEBTOR'
        WHEN details.state = 8
        THEN 'CANCELLED, NOT SENT'
        WHEN details.state = 9
        THEN 'CANCELLED, SENT'
        WHEN details.state = 10
        THEN 'ENDED, CREDITOR'
        WHEN details.state = 11
        THEN 'NO AGREEMENT'
        WHEN details.state = 12
        THEN 'CASH PAYMENT'
        WHEN details.state = 13
        THEN 'AGREEMENT NOT NEEDED'
        WHEN details.state = 14
        THEN 'AGREEMENT INFORMATION INCOMPLETE'
        WHEN details.state = 15
        THEN 'TRANSFER'
        WHEN details.state = 16
        THEN 'AGREEMENT RECREATED'
        WHEN details.state = 17
        THEN 'SIGNATURE MISSING'
        ELSE 'UNDEFINED'
    END AS agreement_State,
    current_clearing_house,
    ch.name AS new_clearinghouse
FROM
    details
JOIN
    sats.clearinghouses ch
ON
    ch.id = details.new_clearinghouse