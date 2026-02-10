-- The extract is extracted from Exerp on 2026-02-08
--  
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
     p.CENTER = 75
     AND clips.CLIPS_LEFT > 0
    -- AND clips.FINISHED = 0
     AND clips.CANCELLED = 0
     AND clips.BLOCKED = 0
