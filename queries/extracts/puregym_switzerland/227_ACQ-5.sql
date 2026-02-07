WITH
    CHILD_PRIV_SETS AS MATERIALIZED
    (
        SELECT
            psi.parent_id,
            ps_child.id,
            ps_child.FREQUENCY_RESTRICTION_COUNT,
            ps_child.FREQUENCY_RESTRICTION_VALUE,
            ps_child.FREQUENCY_RESTRICTION_UNIT
        FROM
            privilege_sets ps
        JOIN
            privilege_set_includes psi
        ON
            psi.parent_id = ps.id
        JOIN
            privilege_sets ps_child
        ON
            ps_child.id = psi.child_id
    )
SELECT
    Child_privs.FREQUENCY_RESTRICTION_COUNT as "Count",
    Child_privs.FREQUENCY_RESTRICTION_VALUE as "Occurrence",
    CASE
        WHEN Child_privs.FREQUENCY_RESTRICTION_UNIT = 0
        THEN 'Week'
        WHEN Child_privs.FREQUENCY_RESTRICTION_UNIT = 1
        THEN 'Day'
        WHEN Child_privs.FREQUENCY_RESTRICTION_UNIT = 2
        THEN 'Month'
        WHEN Child_privs.FREQUENCY_RESTRICTION_UNIT = 3
        THEN 'Year'
        ELSE NULL
    END AS "Unit"
FROM
    (
        SELECT
            CASE
                WHEN cps.parent_id IS NULL
                THEN ps.FREQUENCY_RESTRICTION_COUNT
                ELSE cps.FREQUENCY_RESTRICTION_COUNT
            END AS FREQUENCY_RESTRICTION_COUNT,
            CASE
                WHEN cps.parent_id IS NULL
                THEN ps.FREQUENCY_RESTRICTION_VALUE
                ELSE cps.FREQUENCY_RESTRICTION_VALUE
            END AS FREQUENCY_RESTRICTION_VALUE,
            CASE
                WHEN cps.parent_id IS NULL
                THEN ps.FREQUENCY_RESTRICTION_UNIT
                ELSE cps.FREQUENCY_RESTRICTION_UNIT
            END AS FREQUENCY_RESTRICTION_UNIT
        FROM
            privilege_sets ps
        LEFT JOIN
            CHILD_PRIV_SETS cps
        ON
            cps.parent_id = ps.id
        WHERE
            ps.id = CAST(:PrivilegeSetId AS INTEGER)) Child_privs