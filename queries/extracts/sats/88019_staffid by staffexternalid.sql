select
ext.personcenter as "staffPerson center",
ext.personid as "staffPerson id"


from person_ext_attrs ext

where
ext.txtvalue in (:staffexternalid)
and ext.name = '_eClub_StaffExternalId'