SELECT
    CASE
        WHEN REGION IS NULL
        THEN NULL
        ELSE REGION
    END AS "Region" ,
    CASE
        WHEN CENTER IS NULL
        THEN 'Total'
        ELSE CENTER
    END                 AS "Center" ,
    C_STATUS            AS "Status",
    SUM(TB."Total New") AS "Total New",
    CASE
        WHEN ((SUM(TB."Total New")+SUM (TB."Total Cancels"))=0)
        THEN 'N/A'
        ELSE ROUND(100*SUM(TB."Total New")/(SUM(TB."Total New")+SUM (TB."Total Cancels")))|| ' %'
    END                      AS "New %" ,
    SUM (TB."Total Cancels") AS "Total Cancels",
    CASE
        WHEN ((SUM(TB."Total New")+SUM (TB."Total Cancels"))=0)
        THEN 'N/A'
        ELSE ROUND(100*SUM(TB."Total Cancels")/(SUM(TB."Total New")+SUM (TB."Total Cancels"))) || ' %'
    END                     AS "Cancels %",
    SUM("1st - New")        AS "1st - New",
    SUM("1st - Cancels")    AS "1st - Cancels" ,
    SUM("1st - Net gains")  AS "1st - Net gains",
    SUM("2nd - New")        AS "2nd - New",
    SUM("2nd - Cancels")    AS "2nd - Cancels",
    SUM("2nd - Net gains")  AS "2nd - Net gains",
    SUM("3rd - New")        AS "3rd - New",
    SUM("3rd - Cancels")    AS "3rd - Cancels",
    SUM("3rd - Net gains")  AS "3rd - Net gains",
    SUM("4th - New")        AS "4th - New",
    SUM("4th - Cancels")    AS "4th - Cancels",
    SUM("4th - Net gains")  AS "4th - Net gains",
    SUM("5th - New")        AS "5th - New",
    SUM("5th - Cancels")    AS "5th - Cancels",
    SUM("5th - Net gains")  AS "5th - Net gains",
    SUM("6th - New")        AS "6th - New",
    SUM("6th - Cancels")    AS "6th - Cancels",
    SUM("6th - Net gains")  AS "6th - Net gains",
    SUM("7th - New")        AS "7th - New",
    SUM("7th - Cancels")    AS "7th - Cancels",
    SUM("7th - Net gains")  AS "7th - Net gains",
    SUM("8th - New")        AS "8th - New",
    SUM("8th - Cancels")    AS "8th - Cancels",
    SUM("8th - Net gains")  AS "8th - Net gains",
    SUM("9th - New")        AS "9th - New",
    SUM("9th - Cancels")    AS "9th - Cancels",
    SUM("9th - Net gains")  AS "9th - Net gains",
    SUM("10th - New")       AS "10th - New",
    SUM("10th - Cancels")   AS "10th - Cancels",
    SUM("10th - Net gains") AS "10th - Net gains",
    SUM("11th - New")       AS "11th - New",
    SUM("11th - Cancels")   AS "11th - Cancels",
    SUM("11th - Net gains") AS "11th - Net gains",
    SUM("12th - New")       AS "12th - New",
    SUM("12th - Cancels")   AS "12th - Cancels",
    SUM("12th - Net gains") AS "12th - Net gains",
    SUM("13th - New")       AS "13th - New",
    SUM("13th - Cancels")   AS "13th - Cancels",
    SUM("13th - Net gains") AS "13th - Net gains",
    SUM("14th - New")       AS "14th - New",
    SUM("14th - Cancels")   AS "14th - Cancels",
    SUM("14th - Net gains") AS "14th - Net gains",
    SUM("15th - New")       AS "15th - New",
    SUM("15th - Cancels")   AS "15th - Cancels",
    SUM("15th - Net gains") AS "15th - Net gains",
    SUM("16th - New")       AS "16th - New",
    SUM("16th - Cancels")   AS "16th - Cancels",
    SUM("16th - Net gains") AS "16th - Net gains",
    SUM("17th - New")       AS "17th - New",
    SUM("17th - Cancels")   AS "17th - Cancels",
    SUM("17th - Net gains") AS "17th - Net gains",
    SUM("18th - New")       AS "18th - New",
    SUM("18th - Cancels")   AS "18th - Cancels",
    SUM("18th - Net gains") AS "18th - Net gains",
    SUM("19th - New")       AS "19th - New",
    SUM("19th - Cancels")   AS "19th - Cancels",
    SUM("19th - Net gains") AS "19th - Net gains",
    SUM("20th - New")       AS "20th - New",
    SUM("20th - Cancels")   AS "20th - Cancels",
    SUM("20th - Net gains") AS "20th - Net gains",
    SUM("21st - New")       AS "21st - New",
    SUM("21st - Cancels")   AS "21st - Cancels",
    SUM("21st - Net gains") AS "21st - Net gains",
    SUM("22nd - New")       AS "22nd - New",
    SUM("22nd - Cancels")   AS "22nd - Cancels",
    SUM("22nd - Net gains") AS "22nd - Net gains",
    SUM("23th - New")       AS "23th - New",
    SUM("23th - Cancels")   AS "23th - Cancels",
    SUM("23th - Net gains") AS "23th - Net gains",
    SUM("24th - New")       AS "24th - New",
    SUM("24th - Cancels")   AS "24th - Cancels",
    SUM("24th - Net gains") AS "24th - Net gains",
    SUM("25th - New")       AS "25th - New",
    SUM("25th - Cancels")   AS "25th - Cancels",
    SUM("25th - Net gains") AS "25th - Net gains",
    SUM("26th - New")       AS "26th - New",
    SUM("26th - Cancels")   AS "26th - Cancels",
    SUM("26th - Net gains") AS "26th - Net gains",
    SUM("27th - New")       AS "27th - New",
    SUM("27th - Cancels")   AS "27th - Cancels",
    SUM("27th - Net gains") AS "27th - Net gains",
    SUM("28th - New")       AS "28th - New",
    SUM("28th - Cancels")   AS "28th - Cancels",
    SUM("28th - Net gains") AS "28th - Net gains",
    SUM("29th - New")       AS "29th - New",
    SUM("29th - Cancels")   AS "29th - Cancels",
    SUM("29th - Net gains") AS "29th - Net gains",
    SUM("30th - New")       AS "30th - New",
    SUM("30th - Cancels")   AS "30th - Cancels",
    SUM("30th - Net gains") AS "30th - Net gains",
    SUM("31st - New")       AS "31st - New",
    SUM("31st - Cancels")   AS "31st - Cancels",
    SUM("31st - Net gains") AS "31st - Net gains"
