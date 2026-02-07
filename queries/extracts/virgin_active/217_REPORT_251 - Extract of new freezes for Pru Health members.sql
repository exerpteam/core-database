 SELECT
     p.CENTER "Club",
     'Extended atttribute?' "Pru Entity NUMBER",
     p.SEX "Gender",
     SUBSTR(p.FIRSTNAME,0,1) || SUBSTR(p.LASTNAME,0,1) "Initials",
     p.FULLNAME "FULL Name",
     p.BIRTHDATE "DATE OF Birth",
     p.CENTER || 'p' || p.ID "Exerp Member ID",
     p.ZIPCODE "Address Postcode",
     phone.TXTVALUE "Home Telephone NUMBER",
     mob.TXTVALUE "Mobile Telephone NUMBER",
     'Extended attribute? ' "Plan ID",
     'For just one membership or all?' "Discount",
     'For just one membership or all?' "Monthly MEMBERSHIP Dues Amount",
     sbp.START_DATE "Effective Date."
 FROM
     SUBSCRIPTIONS s
 JOIN RELATIVES rel
 ON
     rel.RTYPE = 2
     AND rel.STATUS = 1
     AND rel.RELATIVECENTER = s.OWNER_CENTER
     AND rel.RELATIVEID = s.OWNER_ID
     /* Needs to be set agains PRU company */
     AND rel.CENTER > 0
     AND rel.ID > 0
     /* Freeze in upcoming month needs to be defined. Should it just be new ones or freezes that have the emd date in the following period but start date before? */
 JOIN SUBSCRIPTION_BLOCKED_PERIOD sbp
 ON
     sbp.SUBSCRIPTION_CENTER = s.CENTER
     AND sbp.SUBSCRIPTION_ID = s.ID
     /* Below is relative to when it's run */
     AND sbp.START_DATE >= to_date(TO_CHAR(add_months(current_timestamp,1),'yyyy-MM') || '-01','yyyy-MM-dd')
     AND sbp.START_DATE < to_date(TO_CHAR(add_months(current_timestamp,2),'yyyy-MM') || '-01','yyyy-MM-dd')
     AND sbp.STATE = 'ACTIVE'
 JOIN PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
     AND p.ID = s.OWNER_ID
 LEFT JOIN PERSON_EXT_ATTRS phone
 ON
     phone.PERSONCENTER = p.CENTER
     AND phone.PERSONID = p.ID
     AND phone.NAME = '_eClub_PhoneHome'
 LEFT JOIN PERSON_EXT_ATTRS mob
 ON
     mob.PERSONCENTER = p.CENTER
     AND mob.PERSONID = p.ID
     AND mob.NAME = '_eClub_PhoneSMS'
