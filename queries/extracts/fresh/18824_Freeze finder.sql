WITH
    params AS
    (
        SELECT
            /*+ materialize */
            to_date('12-03-2020', 'dd-MM-yyyy') AS StartDate,
            to_date('27-03-2020', 'dd-MM-yyyy') AS EndDate
    )

SELECT
    sub.CENTER || 'ss' || sub.ID            AS SUBSCRIPTION_ID,
    sub.OWNER_CENTER || 'p' || sub.OWNER_ID AS MEMBER,
    sub.*
FROM
    SUBSCRIPTIONS sub
JOIN
    SUBSCRIPTION_FREEZE_PERIOD sfp
ON
    sub.CENTER = sfp.SUBSCRIPTION_CENTER
AND sub.ID = sfp.SUBSCRIPTION_ID
AND sfp.start_date <= params.EndDate
AND sfp.state = 'ACTIVE'
AND sfp.end_date >= params.StartDate