SELECT
    i1."Extenal ID"
  , i1."P number"
  , i1."First Name"
  , i1."Surname"
  , i1."Mobile"
  , i1."Email"
  , i1."Male / Female"
  , i1."Date of Birth"
  , i1."Home club"
  , i1."Club no"
  , i1."Price paid"
  , i1."Date of purchase"
  , i1."Creation date"
  , i1."Start date of trial"
  , i1."Stop date of trial"
  , i1."Trial days"
  , i1."Marketing"
    --  , i1."Code used"
  ,i1."taken an EFT membership"
  ,COUNT(1) vistits
    --  , i1."CENTER"
    --  , i1."ID"
    --  , i1."START_DATE"
    --  , i1."END_DATE"
FROM
    (
        SELECT
            p.EXTERNAL_ID "Extenal ID"
          , p.CENTER || 'p' || p.ID "P number"
          , p.FIRSTNAME "First Name"
          , p.LASTNAME           "Surname"
          , ExtPhoneSMS.TXTVALUE "Mobile"
          , ExtEMAIL.TXTVALUE    "Email"
          , p.SEX "Male / Female"
          , p.BIRTHDATE "Date of Birth"
          , c.SHORTNAME "Home club"
          , p.CENTER "Club no"
          , SUM(invl.TOTAL_AMOUNT) "Price paid"
          , ss.SALES_DATE "Date of purchase"
          , ss.SALES_DATE "Creation date"
          , ss.START_DATE "Start date of trial"
          , ss.END_DATE "Stop date of trial"
          , ss.END_DATE - ss.START_DATE AS "Trial days"
          , ExtIsAcceptingEmailNewsLetters.TXTVALUE "Marketing"
          , NULL "Code used"
          ,(
                SELECT
                    MAX(1)
                FROM
                    SUBSCRIPTIONS sEFT
                JOIN
                    SUBSCRIPTIONTYPES stEFT
                ON
                    stEFT.CENTER = sEFT.SUBSCRIPTIONTYPE_CENTER
                    AND stEFT.ID = sEFT.SUBSCRIPTIONTYPE_ID
                    AND stEFT.ST_TYPE = 1
                WHERE
                    sEFT.OWNER_CENTER = p.CENTER
                    AND sEFT.OWNER_ID = p.ID
                    AND sEFT.START_DATE > s.START_DATE ) "taken an EFT membership"
          ,p.CENTER
          ,p.ID
          ,s.START_DATE
          ,s.END_DATE
        FROM
            SUBSCRIPTION_SALES ss
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = ss.SUBSCRIPTION_CENTER
            AND s.ID = ss.SUBSCRIPTION_ID
        JOIN
            SUBSCRIPTIONPERIODPARTS spp
        ON
            spp.CENTER = s.CENTER
            AND spp.ID = s.ID
        JOIN
            SPP_INVOICELINES_LINK link
        ON
            link.PERIOD_CENTER = spp.CENTER
            AND link.PERIOD_ID = spp.ID
            AND link.PERIOD_SUBID = spp.SUBID
        JOIN
            INVOICELINES invl
        ON
            invl.CENTER = link.INVOICELINE_CENTER
            AND invl.ID = link.INVOICELINE_ID
            AND invl.SUBID = link.INVOICELINE_SUBID
        JOIN
            PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.id = s.OWNER_ID
        LEFT JOIN
            PERSON_EXT_ATTRS ExtIsAcceptingThirdPartyOffers
        ON
            ExtIsAcceptingThirdPartyOffers.PERSONCENTER = p.CENTER
            AND ExtIsAcceptingThirdPartyOffers.PERSONID = p.ID
            AND ExtIsAcceptingThirdPartyOffers.NAME = 'eClubIsAcceptingThirdPartyOffers'
        LEFT JOIN
            PERSON_EXT_ATTRS ExtIsAcceptingEmailNewsLetters
        ON
            ExtIsAcceptingEmailNewsLetters.PERSONCENTER = p.CENTER
            AND ExtIsAcceptingEmailNewsLetters.PERSONID = p.ID
            AND ExtIsAcceptingEmailNewsLetters.NAME = 'eClubIsAcceptingEmailNewsLetters'
        JOIN
            CENTERS c
        ON
            c.id = p.CENTER
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.id = s.SUBSCRIPTIONTYPE_ID
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.id = s.SUBSCRIPTIONTYPE_ID
        LEFT JOIN
            PERSON_EXT_ATTRS ExtEmail
        ON
            ExtEmail.PERSONCENTER = p.CENTER
            AND ExtEmail.PERSONID = p.ID
            AND ExtEmail.NAME = '_eClub_Email'
        LEFT JOIN
            PERSON_EXT_ATTRS ExtPhoneSMS
        ON
            ExtPhoneSMS.PERSONCENTER = p.CENTER
            AND ExtPhoneSMS.PERSONID = p.ID
            AND ExtPhoneSMS.NAME = '_eClub_PhoneSMS'
        WHERE
            st.PERIODUNIT = 1
            AND st.PERIODCOUNT IN (1,3,7,10)
            AND st.ST_TYPE = 0
            AND ss.CREDITED IS NULL
            AND p.CENTER IN ($$scope$$)
            AND ss.SALES_DATE BETWEEN $$sold_from$$ AND $$sold_to$$
        GROUP BY
            p.EXTERNAL_ID
          , p.CENTER
          ,p.ID
          , p.FIRSTNAME
          , p.LASTNAME
          , ExtPhoneSMS.TXTVALUE
          , ExtEMAIL.TXTVALUE
          , p.SEX
          , p.BIRTHDATE
            --,i1.trial_days
          , c.SHORTNAME
          , p.CENTER
          , ss.SALES_DATE
          , ss.SALES_DATE
          , ss.START_DATE
          , ss.END_DATE
          , ExtIsAcceptingEmailNewsLetters.TXTVALUE
          ,s.START_DATE
          ,s.END_DATE ) i1
LEFT JOIN
    CHECKINS cin
ON
    cin.PERSON_CENTER = i1.CENTER
    AND cin.PERSON_ID = i1.id
    AND cin.CHECKIN_TIME BETWEEN dateToLongC(TO_CHAR(i1.START_DATE,'YYYY-MM-dd HH24:MI'),i1.center) AND dateToLongC(TO_CHAR(i1.end_date,'YYYY-MM-dd HH24:MI'),i1.center)
GROUP BY
    i1."Extenal ID"
  , i1."P number"
  , i1."First Name"
  , i1."Surname"
  , i1."Mobile"
  , i1."Email"
  , i1."Trial days"
  , i1."Male / Female"
  , i1."Date of Birth"
  , i1."Home club"
  , i1."Club no"
  , i1."Price paid"
  , i1."Date of purchase"
  , i1."Creation date"
  , i1."Start date of trial"
  , i1."Stop date of trial"
  , i1."Marketing"
  ,i1."taken an EFT membership"
  , i1."Code used"