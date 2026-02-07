SELECT replace(left(c.cc_comment,strpos(c.cc_comment,chr(13))-1), 'LegacyClipcardId: ', '')    AS MMSClipcardId
     , c.center || 'cc' || c.id || 'cc' || c.subid                                             AS ExerpClipcardId,
	c.center AS Clipcard_Center
  FROM lifetime.clipcards c
 WHERE c.cc_comment IS NOT NULL
AND c.center IN (:Scope)