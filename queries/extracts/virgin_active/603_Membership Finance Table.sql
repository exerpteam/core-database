SELECT
    p.UNIQUE_KEY "Members ID",
    p.CENTER || 'p' || p.ID "SysMemberID",
    '?' "Date",
    '?' "Membership Type",
    '?' "PT",
    '?' "Beauty",
    '?' "Lockers",
    '?' "Towels",
    '?' "Swim",
    '?' "Subscription"
FROM
    PERSONS_VW p