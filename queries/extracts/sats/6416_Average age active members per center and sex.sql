SELECT p.center, c.name, p.sex, 
round(avg(((exerpsysdate() - p.birthdate)/365)),2) As AvgerageAge,
count (p.center) as Members


FROM
persons p

join centers c on c.id=p.center 

WHERE
p.persontype <> 2  /* 2= staff  */
and p.status in (1)  /*active 1 + frozen 3 */
and p.center >= :cfrom and 
 p.center <= :cto and
 p.birthdate >TO_DATE('01-01-1900','dd-mm-yyyy') 

group by
p.center,
p.sex,
c.name