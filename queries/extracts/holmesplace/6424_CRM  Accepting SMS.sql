select 

p.FIRSTNAME,
p.LASTNAME,
mobile.TXTVALUE as Mobile,
DECODE(sms.TXTVALUE, 'true', 'Yes', 'false', 'No') as AllowSMS

from HP.TASKS ta

join HP.PERSONS p
on p.CENTER = ta.PERSON_CENTER
and p.ID = ta.PERSON_ID

left join HP.PERSON_EXT_ATTRS mobile
on mobile.PERSONCENTER = p.CENTER
and mobile.PERSONID = p.ID
and mobile.NAME = '_eClub_PhoneSMS'

left join HP.PERSON_EXT_ATTRS sms
on sms.PERSONCENTER = p.CENTER
and sms.PERSONID = p.ID
and sms.NAME = '_eClub_AllowedChannelSMS'

Where ta.TASK_CATEGORY_ID in (:catagory)
and ta.PERSON_CENTER in (:scope)
