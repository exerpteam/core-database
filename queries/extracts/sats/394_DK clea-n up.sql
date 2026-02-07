select unique P.GLOBALID, P.NAME from PRODUCTS P where
P.REQUIREDROLE is not null and P.PTYPE=10 order by P.GLOBALID,
P.NAME