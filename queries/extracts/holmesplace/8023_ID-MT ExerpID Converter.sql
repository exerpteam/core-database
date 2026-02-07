SELECT
    pea.TXTVALUE,
    pea.PERSONCENTER||'p'||pea.PERSONID
   
FROM
    HP.PERSON_EXT_ATTRS pea

WHERE
    pea.NAME = '_eClub_OldSystemPersonId'
    and (pea.PERSONCENTER,pea.PERSONID) in ($$Exerp_ID$$)
