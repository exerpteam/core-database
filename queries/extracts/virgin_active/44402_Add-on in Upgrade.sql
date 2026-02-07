 SELECT
    c.SHORTNAME                                                                  AS "CLUB",
    s.owner_center||'p'||s.OWNER_ID                                              AS "MEMBER ID",
    pr.name                                                                      AS "SUBSCRIPTION NAME",
    prod_old.name                                                                AS "NAME OLD ADD ON",
    TO_CHAR(sa_old.START_DATE,'DD-MM-YYYY')                                      AS "START DATE OLD ADD ON",
    TO_CHAR(sa_old.END_DATE,'DD-MM-YYYY')                                        AS "STOP DATE OLD ADD ON",
    prod_new.name                                                                AS "NAME NEW ADD ON",
    TO_CHAR(sa_new.START_DATE,'DD-MM-YYYY')                                      AS "START DATE NEW ADD ON",
    TO_CHAR(sa_new.END_DATE,'DD-MM-YYYY')                                        AS "STOP DATE NEW ADD ON",
    TO_CHAR(LONGTODATEC(sa_new.CREATION_TIME,sa_new.CENTER_ID),'DD-MM-YYYY')     AS "DATE SALE NEW ADD ON",
    staff.FULLNAME                                                               AS "STAFF NAME"
 FROM
    SUBSCRIPTIONS s
 JOIN
    PRODUCTS pr
 ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN
    SUBSCRIPTION_ADDON sa_new
 ON
    s.CENTER = sa_new.SUBSCRIPTION_CENTER
    AND s.ID = sa_new.SUBSCRIPTION_ID
 JOIN
    MASTERPRODUCTREGISTER mpr_new
 ON
    mpr_new.id = sa_new.ADDON_PRODUCT_ID
 JOIN
    PRODUCTS prod_new
 ON
    prod_new.center = sa_new.CENTER_ID
    AND prod_new.GLOBALID = mpr_new.GLOBALID
 JOIN
    SUBSCRIPTION_ADDON sa_old
 ON
    s.CENTER = sa_old.SUBSCRIPTION_CENTER
    and s.ID = sa_old.SUBSCRIPTION_ID
    AND sa_new.START_DATE - sa_old.END_DATE < 3
    AND sa_new.START_DATE - sa_old.END_DATE >= 0
 JOIN
     MASTERPRODUCTREGISTER mpr_old
 ON
     mpr_old.id = sa_old.ADDON_PRODUCT_ID
 JOIN
     PRODUCTS prod_old
 ON
     prod_old.center = sa_old.CENTER_ID
     AND prod_old.GLOBALID = mpr_old.GLOBALID
 JOIN
     CENTERS c
 ON
     c.ID = sa_new.CENTER_ID
 JOIN
     EMPLOYEES e
 ON
     e.CENTER = sa_new.EMPLOYEE_CREATOR_CENTER
     AND e.ID = sa_new.EMPLOYEE_CREATOR_ID
 JOIN
     PERSONS staff
 ON
     e.PERSONCENTER = staff.CENTER
     AND e.PERSONID = staff.ID
 WHERE
     sa_new.CANCELLED = 0
     AND sa_old.CANCELLED = 0
     AND sa_new.CENTER_ID in (:Scope)
     AND sa_new.CREATION_TIME > :Date_From
     AND sa_new.CREATION_TIME < :Date_To + 24*3600*1000
 AND (
 ((prod_old.NAME like '%Premium%' and prod_old.NAME not like '%Plus%') AND (prod_new.NAME like '%Premium Plus%'))  --from Premium to Premium Plus
 OR
 ((prod_old.NAME like '%Premium Plus%') AND (prod_new.NAME like '%Collection%'))  --  'From Premium Plus to Collection'
 OR
 ((prod_old.NAME like '%Premium%' and prod_old.NAME not like '%Plus%') AND (prod_new.NAME like '%Collection%'))     -- From Premium to Collection
 OR
 ((prod_old.NAME like '%Life%') AND (prod_new.NAME like '%Collection%' OR prod_new.NAME like '%Premium%')) --    From Life to other
 )
