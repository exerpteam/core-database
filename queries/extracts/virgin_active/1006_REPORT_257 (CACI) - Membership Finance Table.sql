SELECT
    p.UNIQUE_KEY "Members ID",
    p.CENTER || 'p' || p.ID "SysMemberID",
    '?' "Date",
    '?' "Membership Type",
    null "PT",
    null "Beauty",
    null "Lockers",
    null "Towels",
    null "Swim",
    '?' "Subscription"
FROM
    PERSONS_VW p