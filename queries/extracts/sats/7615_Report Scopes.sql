SELECT 
ar.name as Country,
a.name as Region,
ac.center,
c.name


FROM
AREA_CENTERS ac

Join centers c on c.id= ac.center 

join areas a on ac.area = a.id
 /* joinar center area id mot nivå1*/

Join areas ar on a.parent=ar.id and ar.id in(39,40,41,42,43)
 /* joinar nivå1 mot nivå2 reportscope*/

Join areas r on ar.parent= r.id 
 /* joinar nivå2 mot nivå3 */



where a.id <> 44
