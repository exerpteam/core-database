 /*
 VA IT free period due to corona virus problem
 1. Exlcude any clubs. Needs to confirm in the meeting.
 2. Add Free period for EFT subscription. From 16-03-2020 to 30-03-2020 both days included. Needs to
 confirm in the meeting.
 3. Exclude EFT subscription which are meeting following condition
 a. Already fully free/freeze period cover for the above period.
 b. Subscription starting after free period end date
 c. Subscription ended before free period start date.
 d. Subscription ended before above free period end date and already free period added until
 subscription end date. This is avoid those appear again in the extract.
 e. Subscription ended same day as billed until date and member has another EFT subscription
 starting in X days from cureent subscription end date. The credit will be used new subscription.
 */
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$FreeFromDate$$ AS StartDate,
             $$FreeFromTo$$ AS EndDate,
             0                                   AS numberOfDays
         
     )
 SELECT
         b.personid,
         b.center ||'ss'|| b.id AS SubscriptionId,
         b.billed_until_date,
         b.sub_start_date,
         b.sub_end_date,
         b.name as product_name
 FROM
     (
         SELECT
             DISTINCT
             a.billed_until_date,
             a.start_date as sub_start_date,
             a.end_date as sub_end_date,
             a.name,
             a.personid,
             a.center,
             a.id,
             a.freezestart AS startdate,
             a.freezeend   AS enddate,
             'COVID-19 Measures (ST-11062)'    AS Text,
             a.TransferDate,
             COALESCE(
                       (
                       SELECT
                           SUM(least(srd2.end_date,a.freezeend) - greatest(srd2.start_date,
                           a.freezestart) + 1)
                       FROM
                           subscription_reduced_period srd2
                       WHERE
                           srd2.subscription_center = a.center
                       AND srd2.subscription_id = a.id
                       AND srd2.state = 'ACTIVE'
                       AND srd2.start_date <= a.freezeend
                       AND srd2.end_date >= a.freezestart), 0) AS free_actual_length,
             (a.freezeend - a.freezestart +1)                  AS free_theoric_length
             --, 'CONDITIONAL' as type
             --, a.*, a.freezeend - a.freezestart + 1 as FreezeLength
         FROM
             (
                 SELECT
                     s.center,
                     s.id,
                     s.owner_center || 'p' || s.owner_id AS PersonId,
                     s.center || 'ss' || s.id            AS SubscriptionId,
                     s.start_date,
                     s.end_date,
                     s.billed_until_date,
                     s.refmain_center,
                     s.refmain_id,
                     pr.name,
                     least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate)
                     AS freezeend,
                     --    greatest(s.start_date, params.StartDate) as freezestart_without_transfer,
                     greatest(greatest(s.start_date, to_date(COALESCE(TO_CHAR(longtodateC
                     (scl.book_start_time, scl.center), 'YYYY-MM-DD'),'1900-01-01'), 'YYYY-MM-DD')),
                     params.StartDate) AS freezestart,
                     to_date(TO_CHAR(longtodateC(scl.book_start_time, scl.center), 'YYYY-MM-DD'),
                     'YYYY-MM-DD') AS TransferDate
                     --    COUNT(*)
                 FROM
                     subscriptions s
                 JOIN
                     centers c ON c.id = s.center AND c.country = 'IT'
                 CROSS JOIN
                     params
                 JOIN
                     subscriptiontypes st
                 ON
                     st.center = s.SUBSCRIPTIONTYPE_CENTER
                 AND st.id = s.SUBSCRIPTIONTYPE_id
                 AND st.st_type = 1
                 JOIN
                      PRODUCTS pr ON
                         pr.center = st.center AND pr.id = st.id
                 LEFT JOIN
                     subscription_reduced_period srd
                 ON
                     srd.subscription_center = s.center
                 AND srd.subscription_id = s.id
                 AND srd.state = 'ACTIVE'
                 AND srd.start_date <= greatest(params.StartDate, s.start_date)
                 AND srd.end_date >= least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy'))
                     ,params.EndDate)
                     /* for getting transfer date and move the free period start date if needed */
                 LEFT JOIN
                     state_change_log scl
                 ON
                     scl.center = s.center
                 AND scl.id = s.id
                 AND scl.stateid = 8
                 AND scl.sub_state = 6
                 AND scl.entry_type = 2
                 AND longtodateC(scl.book_start_time, scl.center) > s.start_date
                 WHERE
                 s.center in (:Scope) and
                  s.state IN (2,4,8)
                     /* Exclude already fully period free/freeze/savedfree days member */
                 AND srd.id IS NULL
                 /* Include these subs */
                     AND pr.NAME IN ('Cambio Merce','Cambio Merce Corporate Cash','Cambio Merce Locale','Corporate Domenica 12 Mesi * CASH','Corporate Giovedì 12 Mesi * CASH','Corporate One Month *','Corporate One Month Collection *','Corporate Open 12 Mesi *','Corporate Open 12 Mesi * CASH','Corporate Open 12 Mesi Under 30 * CASH','Corporate Open 3 Mesi *','Corporate Open 3 Mesi * CASH','Corporate Open Mese *','Corporate Open Mese * CASH','Corporate Young Open 12 mesi * CASH','Corporate Young Open 3 * CASH','Diplomatico Off Peak Cash','Diplomatico Off Peak Day 12 Mesi','Diplomatico Off Peak Night 12 Mesi','Diplomatico Open 12 Collection','Diplomatico Open 12 Collection Cash','Diplomatico Open 12 Home Club','Diplomatico Open 12 Home Club Cash','Diplomatico Open 12 Mesi *','Diplomatico Open 12 Mesi * CASH','Diplomatico Open 12 Mesi Collection','Diplomatico Open 12 Mesi Collection CASH','Diplomatico Open 12 Mesi Life','Diplomatico Open 12 Mesi Life CASH','Diplomatico Open 12 Mesi Premium','Diplomatico Open 12 Mesi Premium CASH','Diplomatico Open 12 Mesi Premium Plus','Diplomatico Open 12 Mesi Premium Plus CASH','Diplomatico Open 12 Mesi UNDER 30 Life','Diplomatico Open 12 Mesi UNDER 30 Life CASH','Diplomatico Open 12 Mesi UNDER 30 Premium','Diplomatico Open 12 Mesi UNDER 30 Premium CASH','Diplomatico Open 12 Mesi UNDER 30 Premium Plus','Diplomatico Open 12 Mesi UNDER 30 Premium Plus CASH','Diplomatico Open 12 Premium','Diplomatico Open 12 Premium Cash','Diplomatico Open 12 Premium Plus','Diplomatico Open 12 Premium Plus Cash','Diplomatico Open 24 Mesi *','Diplomatico Open 24 Mesi * CASH','Diplomatico Open 24 Mesi Collection','Diplomatico Open 24 Mesi Collection CASH','Diplomatico Open 24 Mesi Life','Diplomatico Open 24 Mesi Life CASH','Diplomatico Open 24 Mesi Premium','Diplomatico Open 24 Mesi Premium CASH','Diplomatico Open 24 Mesi Premium Plus','Diplomatico Open 24 Mesi Premium Plus CASH','Diplomatico Open 3 Mesi *','Diplomatico Open 3 Mesi * CASH','Diplomatico Open 3 Mesi Collection','Diplomatico Open 3 Mesi Collection 2018','Diplomatico Open 3 Mesi Collection CASH','Diplomatico Open 3 Mesi Collection Cash 2018','Diplomatico Open 3 Mesi Home Club','Diplomatico Open 3 Mesi Home Club Cash','Diplomatico Open 3 Mesi Life','Diplomatico Open 3 Mesi Life CASH','Diplomatico Open 3 Mesi Premium','Diplomatico Open 3 Mesi Premium 2018','Diplomatico Open 3 Mesi Premium CASH','Diplomatico Open 3 Mesi Premium Cash 2018','Diplomatico Open 3 Mesi Premium Plus','Diplomatico Open 3 Mesi Premium Plus 2018','Diplomatico Open 3 Mesi Premium Plus CASH','Diplomatico Open 3 Mesi Premium Plus Cash 2018','Diplomatico Open Mese *','Diplomatico Open Mese * CASH','Diplomatico Open Mese 2018','Diplomatico Open Mese Cash 2018','Diplomatico Open Mese Collection','Diplomatico Open Mese Collection CASH','Diplomatico Open Mese Life','Diplomatico Open Mese Life CASH','Diplomatico Open Mese Premium','Diplomatico Open Mese Premium CASH','Diplomatico Open Mese Premium Plus','Diplomatico Open Mese Premium Plus CASH','Diplomatico Promo Active Open 12 *','Diplomatico Promo Active Open 12 * CASH','Diplomatico Promo Off Peak Day Open 12 *','Diplomatico Promo Off Peak Day Open 12 * CASH','Diplomatico Promo Off Peak Night Open 12 *','Diplomatico Promo Off Peak Night Open 12 * CASH','Diplomatico Promo Senior Open 12 *','Diplomatico Promo Senior Open 12 * CASH','Diplomatico Promo Week End Open 12 *','Diplomatico Promo Week End Open 12 * CASH','Diplomatico Promo Young 3 Open 3 *','Diplomatico Promo Young 3 Open 3 * CASH','Diplomatico Promo Young 30 Open 12 *','Diplomatico Promo Young 30 Open 12 * CASH','Diplomatico Promo Young Free Open 12 *','Diplomatico Promo Young Free Open 12 * CASH','Diplomatico Promo Young Open 12 *','Diplomatico Promo Young Open 12 * CASH','Diplomatico PT Family *','Diplomatico PT Family * CASH','Diplomatico Senior ','Diplomatico Senior Cash','Diplomatico Staff Friends *','Diplomatico Staff Friends * CASH','Diplomatico Week End Cash','Diplomatico WeekEnd','Diplomatico Young 12 Open','Diplomatico Young 12 Open Cash','Diplomatico Young 3 Mesi ','Diplomatico Young 3 Mesi Cash','Flexi','Flexi Cash','Flexi Diplomatico','Flexi Diplomatico Cash','Flexi Student','Flexi Student Cash','Junior 12','Junior 12 Cash','Junior 12 Classic','Junior 6 Mesi','Junior Mese','Junior Mese Cash','Junior Mese Classic','Junior Mese Classic Cash','Junior Multiactive','Junior Multiactive Cash','Junior Omaggio','Junior Omaggio Cash','Junior Open 12 10A-13A','Junior Open 12 10A-13A Cash','Junior Open 12 10A-13A Cash Diplomatico','Junior Open 12 10A-13A Diplomatico','Junior Open 12 18M-9A','Junior Open 12 18M-9A Cash','Junior Open 12 18M-9A Cash Diplomatico','Junior Open 12 18M-9A Diplomatico','Junior Open 3 10A-13A','Junior Open 3 10A-13A Cash ','Junior Open 3 10A-13A Cash Diplomatico','Junior Open 3 10A-13A Diplomatico','Junior Open 3 18M-9A','Junior Open 3 18M-9A Cash','Junior Open 3 18M-9A Cash Diplomatico','Junior Open 3 18M-9A Diplomatico','Junior Open 3 Mesi 3A-9A','Junior Open 3 Mesi Cash 3A-9A','Junior Open Mese 10A-13A','Junior Open Mese 10A-13A Cash','Junior Open Mese 10A-13A Cash Diplomatico','Junior Open Mese 10A-13A Diplomatico','Junior Open Mese 18M-9A','Junior Open Mese 18M-9A Cash','Junior Open Mese 18M-9A Cash Diplomatico','Junior Open Mese 18M-9A Diplomatico','Junior Open Mese 3A-9A','Junior Open Mese Cash 3A-9A','Junior Pool ','Junior Pool 10 Ingressi','Junior Pool 12 Mesi','Junior Pool 12 Mesi Cash','Junior Pool 18M-13A','Junior Pool 18M-13A Cash','Junior Pool 3 Mesi','Junior Pool 3 Mesi Cash','Junior Pool 6 Mesi','Junior Pool 6 Mesi Cash','Junior Pool Cash','Off Peak Day','Off Peak Day Cash','Off Peak Night','Off Peak Night Cash','Off Peak Promo','Off Peak Promo Cash','One Month','One Month Classic ','One Month Classic cash','Open 12','Open 12 - Ch','Open 12 BLACK FRIDAY ','Open 12 BLACK FRIDAY CASH','Open 12 Cash','Open 12 Cash - Ch','Open 12 Collection','Open 12 Collection AlterEgo','Open 12 Collection AlterEgo Cash','Open 12 Collection Cash','Open 12 Fascia 1','Open 12 Fascia 1 Cash','Open 12 Fascia 3','Open 12 Fascia 3 Cash','Open 12 Home Club','Open 12 Home Club *','Open 12 Home Club AlterEgo ','Open 12 Home Club AlterEgo Cash','Open 12 Home Club Cash','Open 12 Home Club Cash *','Open 12 Home Club Rinnovo','Open 12 Home Club Rinnovo Cash','Open 12 Mesi Collection','Open 12 Mesi Collection CASH','Open 12 Mesi Life','Open 12 Mesi Life CASH','Open 12 Mesi OLD','Open 12 Mesi Premium','Open 12 Mesi Premium CASH','Open 12 Mesi Premium Plus','Open 12 Mesi Premium Plus CASH','Open 12 Mesi UNDER 30 *','Open 12 Mesi UNDER 30 * CASH','Open 12 Mesi UNDER 30 Life','Open 12 Mesi UNDER 30 Life CASH','Open 12 Mesi UNDER 30 Premium','Open 12 Mesi UNDER 30 Premium CASH','Open 12 Mesi UNDER 30 Premium Plus','Open 12 Mesi UNDER 30 Premium Plus CASH','Open 12 Mesi*','Open 12 Mesi* CASH','Open 12 Premium','Open 12 Premium AlterEgo','Open 12 Premium AlterEgo Cash','Open 12 Premium Cash','Open 12 Premium Plus','Open 12 Premium Plus AlterEgo','Open 12 Premium Plus AlterEgo Cash','Open 12 Premium Plus Cash','Open 12 Premium Presales','Open 12 Premium Presales Cash','Open 12 Premium Rinnovo','Open 12 Premium Rinnovo Cash','Open 12 Presales ','Open 24 Collection','Open 24 Collection Cash','Open 24 Home Club','Open 24 Home Club Cash','Open 24 Home Club Rinnovo','Open 24 Home Club Rinnovo Cash','Open 24 Mesi * CASH','Open 24 Mesi Collection','Open 24 Mesi Collection CASH','Open 24 Mesi Life','Open 24 Mesi Life CASH','Open 24 Mesi Premium','Open 24 Mesi Premium CASH ','Open 24 Mesi Premium Plus ','Open 24 Mesi Premium Plus CASH ','Open 24 Mesi*','Open 24 Premium','Open 24 Premium Cash','Open 24 Premium Plus','Open 24 Premium Plus Cash','Open 3','Open 3 Cash','Open 3 Collection','Open 3 Collection Cash','Open 3 Home Club','Open 3 Home Club *','Open 3 Home Club Cash','Open 3 Home Club Cash *','Open 3 Mesi * CASH','Open 3 Mesi Collection','Open 3 Mesi Collection CASH','Open 3 Mesi Life','Open 3 Mesi Life CASH','Open 3 Mesi Premium','Open 3 Mesi Premium CASH','Open 3 Mesi Premium Plus','Open 3 Mesi Premium Plus CASH','Open 3 Mesi*','Open 3 Premium','Open 3 Premium Cash','Open 3 Premium Plus','Open 3 Premium Plus Cash','Open 36','Open 36 Cash','Open 36 Classic','Open 36 Classic Cash','Open 36 Fascia 1','Open 36 Fascia 1 Cash ','Open 36 Fascia 3','Open 36 Fascia 3 Cash ','Open 36 Multiactive','Open 36 Multiactive Cash','Open 36 Premium','Open 36 Premium Cash ','Open 36 Premium Plus','Open 36 Premium Plus Cash ','Open 6','Open 6 Cash','Open Mensile OLD','Open Mese','Open Mese *','Open Mese * CASH','Open Mese Cash','Open Mese Collection','Open Mese Collection CASH','Open Mese Life','Open Mese Life CASH','Open Mese Premium','Open Mese Premium CASH','Open Mese Premium Plus','Open Mese Premium Plus CASH','Partnership Open 12 Classic','Partnership Open 12 Collection ','Partnership Open 12 Collection Cash','Partnership Open 12 Fascia 1','Partnership Open 12 Fascia 3','Partnership Open 12 Home Club','Partnership Open 12 Home Club Cash','Partnership Open 12 Mesi *','Partnership Open 12 Mesi * CASH','Partnership Open 12 Mesi Collection','Partnership Open 12 Mesi Collection CASH','Partnership Open 12 Mesi Life','Partnership Open 12 Mesi Life CASH','Partnership Open 12 Mesi Models*','Partnership Open 12 Mesi Models* CASH','Partnership Open 12 Mesi Premium','Partnership Open 12 Mesi Premium CASH','Partnership Open 12 Mesi Premium Plus','Partnership Open 12 Mesi Premium Plus CASH','Partnership Open 12 Premium','Partnership Open 12 Premium Plus  ','Partnership Open 12 Premium Plus Cash','Partnership Open 3 Mesi Models*','Partnership Open 3 Mesi Models* CASH','Partnership Open 3 Premium','Partnership Open 3 Premium Cash ','Partnership Open 3 Premium Plus  ','Partnership Open 3 Premium Plus Cash ','Partnership Open Mese','Partnership Open Mese *','Partnership Open Mese * CASH','Partnership Open Mese Cash','Partnership Open Mese Models*','Partnership Open Mese Models* CASH','Partnership Premium Open 12 ','Partnership Premium Open 12 Cash','Partnership Special Collection ','Partnership Special Collection Cash','Partnership Special Home Club','Partnership Special Home Club Cash','Partnership Special Open 12 Mesi Collection','Partnership Special Open 12 Mesi Collection CASH','Partnership Special Open 12 Mesi Life','Partnership Special Open 12 Mesi Life CASH','Partnership Special Open 12 Mesi Premium','Partnership Special Open 12 Mesi Premium CASH','Partnership Special Open 12 Mesi Premium Plus','Partnership Special Open 12 Mesi Premium Plus CASH','Partnership Special Open 3 Mesi Collection ','Partnership Special Open 3 Mesi Collection CASH','Partnership Special Open 3 Mesi Life','Partnership Special Open 3 Mesi Life CASH','Partnership Special Open 3 Mesi Premium','Partnership Special Open 3 Mesi Premium CASH','Partnership Special Open 3 Mesi Premium Plus','Partnership Special Open 3 Mesi Premium Plus CASH','Partnership Special Open Mese Collection','Partnership Special Open Mese Life','Partnership Special Open Mese Life CASH','Partnership Special Premium','Promo Active Open 12 *','Promo Active Open 12 * CASH','Promo Off Peak Day Open 12 *','Promo Off Peak Day Open 12 * CASH','Promo Off Peak Night Open 12 *','Promo Off Peak Night Open 12 * CASH','Promo Senior Open 12 *','Promo Senior Open 12 * CASH','Promo Week End Open 12 *','Promo Week End Open 12 * CASH','Promo Young 3 Open 3 *','Promo Young 3 Open 3 * CASH','Promo Young 30 Open 12 *','Promo Young 30 Open 12 * CASH','Promo Young Free Open 12 *','Promo Young Free Open 12 * CASH','Promo Young Open 12 *','Promo Young Open 12 * CASH','PT Family','PT Family *','PT Family * CASH','PT Family Cash','Senior ','Senior Cash','Staff Family','Staff Family Senior ','Staff Family Young','Staff Friends','Staff Friends *','Staff Friends * CASH','Staff Friends Cash','Vip','Vip Classic','Vip Senior','Vip Senior Collection','Vip Young','Vip Young Collection','Week End','Week End Active','Week End Active Cash','Week End Cash','Week End Giovedi','Week End Giovedi Cash','Week End Lunedi','Week End Lunedi Cash','Week End Martedi','Week End Martedi Cash','Week End Mercoledi','Week End Mercoledi Cash','Week End Venerdi','Week End Venerdi Cash','Young 12 Day','Young 12 Day Cash','Young 12 Mesi','Young 12 Night','Young 12 Night Cash','Young 12 Open','Young 12 Open Cash','Young 12 Promo','Young 12 Promo Cash','Young 3 Day','Young 3 Day Cash','Young 3 Night  ','Young 3 Night Cash','Young 3 Open','Young 3 Open Cash','Young 3 Open Cash Old','Young 3 Open Old','Young 3 Promo','Young 3 Promo Cash','Young Free 12 Open','Young Free 12 Open Cash','Young30 12 Open','Young30 12 Open Cash')
                     /* Exlcude subscription starting after free period end date */
                 AND s.start_date <= params.EndDate
                     /* Exclude subscription ended before free period start date */
                 AND (
                         s.end_date IS NULL
                     OR  s.end_date >= params.StartDate)
             ) a
         CROSS JOIN
             params
 ) b
 WHERE
     b.free_actual_length != b.free_theoric_length
