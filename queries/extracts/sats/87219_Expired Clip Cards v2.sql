-- The extract is extracted from Exerp on 2026-02-08
-- EC-6784
WITH
    params AS Materialized
    (
        SELECT
                datetolongTZ (TO_CHAR (CURRENT_DATE - interval '1 month', 'YYYY-MM-DD HH24:MI'), c.time_zone)::bigint AS from_date,
                datetolongTZ (TO_CHAR (CURRENT_DATE, 'YYYY-MM-DD HH24:MI'), c.time_zone)::bigint AS to_date,
                c.id AS centerid
        FROM
            centers c
    )

SELECT
        center,
        id,
        subid,
        owner_center,
        owner_id,
        OLD_MEMBERNUMBER,
        clips_left,
        clips_initial,
        price_per_clip_card,
        price_per_clip_card_spons,
        pid_spons,
        valid_until,
        name,
        CASE WHEN MAX (INSTALLMENT_PLAN_ID) IS NULL THEN 'No' ELSE 'Yes' END AS "Installment Plan",
        MAX (INSTALLEMENTS_COUNT), 
        country_name
    FROM
        (
        
            SELECT DISTINCT
                    c.center::VARCHAR          center,
                    c.id::VARCHAR              id,
                    c.subid::VARCHAR           subid,
                    c.owner_center::VARCHAR    owner_center,
                    c.owner_id::VARCHAR        owner_id,
                    pea_oldid.txtvalue      AS OLD_MEMBERNUMBER,
                    c.clips_left,
                    c.clips_initial,
                    CAST (invl.TOTAL_AMOUNT * 1.000 / invl.QUANTITY AS DECIMAL (18, 2))   price_per_clip_card,
                    CAST (invls.TOTAL_AMOUNT * 1.000 / invls.QUANTITY AS DECIMAL (18, 2)) price_per_clip_card_spons,
                    invls.PERSON_CENTER || 'p' || invls.PERSON_ID                         pid_spons,
                    LongToDate (c.valid_until)                                            valid_until,
                    p.name,
                    crt.INSTALLMENT_PLAN_ID,
                    insp.INSTALLEMENTS_COUNT, 
                    co.name as country_name
                FROM
                    CLIPCARDS c
                JOIN
                    params on params.centerid = c.center  and c.valid_until between params.from_date and params.to_date  
                JOIN
                    products p ON p.center = c.center AND p.id = c.id
                JOIN
                    centers cen ON c.owner_center = cen.id
		JOIN 
		    COUNTRIES co ON cen.COUNTRY = co.ID
                LEFT JOIN
                    PERSON_EXT_ATTRS pea_oldid ON pea_oldid.PERSONCENTER = c.owner_center AND pea_oldid.PERSONID = c.owner_id AND pea_oldid.name =
                    '_eClub_OldSystemPersonId'
                LEFT JOIN
                    INVOICELINES invl ON invl.CENTER = c.INVOICELINE_CENTER AND invl.ID = c.INVOICELINE_ID AND invl.SUBID = c.INVOICELINE_SUBID
                LEFT JOIN
                    INVOICES inv ON inv.CENTER = invl.CENTER AND inv.ID = invl.ID
                LEFT JOIN
                    INVOICELINES invls ON invls.CENTER = inv.SPONSOR_INVOICE_CENTER AND invls.ID = inv.SPONSOR_INVOICE_ID AND invls.SUBID =
                    invl.SPONSOR_INVOICE_SUBID
                LEFT JOIN
                    CASHREGISTERTRANSACTIONS crt ON inv.PAYSESSIONID = crt.PAYSESSIONID
                LEFT JOIN
                    INSTALLMENT_PLANS insp ON insp.ID = crt.INSTALLMENT_PLAN_ID
                WHERE
                    c.cancelled = false 
                    and C.OWNER_CENTER IN (:scope) 
                    ) t1
    GROUP BY
        center,
        id,
        subid,
        owner_center,
        owner_id,
        OLD_MEMBERNUMBER,
        clips_left,
        clips_initial,
        price_per_clip_card,
        price_per_clip_card_spons,
        pid_spons,
        valid_until,
        name, 
        country_name