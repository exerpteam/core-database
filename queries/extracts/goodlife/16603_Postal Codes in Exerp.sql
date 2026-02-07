select

zipcode as "Postal code"
,city as "City"
,county as "County"
,province as "Province"

from zipcodes

where

zipcode in (:Postal_Codes)

