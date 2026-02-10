-- The extract is extracted from Exerp on 2026-02-08
-- Creator: Henrik Håkanson
Purpose: List clipcards that has expired with clips left.

SELECT
    center.ID centerId,
    center.NAME centerName,
    p.CENTER || 'p' || p.ID AS PERSONID,
    clips.CENTER || 'cc' || clips.ID || 'id' || clips.SUBID AS CLIPCARD_ID,
    pd.GLOBALID globalNAME,
    pd.NAME,
    TO_CHAR(longtodate(clips.VALID_FROM), 'YYYY-MM-DD') AS VALID_FROM_DATE,
    TO_CHAR(longtodate(clips.VALID_UNTIL), 'YYYY-MM-DD') AS VALID_TO_DATE,
    clips.CLIPS_INITIAL,
    clips.CLIPS_LEFT,
    il.TOTAL_AMOUNT Original_Price,
	clips.BLOCKING_TIME,
	clips.CANCELLATION_TIME,
	clips.CANCELLED


FROM CLIPCARDS clips
JOIN CENTERS center
ON
    clips.CENTER = center.ID
JOIN CLIPCARDTYPES ct
ON
    ct.CENTER = clips.CENTER
    AND ct.id = clips.ID
JOIN INVOICELINES il
ON
    il.CENTER = clips.INVOICELINE_CENTER
    AND il.ID = clips.INVOICELINE_ID
    AND il.SUBID = clips.INVOICELINE_SUBID
JOIN PRODUCTS pd
ON
    pd.CENTER = ct.CENTER
    AND pd.ID = ct.ID
JOIN PERSONS p
ON
    p.CENTER = clips.OWNER_CENTER
    AND p.ID = clips.OWNER_ID
WHERE
    p.CENTER IN ($$scope$$)
    AND clips.CLIPS_LEFT > 0
AND clips.VALID_FROM >=$$FromDate$$	
AND clips.VALID_UNTIL <=$$ToDate$$
AND clips.CANCELLED = FALSE
