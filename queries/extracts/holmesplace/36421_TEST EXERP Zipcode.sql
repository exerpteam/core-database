SELECT longtodatec(pr.entry_time, pr.center),pr.* FROM ACCOUNT_RECEIVABLEs ar
join payment_requests pr ON pr.center = ar.center and pr.id = ar.id
WHERE ar.customerCenter = 3
and ar.customerid = 112453