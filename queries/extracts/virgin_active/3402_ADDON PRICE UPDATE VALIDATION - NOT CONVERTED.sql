SELECT
    t.OLD_MEM_ID,
    t.OLD_SUB_ID
FROM
    TEMP_PT_PRICE_UPDATES t
left join CONVERTER_ENTITY_STATE con on 
    con.WRITERNAME = 'ClubLeadPersonWriter'
    AND con.ENTITYTYPE = 'person'
    and con.OLDENTITYID   = 'CC_' || t.OLD_MEM_ID
where con.OLDENTITYID is null    