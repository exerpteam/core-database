SELECT 
        CENTER_ID,
        PERSON_ID,
        CHECK_IN_DATE,
        CHECK_IN_RESULT,
        CHECK_IN_TIME
FROM
        BI_VISIT_LOG
WHERE
        CHECK_IN_RESULT = 'ACCESS_GRANTED' and to_date(CHECK_IN_DATE,'yyyy-MM-dd') > $$seedate$$ and CENTER_ID in ($$scope$$)