WITH
    params AS
    (
        SELECT
            c.id AS CENTERID,
            datetolongc(TO_CHAR(to_date($$start_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) AS FROM_DATE,
            datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS TO_DATE
        FROM
            centers c
        WHERE
            c.id IN (
    58,
    62,
    79,
    104,
    131,
    185,
    202,
    241,
    246,
    299,
    340,
    341,
    347,
    5,
    29,
    30,
    32,
    38,
    47,
    55,
    60,
    106,
    110,
    112,
    138,
    151,
    155,
    169,
    173,
    175,
    180,
    181,
    182,
    183,
    184,
    186,
    187,
    188,
    189,
    212,
    234,
    235,
    247,
    255,
    261,
    262,
    264,
    266,
    268,
    270,
    273,
    336,
    339,
    870
    )
)
select
    TO_CHAR(longtodateC(c.valid_until,c.center), 'YYYY-MM-DD HH24:MI') as valid_until,
    c.center||'cc'||c.id||'cc'||c.subid as clipid,p.external_id,
    c.clips_left
    from clipcards c join params on c.center = centerid
     join persons p on p.center = c.owner_center and p.id = c.owner_id
    where c.valid_until between FROM_DATE and TO_DATE
    and c.finished = false
    and c.clips_left >0
    order by 1,2,3