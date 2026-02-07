SELECT
    c.shortname,a.name,a1.name
FROM
    VA.CENTERS c
JOIN
    VA.AREA_CENTERS ac
ON
    ac.center = c.id
    join VA.AREAS a on a.id = ac.area
    join VA.AREAS a1 on a1.id = 1
WHERE
    c.id IN (41,
           420,
           429,
           28,
           451,
           424,
           25,
           417,
           412,
           446,
           413,
           32,
           418,
           439,
           426,
           20,
           404,
           23,
           73,
           428,
           414,
           37,
           53,
           444,
           409,
           17,
           63,
           14,
           22,
           44,
           423,
           54,
           70,
           433,
           49,
           24,
           42,
           5,
           8,
           449,
           11,
           431,
           66,
           26,
           18,
           402,
           46,
           430,
           447,
           19,
           416,
           432)