SELECT
    cmp.CENTER || 'p' ||    cmp.ID comp_id,
    cmp.LASTNAME comp_name,
    ca.NAME ca_name,
    DECODE(ca.STATE, 0, 'Under target', 1, 'Active', 2, 'Stop new', 3, 'Old', 4, 'Awaiting activation', 5, 'Blocked', 6, 'Deleted') CA_STATE,
    ca.BLOCKED,
    ca.DOCUMENTATION_REQUIRED,
    ca.DOCUMENTATION_INTERVAL_UNIT,
    ca.DOCUMENTATION_INTERVAL,
    ca.STOP_NEW_DATE,
    ca.AVAILABILITY
FROM
    COMPANYAGREEMENTS ca
join PERSONS cmp on cmp.CENTER = ca.CENTER and cmp.ID = ca.ID
where ca.BLOCKED = 0 and ca.center in (:scope)