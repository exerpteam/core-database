SELECT
   do_not_call_phonenumbers.creation_date,
   do_not_call_phonenumbers.state,
   do_not_call_phonenumbers.phone_number,
   do_not_call_phonenumbers.type,
   do_not_call_phonenumbers.source
FROM
    goodlife.do_not_call_phonenumbers
where do_not_call_phonenumbers.type = 'INTERNAL'    
 