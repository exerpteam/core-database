WITH
    PARAMS AS
    (
        SELECT
            datetolong(TO_CHAR( TRUNC($$CheckDate$$,'MM'), 'YYYY-MM-dd HH24:MI' ))     fromdate,
            datetolong(TO_CHAR(TRUNC(LAST_DAY($$CheckDate$$)), 'YYYY-MM-dd HH24:MI' )) todate
        FROM
            dual
    )
SELECT
    s.CENTER,
    c.NAME,
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),1,1,0))  AS "1st Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),1,1,0))                   AS "1st Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),2,1,0))  AS "2nd Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),2,1,0))                   AS "2nd Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),3,1,0))  AS "3rd Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),3,1,0))                   AS "3rd Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),4,1,0))  AS "4th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),4,1,0))                   AS "4th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),5,1,0))  AS "5th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),5,1,0))                   AS "5th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),6,1,0))  AS "6th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),6,1,0))                   AS "6th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),7,1,0))  AS "7th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),7,1,0))                   AS "7th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),8,1,0))  AS "8th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),8,1,0))                   AS "8th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),9,1,0))  AS "9th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),9,1,0))                   AS "9th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),10,1,0)) AS "10th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),10,1,0))                  AS "10th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),11,1,0)) AS "11th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),11,1,0))                  AS "11th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),12,1,0)) AS "12th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),12,1,0))                  AS "12th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),13,1,0)) AS "13th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),13,1,0))                  AS "13th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),14,1,0)) AS "14th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),14,1,0))                  AS "14th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),15,1,0)) AS "15th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),15,1,0))                  AS "15th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),16,1,0)) AS "16th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),16,1,0))                  AS "16th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),17,1,0)) AS "17th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),17,1,0))                  AS "17th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),18,1,0)) AS "18th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),18,1,0))                  AS "18th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),19,1,0)) AS "19th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),19,1,0))                  AS "19th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),20,1,0)) AS "20th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),20,1,0))                  AS "20th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),21,1,0)) AS "21st Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),21,1,0))                  AS "21st Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),22,1,0)) AS "22nd Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),22,1,0))                  AS "22nd Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),23,1,0)) AS "23rd Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),23,1,0))                  AS "23rd Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),24,1,0)) AS "24th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),24,1,0))                  AS "24th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),25,1,0)) AS "5th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),25,1,0))                  AS "25th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),26,1,0)) AS "6th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),26,1,0))                  AS "26th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),27,1,0)) AS "7th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),27,1,0))                  AS "27th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),28,1,0)) AS "8th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),28,1,0))                  AS "28th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),29,1,0)) AS "9th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),29,1,0))                  AS "29th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),30,1,0)) AS "30th Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),30,1,0))                  AS "30th Ends",
    SUM(DECODE(extract(DAY FROM longtodate(sa.CREATION_TIME)),31,1,0)) AS "31st Sales",
    SUM(DECODE(extract(DAY FROM sa.END_DATE),31,1,0))                  AS "31st Ends"
FROM
    SUBSCRIPTIONS s
CROSS JOIN
    params
JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.CENTER
    AND sa.SUBSCRIPTION_ID = s.ID
    AND sa.CANCELLED=0
    AND sa.START_DATE<exerpsysdate()
    AND (
        sa.END_DATE >exerpsysdate()
        OR sa.END_DATE IS NULL)
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
JOIN
    CENTERS c
ON
    s.CENTER = c.ID
WHERE
    s.STATE IN(2,4)
    AND mpr.GLOBALID IN ( 'CASH_GX_ADD_ON_1',
                         'CASH_GX_ADD_ON',
                         'EFT_GX_ADD_ON',
                         'EFT_GX_ADD_ON_1',
                         'ADD_ON_CLASSES_EFT',
                         'ADD_ON_CLASSES_CASH')
    AND p.center IN ($$scope$$)
    AND (
        sa.CREATION_TIME BETWEEN params.fromdate AND params.todate
        OR sa.END_DATE BETWEEN longtodate(params.fromdate) AND longtodate(params.todate))
GROUP BY
    s.CENTER,
    c.NAME