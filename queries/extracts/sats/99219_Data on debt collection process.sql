-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    date_range AS materialized
    (
        SELECT
            (:date_from)::DATE                                    AS date_from ,
            (:date_to)::DATE                                    AS date_to,
            getstartofday((:date_from)::DATE::text, c.id)::bigint AS date_from_epoch,
            getendofday((:date_to)::DATE::text, c.id)::bigint   AS date_to_epoch,
            c.id                                                    AS center_id,
            c.country
        FROM
            centers c
               WHERE
              c.id IN  (:scope)
    )
    ,
    xml_table AS materialized
    (
        SELECT
            ccc.center,
            ccc.id,
            personcenter,
            personid,
            dr.country,
            dr.date_from_epoch,
            dr.date_to_epoch,
            ccs.name                            AS agency,
            convert_from(settings, 'UTF8')::xml AS doc
        FROM
            cashcollectioncases ccc
        JOIN
            date_range dr
        ON
            ccc.center=dr.center_id
        LEFT JOIN
            sats.cashcollectionservices ccs
        ON
            ccc.cashcollectionservice=ccs.id
        WHERE
            (
                ccc.startdate <= dr.date_to
            AND (
                    closed=false
                OR  ccc.closed_datetime >= dr.date_from_epoch)
            AND ccc.missingpayment=true )
    )
    ,
    xml_unpacked AS materialized
    (
        SELECT
            t.center,
            t.id,
            t.country,
            t.personcenter,
            t.personid,
            t.date_from_epoch,
            t.date_to_epoch,
            t.agency,
          
            u.ordinality                                      AS step_number,
            ( (xpath('string(local-name(*))', u.x))[1])::text AS step_type,
            doc
        FROM
            xml_table t
        CROSS JOIN
            LATERAL unnest(xpath('/cashCollectionSettings/cashCollectionStep/' || '*', t.doc)) WITH
            ORDINALITY AS u(x, ordinality)
        WHERE
            ( (
                    xpath('string(local-name(*))', u.x))[1])::text IN ('cashCollection',
                                                                       'requestAndStop',
                                                                       'requestBuyoutAndStop',
                                                                       'block')
    )
SELECT
    SUM(
        CASE
            WHEN cmap.step_type='cashCollection'
            THEN 1
            ELSE 0
        END) AS "Total in Debt Collection",
    SUM(
        CASE
            WHEN cmap.step_type='block'
            THEN 1
            ELSE 0
        END) AS "Total blocked",
    SUM(
        CASE
            WHEN cmap.step_type IN ( 'requestAndStop',
                                    'requestBuyoutAndStop')
            THEN 1
            ELSE 0
        END)     AS "Total terminated",
          SUM(
        CASE
            WHEN cmap.step_type='cashCollection' and ccj.creationtime >= cmap.date_from_epoch
            THEN 1
            ELSE 0
        END) AS "New in Debt Collection",
    SUM(
        CASE
            WHEN cmap.step_type='block' and ccj.creationtime >= cmap.date_from_epoch
            THEN 1
            ELSE 0
        END) AS "New blocked",
    SUM(
        CASE
            WHEN cmap.step_type IN ( 'requestAndStop',
                                    'requestBuyoutAndStop') and ccj.creationtime >= cmap.date_from_epoch
            THEN 1
            ELSE 0
        END)     AS "New terminated",
    cmap.country AS "Country",
    ch.name      AS "Clearinghouse" ,
    cmap.agency AS "Agency", 
        CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL_STAFF'
        ELSE 'Undefined'
    END         AS PERSON_TYPE
FROM
    xml_unpacked cmap
JOIN
    persons p
ON
    cmap.personcenter=p.center
AND cmap.personid=p.id
JOIN
    sats.cashcollectionjournalentries ccj
ON
    cmap.center=ccj.center
AND cmap.id=ccj.id
AND cmap.step_number=ccj.step
LEFT JOIN
    LATERAL
    (
        SELECT
            clearinghouse
        FROM
            (
                -- Priority 1: active or state15 agreements
                SELECT
                    pa.clearinghouse,
                    pa.last_modified,
                    1 AS priority
                FROM
                    Account_receivables ar
                JOIN
                    payment_agreements pa
                ON
                    ar.center = pa.center
                AND ar.id = pa.id
                WHERE
                    p.center = ar.customercenter
                AND p.id = ar.customerid
                AND ar.ar_type = 4
                AND (
                        pa.active = true
                    OR  pa.state = 15)
                UNION ALL
                -- Priority 2: any agreement (latest modified)
                SELECT
                    pa2.clearinghouse,
                    pa2.last_modified,
                    2 AS priority
                FROM
                    Account_receivables ar
                JOIN
                    payment_agreements pa2
                ON
                    ar.center = pa2.center
                AND ar.id = pa2.id
                WHERE
                    p.center = ar.customercenter
                AND p.id = ar.customerid
                AND ar.ar_type = 4 ) t
        ORDER BY
            t.priority,
            t.last_modified DESC LIMIT 1 ) AS find_clearing
ON
    true
LEFT JOIN
    sats.clearinghouses ch
ON
    find_clearing.clearinghouse=ch.id
WHERE
    ccj.creationtime < cmap.date_to_epoch
GROUP BY
    cmap.country ,
    ch.name ,
   p.PERSONTYPE,
    cmap.agency
ORDER BY
    4,5