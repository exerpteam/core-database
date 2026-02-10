-- The extract is extracted from Exerp on 2026-02-08
--  
select
	center || 'p' || id,
	lastname,
	firstname
from
	persons
where
	 (lastname is not null
		and lastname ~ '[^A-Za-z0-9\u0600-\u06FF\u00C0-\u024F\u0370-\u03FF\u0400-\u04FF\s@''\-/\.\,\(\)\’\_\u200B-\u200F\u202A-\u202E]')
	or (middlename is not null
		and middlename ~ '[^A-Za-z0-9\u0600-\u06FF\u00C0-\u024F\u0370-\u03FF\u0400-\u04FF\s@''\-/\.\,\(\)\’\_\u200B-\u200F\u202A-\u202E]')
	or (firstname is not null
		and firstname ~ '[^A-Za-z0-9\u0600-\u06FF\u00C0-\u024F\u0370-\u03FF\u0400-\u04FF\s@''\-/\.\,\(\)\’\_\u200B-\u200F\u202A-\u202E]') ;