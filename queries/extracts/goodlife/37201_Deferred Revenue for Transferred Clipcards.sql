-- Deferred Revenue for Transferred Clipcards (including transfers between duplicate Members)
-- Created On: 2021-03-10
SELECT 
	OldCC.center || 'cc' || OldCC.id || 'id' || OldCC.subid AS "From Clipcard",
	NewCC.center || 'cc' || NewCC.id || 'id' || NewCC.subid AS "To Clipcard",
	OldCC.owner_center || 'p' || OldCC.owner_id as "From ClubPersonID",
	NewCC.owner_center || 'p' || NewCC.owner_id as "To ClubPersonID",
	TO_CHAR(longtodate(NewCCU.time),'YYYY-MM-DD') as "Transfer Date",
	OldCC.center as "From Club Number",
	OldCenter.name AS "From Club Name",
	NewCC.center as "To Club Number",
	NewCenter.name as "To Club Name",
	PGN.NAME  AS "Primary Product Group",
	PR.NAME  AS "Product Name",
	PAC.DEFER_REV_ACCOUNT_GLOBALID AS "Deferred Revenue Account",
	ROUND(((IL.TOTAL_AMOUNT + COALESCE(IL2.TOTAL_AMOUNT, 0)) / (COALESCE(ILVATL.RATE, 0) + 1)),2) AS "Amount Excluding VAT",
	OldCC.clips_initial as "Initial Clips",
	CAST((ROUND(((IL.TOTAL_AMOUNT + COALESCE(IL2.TOTAL_AMOUNT, 0)) / (COALESCE(ILVATL.RATE, 0) + 1)),2)) / OldCC.clips_initial AS DOUBLE PRECISION)  AS "Price Per Clip",
	TO_CHAR(longtodate(OldCC.valid_from),'YYYY-MM-DD') as "Valid From",
	OldCCU.clips * -1 as "Transferred Clips",
	TO_CHAR(longtodate(NewCC.valid_from),'YYYY-MM-DD') as "Transferred Valid From"

FROM clipcards NewCC -- post-transfer clipcards

LEFT JOIN card_clip_usages NewCCU -- post-transfer clipcard usages 
	ON NewCC.center = NewCCU.card_center
	AND NewCC.id = NewCCU.card_id
	AND NewCC.subid = NewCCU.card_subid
	AND NewCCU."type" = 'TRANSFER_TO'
	AND NewCCU.state = 'ACTIVE'

JOIN clipcards OldCC -- pre-transfer clipcards
	ON NewCC.transfer_from_clipcard_center = OldCC.center
	AND NewCC.transfer_from_clipcard_id = OldCC.id
	AND NewCC.transfer_from_clipcard_subid = OldCC.subid

LEFT JOIN card_clip_usages OldCCU -- pre-transfer clipcard usages 
	ON OldCC.center = OldCCU.card_center
	AND OldCC.id = OldCCU.card_id
	AND OldCC.subid = OldCCU.card_subid
	AND OldCCU."type" = 'TRANSFER_FROM'
	AND OldCCU.state = 'ACTIVE'

JOIN INVOICE_LINES_MT IL 
	ON NewCC.INVOICELINE_CENTER = IL.CENTER
    AND NewCC.INVOICELINE_ID = IL.ID
    AND NewCC.INVOICELINE_SUBID = IL.SUBID

JOIN INVOICES INV
	ON IL.CENTER = INV.CENTER
    AND IL.ID = INV.ID

JOIN PRODUCTS PR
	ON IL.PRODUCTCENTER = PR.CENTER
	AND IL.PRODUCTID = PR.ID

LEFT JOIN INVOICELINES_VAT_AT_LINK ILVATL
	ON ILVATL.INVOICELINE_CENTER = IL.CENTER
	AND ILVATL.INVOICELINE_ID = IL.ID
	AND ILVATL.INVOICELINE_SUBID = IL.SUBID

JOIN PRODUCT_GROUP PGN
	ON PR.PRIMARY_PRODUCT_GROUP_ID = PGN.ID

LEFT JOIN PRODUCT_ACCOUNT_CONFIGURATIONS PAC
	ON PR.PRODUCT_ACCOUNT_CONFIG_ID = PAC.ID

LEFT JOIN INVOICE_LINES_MT IL2
	ON IL2.CENTER = INV.SPONSOR_INVOICE_CENTER
    AND IL2.ID = INV.SPONSOR_INVOICE_ID
    AND IL2.SUBID = IL.SPONSOR_INVOICE_SUBID

JOIN CENTERS NewCenter -- center for the pre-transferred clips
	ON NewCenter.id = NewCC.center

JOIN CENTERS OldCenter -- center for the post-transferred clips
	ON OldCenter.id = OldCC.center

WHERE NewCC.cancelled = 'f' AND OldCC.cancelled = 'f'
	AND longtodate(NewCCU.time) >= CAST($$StartDate$$ AS DATE)
	AND longtodate(NewCCU.time) <= CAST($$EndDate$$ AS DATE) + INTERVAL '1 DAY'