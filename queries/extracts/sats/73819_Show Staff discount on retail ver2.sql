WITH

    params AS
    (
        SELECT /*+ materialize */
			dateToLongC(TO_CHAR($$from_date$$,'YYYY-MM-DD' ) || ' 00:00',100) AS FROMDATE,
			dateToLongC(TO_CHAR($$to_date$$,'YYYY-MM-DD' ) || ' 00:00',100) AS TODATE
        FROM
            dual
    )
SELECT
    sv.CENTER
  , C.NAME
  ,(CASE 
	WHEN a1.parent=316 THEN a1.NAME
	WHEN a2.parent=316 THEN a2.NAME
	WHEN a3.parent=316 THEN a3.NAME
	WHEN a4.parent=316 THEN a4.NAME
	ELSE NULL
  END) AS scope
  , sv.ID
  , sv.SUB_ID
  , sv.SALES_TYPE
  , sv.TEXT
  , sv.EMPLOYEE_CENTER || 'emp' || sv.EMPLOYEE_ID SALES_EMPLOYEE_EMP
  ,pemp.FULLNAME                                  SALES_EMPLOYEE_NAME
  , longToDateC(sv.TRANS_TIME,sv.CENTER)          TRANS_TIME
  , sv.PAYER_CENTER || 'p' || sv.PAYER_ID         CUSTOMER_PID
  ,p.FULLNAME                                     CUSTOMER_NAME
  , sv.PRODUCT_NAME
  , sv.PRODUCT_TYPE
, PROD.COST_PRICE
  , sv.PRODUCT_GROUP_NAME
  , sv.QUANTITY
  , sv.NET_AMOUNT
  , sv.VAT_AMOUNT
  , sv.TOTAL_AMOUNT / sv.QUANTITY                              PAID_AMOUNT
  ,invl.PRODUCT_NORMAL_PRICE                                   LIST_PRICE
  ,invl.PRODUCT_NORMAL_PRICE - (sv.TOTAL_AMOUNT / sv.QUANTITY) DISCOUNT
  ,sinvl.TOTAL_AMOUNT                                          SPONSORSHIP_AMOUNT
  FROM
	params,
    SALES_VW sv
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK link
ON
    link.PRODUCT_CENTER = sv.PRODUCT_CENTER
    AND link.PRODUCT_ID = sv.PRODUCT_ID
JOIN
    PRODUCTS PROD
ON
    PROD.ID = SV.PRODUCT_ID 
	AND PROD.CENTER = SV.PRODUCT_CENTER
JOIN
    PRODUCT_GROUP pg
ON
    link.PRODUCT_GROUP_ID = pg.ID
    AND UPPER(pg.NAME) = UPPER($$product_group$$)
JOIN
    PERSONS p
ON
    p.CENTER = sv.PAYER_CENTER
    AND p.ID = sv.PERSON_ID
    AND p.PERSONTYPE = 2
JOIN
	CENTERS C
ON
	sv.CENTER = C.ID
JOIN
    EMPLOYEES emp
ON
    emp.CENTER = sv.EMPLOYEE_CENTER
    AND emp.id = sv.EMPLOYEE_ID
JOIN
    PERSONS pemp
ON
    pemp.CENTER = emp.PERSONCENTER
    AND pemp.id = emp.PERSONID
LEFT JOIN
    INVOICELINES invl
ON
    invl.CENTER = sv.CENTER
    AND invl.ID = sv.ID
    AND invl.SUBID = sv.SUB_ID
    AND sv.SALES_TYPE = 'INVOICE'
LEFT JOIN
    INVOICELINES sinvl
ON
    sinvl.CENTER = sv.SPONSOR_INVOICE_CENTER
    AND sinvl.ID = sv.SPONSOR_INVOICE_ID
    AND sinvl.SUBID = sv.SPONSOR_INVOICE_SUBID
    AND sv.SALES_TYPE = 'INVOICE'


join area_centers ac on ac.center = c.id 
join areas a1 on a1.id = ac.area and a1.root_area = 297
join areas a2 on a2.id = a1.parent
join areas a3 on a3.id = a2.parent
join areas a4 on a4.id = a3.parent
WHERE
    p.CENTER IN ($$scope$$)
    AND sv.TRANS_TIME BETWEEN params.FROMDATE AND params.TODATE
ORDER BY
    sv.TRANS_TIME DESC
  , p.center
  ,p.id