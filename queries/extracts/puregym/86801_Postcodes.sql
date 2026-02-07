WITH postcodes AS
(
SELECT
UPPER(t1.postcode) AS post_codes
FROM
(
SELECT
REPLACE(REPLACE(REPLACE((regexp_split_to_table(CAST((:postcode) AS TEXT), ',')), '"', ''), '(', ''), ')', '') AS postcode
) t1
)
SELECT
zipcode AS "Post code",
city AS "City",
county AS "County"
FROM
zipcodes zi
JOIN
postcodes pc
ON
pc.post_codes = zi.zipcode