FROM
    (
        SELECT
            A.NAME AS REGION,
            C.NAME AS CENTER,
            CASE
                WHEN c.STARTUPDATE> CAST(now() AS DATE)
                THEN 'Pre-Join'
                ELSE 'Open'
            END AS C_STATUS,
            (
                SELECT
                    SUM(D.VALUE)
                FROM
                    KPI_DATA D,
                    KPI_FIELDS F
                WHERE
                    F.KEY = 'POSITIVEGAIN'
                    AND D.FIELD = F.ID
                    AND C.ID = D.CENTER
                    AND D.FOR_DATE BETWEEN P.STARTDATE AND
                    CASE
                        WHEN CAST(DATE_TRUNC('month', P.STARTDATE) AS DATE) = CAST(DATE_TRUNC('month', CAST(now() AS DATE)-1) AS DATE)
                        THEN CAST(now() AS DATE)-1
                        ELSE CAST(DATE_TRUNC('month', CAST(P.STARTDATE AS DATE)) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS DATE)
                    END ) AS "Total New" ,
            (
                SELECT
                    -SUM(D.VALUE)
                FROM
                    KPI_DATA D,
                    KPI_FIELDS F
                WHERE
                    F.KEY = 'LOSS'
                    AND D.FIELD = F.ID
                    AND C.ID = D.CENTER
                    AND D.FOR_DATE BETWEEN P.STARTDATE AND
                    CASE
                        WHEN CAST(DATE_TRUNC('month', P.STARTDATE) AS DATE) = CAST(DATE_TRUNC('month', CAST(now() AS DATE)-1) AS DATE)
                        THEN CAST(now() AS DATE)-1
                        ELSE CAST(DATE_TRUNC('month', CAST(P.STARTDATE AS DATE)) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS DATE)
                    END ) AS "Total Cancels" ,
            (
                SELECT
                    SUM(D.VALUE)
                FROM
                    KPI_DATA D,
                    KPI_FIELDS F
                WHERE
                    F.KEY = 'NETGAIN'
                    AND D.FIELD = F.ID
                    AND C.ID = D.CENTER
                    AND D.FOR_DATE BETWEEN P.STARTDATE AND
                    CASE
                        WHEN CAST(DATE_TRUNC('month', P.STARTDATE) AS DATE) = CAST(DATE_TRUNC('month', CAST(now() AS DATE)-1) AS DATE)
                        THEN CAST(now() AS DATE)-1
                        ELSE CAST(DATE_TRUNC('month', CAST(P.STARTDATE AS DATE)) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS DATE)
                    END )           AS "Total Net Gain" ,
            "NEW"."1"               AS "1st - New",
            "LOSS"."1"              AS "1st - Cancels" ,
            "NEW"."1" -"LOSS"."1"   AS "1st - Net gains",
            "NEW"."2"               AS "2nd - New",
            "LOSS"."2"              AS "2nd - Cancels",
            "NEW"."2" - "LOSS"."2"  AS"2nd - Net gains",
            "NEW"."3"               AS "3rd - New",
            "LOSS"."3"              AS "3rd - Cancels",
            "NEW"."3" -"LOSS"."3"   AS"3rd - Net gains",
            "NEW"."4"               AS "4th - New",
            "LOSS"."4"              AS "4th - Cancels",
            "NEW"."4" -"LOSS"."4"   AS"4th - Net gains",
            "NEW"."5"               AS "5th - New",
            "LOSS"."5"              AS "5th - Cancels",
            "NEW"."5"-"LOSS"."5"    AS"5th - Net gains",
            "NEW"."6"               AS "6th - New",
            "LOSS"."6"              AS "6th - Cancels",
            "NEW"."6" -"LOSS"."6"   AS"6th - Net gains",
            "NEW"."7"               AS "7th - New",
            "LOSS"."7"              AS "7th - Cancels",
            "NEW"."7" -"LOSS"."7"   AS "7th - Net gains",
            "NEW"."8"               AS "8th - New",
            "LOSS"."8"              AS"8th - Cancels",
            "NEW"."8"- "LOSS"."8"   AS "8th - Net gains",
            "NEW"."9"               AS "9th - New",
            "LOSS"."9"              AS "9th - Cancels",
            "NEW"."9" -"LOSS"."9"   AS "9th - Net gains",
            "NEW"."10"              AS "10th - New",
            "LOSS"."10"             AS"10th - Cancels",
            "NEW"."10" -"LOSS"."10" AS"10th - Net gains",
            "NEW"."11"              AS"11th - New",
            "LOSS"."11"             AS "11th - Cancels",
            "NEW"."11" -"LOSS"."11" AS "11th - Net gains",
            "NEW"."12"              AS"12th - New",
            "LOSS"."12"             AS"12th - Cancels",
            "NEW"."12" -"LOSS"."12" AS"12th - Net gains",
            "NEW"."13"              AS "13th - New",
            "LOSS"."13"             AS"13th - Cancels",
            "NEW"."13" -"LOSS"."13" AS"13th - Net gains",
            "NEW"."14"              AS"14th - New",
            "LOSS"."14"             AS "14th - Cancels",
            "NEW"."14" -"LOSS"."14" AS "14th - Net gains",
            "NEW"."15"              AS"15th - New",
            "LOSS"."15"             AS"15th - Cancels",
            "NEW"."15" -"LOSS"."15" AS"15th - Net gains",
            "NEW"."16"              AS "16th - New",
            "LOSS"."16"             AS"16th - Cancels",
            "NEW"."16" -"LOSS"."16" AS"16th - Net gains",
            "NEW"."17"              AS"17th - New",
            "LOSS"."17"             AS "17th - Cancels",
            "NEW"."17" -"LOSS"."17" AS "17th - Net gains",
            "NEW"."18"              AS"18th - New",
            "LOSS"."18"             AS"18th - Cancels",
            "NEW"."18" -"LOSS"."18" AS"18th - Net gains",
            "NEW"."19"              AS "19th - New",
            "LOSS"."19"             AS"19th - Cancels",
            "NEW"."19" -"LOSS"."19" AS"19th - Net gains",
            "NEW"."20"              AS"20th - New",
            "LOSS"."20"             AS "20th - Cancels",
            "NEW"."20" -"LOSS"."20" AS "20th - Net gains",
            "NEW"."21"              AS"21st - New",
            "LOSS"."21"             AS"21st - Cancels",
            "NEW"."21" -"LOSS"."21" AS"21st - Net gains",
            "NEW"."22"              AS "22nd - New",
            "LOSS"."22"             AS"22nd - Cancels",
            "NEW"."22" -"LOSS"."22" AS"22nd - Net gains",
            "NEW"."23"              AS"23th - New",
            "LOSS"."23"             AS "23th - Cancels",
            "NEW"."23" -"LOSS"."23" AS "23th - Net gains",
            "NEW"."24"              AS"24th - New",
            "LOSS"."24"             AS"24th - Cancels",
            "NEW"."24" -"LOSS"."24" AS"24th - Net gains",
            "NEW"."25"              AS "25th - New",
            "LOSS"."25"             AS"25th - Cancels",
            "NEW"."25" -"LOSS"."25" AS"25th - Net gains",
            "NEW"."26"              AS"26th - New",
            "LOSS"."26"             AS "26th - Cancels",
            "NEW"."26" -"LOSS"."26" AS "26th - Net gains",
            "NEW"."27"              AS"27th - New",
            "LOSS"."27"             AS"27th - Cancels",
            "NEW"."27" -"LOSS"."27" AS"27th - Net gains",
            "NEW"."28"              AS "28th - New",
            "LOSS"."28"             AS"28th - Cancels",
            "NEW"."28" -"LOSS"."28" AS"28th - Net gains",
            "NEW"."29"              AS"29th - New",
            "LOSS"."29"             AS "29th - Cancels",
            "NEW"."29" -"LOSS"."29" AS "29th - Net gains",
            "NEW"."30"              AS"30th - New",
            "LOSS"."30"             AS"30th - Cancels",
            "NEW"."30" -"LOSS"."30" AS"30th - Net gains",
            "NEW"."31"              AS "31st - New",
            "LOSS"."31"             AS"31st - Cancels",
            "NEW"."31" -"LOSS"."31" AS"31st - Net gains"
        FROM
            (
                SELECT
                    CAST(DATE_TRUNC('month', CAST(now() AS DATE)-1-$$offset$$) AS DATE) AS STARTDATE ) P,
            CENTERS C
        JOIN
            AREA_CENTERS AC
        ON
            C.ID = AC.CENTER
        JOIN
            AREAS A
        ON
            A.ID = AC.AREA
            -- Area Managers/UK
            AND A.PARENT = 61			
        JOIN
            (
                SELECT 
					t.center,
					MAX( CASE WHEN  t.day = 1 THEN members ELSE NULL END) as "1",
					MAX( CASE WHEN  t.day = 2 THEN members ELSE NULL END) as "2",
					MAX( CASE WHEN  t.day = 3 THEN members ELSE NULL END) as "3",
					MAX( CASE WHEN  t.day = 4 THEN members ELSE NULL END) as "4",
					MAX( CASE WHEN  t.day = 5 THEN members ELSE NULL END) as "5",
					MAX( CASE WHEN  t.day = 6 THEN members ELSE NULL END) as "6",
					MAX( CASE WHEN  t.day = 7 THEN members ELSE NULL END) as "7",
					MAX( CASE WHEN  t.day = 8 THEN members ELSE NULL END) as "8",
					MAX( CASE WHEN  t.day = 9 THEN members ELSE NULL END) as "9",
					MAX( CASE WHEN  t.day = 10 THEN members ELSE NULL END) as "10",
					MAX( CASE WHEN  t.day = 11 THEN members ELSE NULL END) as "11",
					MAX( CASE WHEN  t.day = 12 THEN members ELSE NULL END) as "12",
					MAX( CASE WHEN  t.day = 13 THEN members ELSE NULL END) as "13",
					MAX( CASE WHEN  t.day = 14 THEN members ELSE NULL END) as "14",
					MAX( CASE WHEN  t.day = 15 THEN members ELSE NULL END) as "15",
					MAX( CASE WHEN  t.day = 16 THEN members ELSE NULL END) as "16",
					MAX( CASE WHEN  t.day = 17 THEN members ELSE NULL END) as "17",
					MAX( CASE WHEN  t.day = 18 THEN members ELSE NULL END) as "18",
					MAX( CASE WHEN  t.day = 19 THEN members ELSE NULL END) as "19",
					MAX( CASE WHEN  t.day = 20 THEN members ELSE NULL END) as "20",
					MAX( CASE WHEN  t.day = 21 THEN members ELSE NULL END) as "21",
					MAX( CASE WHEN  t.day = 22 THEN members ELSE NULL END) as "22",
					MAX( CASE WHEN  t.day = 23 THEN members ELSE NULL END) as "23",
					MAX( CASE WHEN  t.day = 24 THEN members ELSE NULL END) as "24",
					MAX( CASE WHEN  t.day = 25 THEN members ELSE NULL END) as "25",
					MAX( CASE WHEN  t.day = 26 THEN members ELSE NULL END) as "26",
					MAX( CASE WHEN  t.day = 27 THEN members ELSE NULL END) as "27",
					MAX( CASE WHEN  t.day = 28 THEN members ELSE NULL END) as "28",
					MAX( CASE WHEN  t.day = 29 THEN members ELSE NULL END) as "29",
					MAX( CASE WHEN  t.day = 30 THEN members ELSE NULL END) as "30",					
					MAX( CASE WHEN  t.day = 31 THEN members ELSE NULL END) as "31"					
				FROM
				(
					SELECT
						MC.CENTER                                                     AS CENTER,
						MC.VALUE                                                      AS MEMBERS,
						(MC.FOR_DATE- P.STARTDATE)+1 								  AS DAY
					FROM
						(
							SELECT
								CAST(DATE_TRUNC('month', CAST(now() AS DATE)-1-$$offset$$) AS DATE) AS STARTDATE ) P,
						-- member field
						KPI_FIELDS MF
					JOIN
						-- members current
						KPI_DATA MC
					ON
						MC.FIELD = MF.ID
					WHERE
						MF.KEY = 'POSITIVEGAIN'
						AND MC.FOR_DATE BETWEEN P.STARTDATE AND
						CASE
							WHEN CAST(DATE_TRUNC('month', P.STARTDATE) AS DATE) = CAST(DATE_TRUNC('month', CAST(now() AS DATE)-1) AS DATE)
							THEN CAST(now() AS DATE)-1
							ELSE CAST(DATE_TRUNC('month', CAST(P.STARTDATE AS DATE)) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS DATE)
						END
					) t GROUP BY t.center) "NEW"
        ON
            C.ID ="NEW".CENTER
        JOIN
            (
				SELECT 
					t.center,
					MAX( CASE WHEN  t.day = 1 THEN members ELSE NULL END) as "1",
					MAX( CASE WHEN  t.day = 2 THEN members ELSE NULL END) as "2",
					MAX( CASE WHEN  t.day = 3 THEN members ELSE NULL END) as "3",
					MAX( CASE WHEN  t.day = 4 THEN members ELSE NULL END) as "4",
					MAX( CASE WHEN  t.day = 5 THEN members ELSE NULL END) as "5",
					MAX( CASE WHEN  t.day = 6 THEN members ELSE NULL END) as "6",
					MAX( CASE WHEN  t.day = 7 THEN members ELSE NULL END) as "7",
					MAX( CASE WHEN  t.day = 8 THEN members ELSE NULL END) as "8",
					MAX( CASE WHEN  t.day = 9 THEN members ELSE NULL END) as "9",
					MAX( CASE WHEN  t.day = 10 THEN members ELSE NULL END) as "10",
					MAX( CASE WHEN  t.day = 11 THEN members ELSE NULL END) as "11",
					MAX( CASE WHEN  t.day = 12 THEN members ELSE NULL END) as "12",
					MAX( CASE WHEN  t.day = 13 THEN members ELSE NULL END) as "13",
					MAX( CASE WHEN  t.day = 14 THEN members ELSE NULL END) as "14",
					MAX( CASE WHEN  t.day = 15 THEN members ELSE NULL END) as "15",
					MAX( CASE WHEN  t.day = 16 THEN members ELSE NULL END) as "16",
					MAX( CASE WHEN  t.day = 17 THEN members ELSE NULL END) as "17",
					MAX( CASE WHEN  t.day = 18 THEN members ELSE NULL END) as "18",
					MAX( CASE WHEN  t.day = 19 THEN members ELSE NULL END) as "19",
					MAX( CASE WHEN  t.day = 20 THEN members ELSE NULL END) as "20",
					MAX( CASE WHEN  t.day = 21 THEN members ELSE NULL END) as "21",
					MAX( CASE WHEN  t.day = 22 THEN members ELSE NULL END) as "22",
					MAX( CASE WHEN  t.day = 23 THEN members ELSE NULL END) as "23",
					MAX( CASE WHEN  t.day = 24 THEN members ELSE NULL END) as "24",
					MAX( CASE WHEN  t.day = 25 THEN members ELSE NULL END) as "25",
					MAX( CASE WHEN  t.day = 26 THEN members ELSE NULL END) as "26",
					MAX( CASE WHEN  t.day = 27 THEN members ELSE NULL END) as "27",
					MAX( CASE WHEN  t.day = 28 THEN members ELSE NULL END) as "28",
					MAX( CASE WHEN  t.day = 29 THEN members ELSE NULL END) as "29",
					MAX( CASE WHEN  t.day = 30 THEN members ELSE NULL END) as "30",					
					MAX( CASE WHEN  t.day = 31 THEN members ELSE NULL END) as "31"				
				FROM
				(
					SELECT
						MC.CENTER                         AS CENTER,
						-MC.VALUE                         AS MEMBERS,
						(MC.FOR_DATE- P.STARTDATE+1) AS DAY
					FROM
						(
							SELECT
								CAST(DATE_TRUNC('month', CAST(now() AS DATE)-1-$$offset$$) AS DATE) AS STARTDATE ) P,
						-- member field
						KPI_FIELDS MF
					JOIN
						-- members current
						KPI_DATA MC
					ON
						MC.FIELD = MF.ID
					WHERE
						MF.KEY = 'LOSS'
						AND MC.FOR_DATE BETWEEN P.STARTDATE AND
						CASE
							WHEN CAST(DATE_TRUNC('month', P.STARTDATE) AS DATE) = CAST(DATE_TRUNC('month', CAST(now() AS DATE)-1) AS DATE)
							THEN CAST(now() AS DATE)-1
							ELSE CAST(DATE_TRUNC('month', CAST(P.STARTDATE AS DATE)) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS DATE)
						END 
				)t GROUP BY t.center) "LOSS"
        ON
            C.ID = "LOSS".CENTER
        WHERE
            (
                SELECT
                    SUM(D.VALUE)
                FROM
                    KPI_DATA D,
                    KPI_FIELDS F
                WHERE
                    -- F.KEY = 'POSITIVEGAIN' AND 
					D.FIELD = F.ID
                    AND C.ID = D.CENTER
                    AND D.FOR_DATE BETWEEN P.STARTDATE AND
                    CASE
                        WHEN CAST(DATE_TRUNC('month', CAST(P.STARTDATE AS DATE)) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS DATE) = CAST(DATE_TRUNC('month', CAST(now() AS DATE)) + INTERVAL '1 MONTH' - INTERVAL '1 DAY'  AS DATE)
                        THEN CAST(now() AS DATE)-1
                        ELSE CAST(DATE_TRUNC('month', CAST(P.STARTDATE AS DATE)) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS DATE)
                    END ) > 0
            AND C.ID IN ( $$scope$$ ) ) TB
GROUP BY
    grouping sets ( (REGION,CENTER,C_STATUS), () )
ORDER BY
    1,2 DESC