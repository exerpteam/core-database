SELECT 
    center.ID centerId,
    center.NAME centerName,
    p.center || 'p' || p.id AS PERSONID,
p.fullname,
	p.STATUS,
    clips.CENTER || 'cc' || clips.id || 'id' || clips.subid AS CLIPCARD_ID,
    pd.GLOBALID globalNAME,
    pd.NAME,
    TO_CHAR(longtodate(clips.VALID_FROM), 'YYYY-MM-DD') AS VALID_FROM_DATE,
    TO_CHAR(longtodate(clips.VALID_UNTIL), 'YYYY-MM-DD') AS VALID_TO_DATE,
    clips.CLIPS_INITIAL,
    clips.CLIPS_LEFT,
    il.TOTAL_AMOUNT Original_Price
FROM
    clipcards clips
JOIN CENTERS center
ON
    clips.center = center.id
JOIN CLIPCARDTYPES ct
ON
    ct.center = clips.center
    AND ct.id = clips.id
JOIN INVOICELINES il
ON
    il.center = clips.INVOICELINE_CENTER
    AND il.id = clips.INVOICELINE_ID
    AND il.SUBID = clips.INVOICELINE_SUBID
JOIN products pd
ON
    pd.center = ct.center
    AND pd.id = ct.id
JOIN persons p
ON
    p.center = clips.OWNER_CENTER
    AND p.id = clips.OWNER_ID
WHERE
    p.CENTER in (76,	29,30,437,33,34,35,	27,	36,	421,	405,	38,	438,	40,	39,	47,	48,	12,	51,	9,	955,	56,	954,	57,	59,	415,	2,	60,	61,	422,	452,	15,	6,	68,	69,	410,	16,	71,	75,	953,	425,	13,	408)

    AND clips.FINISHED = 1
    AND clips.CANCELLED = 0
    AND clips.BLOCKED = 0
	AND TO_CHAR(longtodate(clips.VALID_FROM), 'YYYY-MM-DD') between '2016-01-01' AND '2018-10-18'
