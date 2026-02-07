select 
      empl.center as employee_center,
      emp.fullname as employee_fullname,
      per.center as customer_center,
      per.id as customer_id,
      per.fullname as customer_name,
      pe_email.txtvalue as customer_email,
      sub.end_date as subscription_end,
      pr.name as subscription,
      per.first_active_start_date as first_active,
      to_char(eclub2.longtodate(subchange.change_time),'YYYY-MM-dd') as end_set_date,
      to_char(subchange.effect_date,'yyyy-mm-dd') as effect
From
           eclub2.subscriptions sub 
      join eclub2.persons per
      ON
           sub.owner_center = per.center
           and sub.owner_id = per.id
           and per.persontype <> 2 -- not staff
      join eclub2.subscriptiontypes st
      on
           sub.subscriptiontype_center = st.center
           and sub.subscriptiontype_id = st.id
	       and st.st_type = 1 -- EFT
      join eclub2.products pr
      on 
           st.center = pr.center
           and st.id = pr.id
      join eclub2.subscription_change subchange
      on
           sub.center = subchange.old_subscription_center
           and sub.id = subchange.old_subscription_id
           and subchange.type like 'END_DATE'
      join eclub2.employees empl
      on
           subchange.employee_center = empl.center
           and subchange.employee_id = empl.id
      join eclub2.persons emp
      on
           empl.personcenter = emp.center
           and empl.personid = emp.id
      left join eclub2.person_ext_attrs pe_email
      on
           per.center = pe_email.personcenter
           and per.id = pe_email.personid
           and pe_email.name = '_eClub_Email'
      LEFT join eclub2.SUBSCRIPTION_SALES SS
      ON
           SUB.CENTER = SS.SUBSCRIPTION_CENTER
           AND SUB.ID = SS.SUBSCRIPTION_ID 
where 
           to_char(ECLUB2.longToDate(subchange.change_time),'yyyy-mm-dd')  = to_char(exerpsysdate() -1,'yyyy-mm-dd')
            and empl.center not in (100,200,300,400,500,600,700,800)
          -- and ss.type = 1 --new sales 
           and sub.end_date is not null
	       and sub.sub_state not in (3,4,5,6,7) -- up/down graded, regret, transfer, extended
           and sub.state in (2,7) -- active, window
group by
           empl.center,
           emp.fullname,
           per.center,
           per.id,
           per.fullname,
           pe_email.txtvalue,
           sub.end_date,
           pr.name,
           per.first_active_start_date,
           to_char(eclub2.longtodate(subchange.change_time),'YYYY-MM-dd'),
           to_char(subchange.effect_date,'yyyy-mm-dd')