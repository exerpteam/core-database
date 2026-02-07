select 
st.center,
st.id,
decode(st.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect') as ST_TYPE,
st.PRODUCTNEW_CENTER,
st.PRODUCTNEW_ID,
st.FLOATINGPERIOD,
st.INITIALPERIODCOUNT,
st.BINDINGPERIODCOUNT,
DECODE(st.PERIODUNIT, 0, 'Week', 1, 'Days', 2, 'Month', 3, 'Year', 4, 'Hour', 5, 'Minutes', 6, 'Second') as PERIODUNIT,
st.PERIODCOUNT,
st.RENEW_WINDOW
from SUBSCRIPTIONTYPES st
where 
st.center >= :FromCenter
    and st.center <= :ToCenter