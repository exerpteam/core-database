SELECT
    to_char(c.center) center,
    to_char(c.id) id,
    to_char(c.subid) subid,
    to_char(c.owner_center) owner_center,
    to_char(c.owner_id) owner_id,
    c.clips_left,
    c.clips_initial,
    to_char(invl.TOTAL_AMOUNT / invl.QUANTITY) price_per_clip_card,
    LongToDate(c.valid_until),
    p.name,
    p.ptype
FROM
    SATS.CLIPCARDS c
JOIN SATS.products p
ON
    p.center = c.center
    AND p.id = c.id
LEFT JOIN SATS.INVOICELINES invl
ON
    invl.CENTER = c.INVOICELINE_CENTER
    AND invl.ID = c.INVOICELINE_ID
    AND invl.SUBID = c.INVOICELINE_SUBID
WHERE
    C.OWNER_CENTER in (:scope)
    and c.clips_left = c.CLIPS_INITIAL
    AND c.finished =0
    AND c.cancelled =0
    and c.VALID_UNTIL < :expiredBefore