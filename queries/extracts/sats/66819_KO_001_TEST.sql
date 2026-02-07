SELECT
    biview.PERSON_ID,
    biview.HOME_CENTER_ID,
    biview.HOME_CENTER_PERSON_ID,
   
    biview.COUNTRY_ID,
    biview.POSTAL_CODE,
    biview.CITY,
    biview.DATE_OF_BIRTH,
    biview.GENDER,
    biview.PERSON_TYPE,
    biview.PERSON_STATUS S,
    biview.CREATION_DATE,
    biview.PAYER_PERSON_ID,
    biview.COMPANY_ID,
    biview.COUNTY,
    biview.STATE,
    biview.ETS

FROM
    SATS.BI_PERSONS biview

WHERE
    biview.HOME_CENTER_ID IN ($$Scope$$)

AND
	biview.PERSON_STATUS = (Active)