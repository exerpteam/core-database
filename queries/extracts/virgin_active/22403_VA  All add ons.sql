         SELECT *
                 FROM
             SUBSCRIPTION_ADDON sa
                 left join centers sa_c on sa_c.id = sa.CENTER_ID
         JOIN
             SUBSCRIPTIONS s
         ON
             s.CENTER = sa.SUBSCRIPTION_CENTER
             AND s.ID = sa.SUBSCRIPTION_ID
         JOIN
             PERSONS p
         ON
             p.CENTER = s.OWNER_CENTER
             AND p.ID = s.OWNER_ID
