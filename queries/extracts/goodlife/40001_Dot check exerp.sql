select * from persons 
where sex = 'C'
AND (strpos(firstname, '.') > 0	 OR strpos(lastname, '.') > 0)