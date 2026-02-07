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
     CASE WHEN MAX(INSTALLMENT_PLAN_ID) IS NULL THEN 'No' ELSE 'Yes' END AS "Installment Plan",
     MAX(INSTALLEMENTS_COUNT)
 FROM
     (
         SELECT DISTINCT
             c.center::varchar          center,
             c.id::varchar              id,
             c.subid::varchar           subid,
             c.owner_center::varchar    owner_center,
             c.owner_id::varchar        owner_id,
             pea_oldid.txtvalue      AS OLD_MEMBERNUMBER,
             c.clips_left,
             c.clips_initial,
             CAST(invl.TOTAL_AMOUNT*1.000 / invl.QUANTITY AS DECIMAL(18,6))    price_per_clip_card,
             CAST(invls.TOTAL_AMOUNT*1.000 / invls.QUANTITY AS DECIMAL(18,6))  price_per_clip_card_spons,
             invls.PERSON_CENTER || 'p' || invls.PERSON_ID pid_spons,
             LongToDate(c.valid_until)             valid_until,
             p.name,
             crt.INSTALLMENT_PLAN_ID,
             insp.INSTALLEMENTS_COUNT
         FROM
             CLIPCARDS c
         JOIN
             products p
         ON
             p.center = c.center
             AND p.id = c.id
         LEFT JOIN
             PERSON_EXT_ATTRS pea_oldid
         ON
             pea_oldid.PERSONCENTER = c.owner_center
             AND pea_oldid.PERSONID = c.owner_id
             AND pea_oldid.name = '_eClub_OldSystemPersonId'
         LEFT JOIN
             INVOICELINES invl
         ON
             invl.CENTER = c.INVOICELINE_CENTER
             AND invl.ID = c.INVOICELINE_ID
             AND invl.SUBID = c.INVOICELINE_SUBID
         LEFT JOIN
             INVOICES inv
         ON
             inv.CENTER = invl.CENTER
             AND inv.ID = invl.ID
         LEFT JOIN
             INVOICELINES invls
         ON
             invls.CENTER = inv.SPONSOR_INVOICE_CENTER
             AND invls.ID = inv.SPONSOR_INVOICE_ID
             AND invls.SUBID = invl.SPONSOR_INVOICE_SUBID
         LEFT JOIN
             CASHREGISTERTRANSACTIONS crt
         ON
             inv.PAYSESSIONID = crt.PAYSESSIONID
         LEFT JOIN
             INSTALLMENT_PLANS insp
         ON
             insp.ID = crt.INSTALLMENT_PLAN_ID
         WHERE
             C.OWNER_CENTER IN ($$scope$$)
             AND c.cancelled =0
            AND c.VALID_UNTIL BETWEEN $$from_date$$ AND $$to_date$$)  t1
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
     name
