-- The extract is extracted from Exerp on 2026-02-08
-- Find clipcards ending in the specified date range.
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
            c.id IN ($$scope$$)

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