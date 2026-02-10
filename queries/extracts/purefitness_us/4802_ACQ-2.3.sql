-- The extract is extracted from Exerp on 2026-02-08
-- Gets Privilege Discount data for multiple Privilege Sets. Takes in a comma separated list of Privilege Set Ids
WITH
    globalRounding AS
    (
        SELECT
            txtvalue AS rounding
        FROM
            systemproperties
        WHERE
            globalid = 'FINANCE_ROUND'
        AND scope_type = :scope_type
        AND scope_id = :scope_id
        LIMIT 1
    ),
    privilegeSetIds AS (
        SELECT UNNEST(string_to_array(:privilegeset_ids, ',')::integer[]) AS id
    ),
    filteredProductPrivileges AS (
        SELECT DISTINCT
            PRIVILEGE_SET,
            REF_GLOBALID,
            REF_TYPE,
            REF_ID,
            PRICE_MODIFICATION_NAME,
            PRICE_MODIFICATION_AMOUNT,
            VALID_FOR,
            PRICE_MODIFICATION_ROUNDING
        FROM PRODUCT_PRIVILEGES
        WHERE VALID_TO IS NULL
    ),
    filteredPrivilegeSets AS (
        SELECT *
        FROM PRIVILEGE_SETS
        WHERE id IN (SELECT id FROM privilegeSetIds)
    ),
    distinctProducts AS (
        SELECT DISTINCT globalid
        FROM products
    ),
    distinctMasterProductRegister AS (
        SELECT DISTINCT globalid
        FROM MASTERPRODUCTREGISTER
    )
SELECT DISTINCT
    privilegeSet.id                                                                               AS "PrivilegeSetId",
    product.globalid                                                                              AS "ProductGlobalId",
    productGroup.id                                                                               AS "ProductGroupId",
    productPrivilege.PRICE_MODIFICATION_NAME                                                      AS "DiscountType",
    productPrivilege.PRICE_MODIFICATION_AMOUNT                                                    AS "DiscountAmount",
    productPrivilege.VALID_FOR                                                                    AS "ValidFor",
    COALESCE(productPrivilege.PRICE_MODIFICATION_ROUNDING, (SELECT rounding FROM globalRounding)) AS "Rounding"
FROM
    filteredPrivilegeSets privilegeSet
JOIN
    filteredProductPrivileges productPrivilege
ON
    privilegeSet.id = productPrivilege.PRIVILEGE_SET
LEFT JOIN
    distinctMasterProductRegister masterProductRegister
ON
    productPrivilege.REF_GLOBALID = masterProductRegister.globalid
LEFT JOIN
    distinctProducts product
ON
    product.globalid = masterProductRegister.globalid
AND productPrivilege.ref_type = 'GLOBAL_PRODUCT'
LEFT JOIN
    PRODUCT_GROUP productGroup
ON
    productPrivilege.ref_id = productGroup.id
AND productPrivilege.ref_type = 'PRODUCT_GROUP'
