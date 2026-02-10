-- The extract is extracted from Exerp on 2026-02-08
-- Pulls a list of all zipcodes in Exerp.
select

zipcode as "Postal code"
,city as "City"
,county as "County"
,province as "Province"

from zipcodes

where

zipcode in (:Postal_Codes)

