SELECT
    
    pemail.personcenter || 'p' || pemail.personid AS PersonId,
pemail.*
FROM
    person_ext_attrs pemail
where 
    pemail.NAME = '_eClub_Email'
    AND pemail.txtvalue = 'vtpaulsen@gmail.com'