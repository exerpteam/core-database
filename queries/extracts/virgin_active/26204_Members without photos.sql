 SELECT
     --p.CENTER                                                                                                                                                                          "ClubID",
     c.shortname                                                                                                                                                                       "Club",
     p.center||'p'||p.id                                                                                                                                                               "MembersshipNumber",
     CASE  p.STATUS  WHEN 0 THEN  'Lead'  WHEN 1 THEN  'Active'  WHEN 2 THEN  'Inactive'  WHEN 3 THEN  'TemporaryInactive'  WHEN 4 THEN  'Transferred'  WHEN 5 THEN  'Duplicate'  WHEN 6 THEN  'Prospect'  WHEN 7 THEN  'Deleted'  WHEN 8 THEN  'Anonymised'  WHEN 9 THEN  'Contact' END AS STATUS
     -- title.TXTVALUE "Title",
     --p.firstname "MemberFirstName",
    -- p.lastname  "MemberLastName",
     -- p.address1 "Address1",
     -- p.address2 "Address2",
     -- p.address3 "Address3",
     -- p.zipcode "Postcode",
     -- p.city "City",
     -- email.TXTVALUE "Email",
     --p.birthdate                                                                               "DOB",
    -- face.MIMETYPE                                                                             "Photo",
     --face1.mimevalue,
   --face1.MIMETYPE                                                                             "Face",
    -- face1.mimevalue
  --   TO_CHAR(longtodateTZ(face.LAST_EDIT_TIME, --'Europe/London'), 'YYYY-MM-DD HH24:MI') "SOMETHING"
 FROM
     PERSONS p
 JOIN
     CENTERS c
 ON
     p.CENTER = c.ID
 LEFT JOIN
     PERSON_EXT_ATTRS face
 ON
     p.center = face.personcenter
     AND p.id = face.personid
     AND face.name = '_eClub_Picture'
 LEFT JOIN
     PERSON_EXT_ATTRS face1
 ON
     p.center = face1.personcenter
     AND p.id = face1.personid
     AND face1.name = '_eClub_PictureFace'
 WHERE
 p.center in ($$scope$$)
     AND p.status IN (1,3)
     and face.mimevalue is  null
 and face1.mimevalue is  null
