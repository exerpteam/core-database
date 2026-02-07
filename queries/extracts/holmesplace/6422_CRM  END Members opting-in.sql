select 
p.CENTER as Person_Center,
p.ID as PERSON_ID,
p.CENTER || 'p' || p.ID AS PERSON_KEY,
p.FIRSTNAME,
p.LASTNAME,
email.TXTVALUE as email,
DECODE (allowemail.TXTVALUE, 'false','opt-out', 'true','opt-in') AS opt_status,
DECODE (ta.TASK_CATEGORY_ID, '205','MEMEBER', '200','HOT', '201','WARM', '202','FUTURE', '203','END', '204','COLD') AS STATUS,
longtodate(ta.CREATION_TIME) as Task_Start_Date,
ta.STATUS as Task_Status

from HP.PERSONS p


join HP.TASKS ta
on ta.PERSON_CENTER = p.CENTER
and ta.PERSON_ID = p.ID

left join HP.PERSON_EXT_ATTRS email
on email.PERSONCENTER = p.CENTER
and email.PERSONID = p.ID
and email.NAME = '_eClub_Email'

left join HP.PERSON_EXT_ATTRS allowemail
on allowemail.PERSONCENTER = p.CENTER
and allowemail.PERSONID = p.ID
and allowemail.NAME = '_eClub_AllowedChannelEmail'

where p.CENTER in (:center)
and ta.TASK_CATEGORY_ID = 203
and allowemail.TXTVALUE = 'true'


