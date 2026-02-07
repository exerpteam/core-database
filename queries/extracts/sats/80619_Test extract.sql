   SELECT
 -- p.CENTER||'p'||  p.ID,e.identity,gc.center,gc.id,
    gc.payer_center,
   gc.payer_id,
    NULL,
    3,--Note
    'Campaign Voucher',
    0,
    500,
    68998,
     params.ENTRY_TIME,
    NULL,
    NULL,
    NULL,
    NULL,
   -- utl_raw.cast_to_raw('Giftcard code '||e.identity),
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    0,
    NULL,
   -- NextIntegerSequence('JournalEntries'),
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
   params.ENTRY_TIME
FROM
    EXERP_TDA."fi_02022022" nt --Temporary table consisting of the listed members provided by the customer
/*JOIN
    persons p
ON
    p.center||'p'||p.id = nt."personid"*/
join gift_cards  gc on gc.payer_center||'p'||gc.payer_id = nt."personid"
join ENTITYIDENTIFIERS e 
ON
    e.ref_center = gc.center
    AND E.ref_id= gc.id
    AND E."IDMETHOD" = 1 -- BARCODE
    AND E."REF_TYPE" = 5 --gift card
JOIN
    (
        SELECT
            /*+ materialize */
            c.ID                                                  AS CENTER,
            dateToLongTZ(getcentertime(c.id), co.DEFAULTTIMEZONE) AS ENTRY_TIME
        FROM
            CENTERS c
        JOIN
            COUNTRIES co
        ON
            c.COUNTRY = co.ID) params
on params.center = gc.payer_center
WHERE
    e.identity IS NOT NULL
   and gc.EXPIRATIONDATE = to_date('31-01-2023','dd-mm-yyyy')
   and gc.amount = 35
   and gc.state = 0 --issued