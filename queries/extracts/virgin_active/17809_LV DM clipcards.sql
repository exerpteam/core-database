SELECT
    center.ID centerId,
    center.NAME centerName,
    p.center || 'p' || p.id AS PERSONID,
p.fullname MemberName,
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
    p.CENTER IN (26,
429,
402,
37,
416,
22,
41,
446,
5,
439,
42,
19,
44,
417,
46,
418,
17,
428,
49,
409,
426,
424,
53,
28,
20,
412,
414,
8,
423,
24,
11,
70,
14,
451,
73)
    AND clips.CLIPS_LEFT > 0
    AND clips.FINISHED = 0
    AND clips.CANCELLED = 0
    AND clips.BLOCKED = 0