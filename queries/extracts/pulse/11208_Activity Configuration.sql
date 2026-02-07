SELECT
            pc.privilege_at_showup_client,
            pc.privilege_at_showup_kiosk,
            pc.privilege_at_showup_web,            
a.name   AS ACTIVITY_NAME,
            AG.NAME  AS ACTIVITY_GROUP,
            PC.activity_id,
            pc.access_group_id,
            PC.ID as Participation_Configuration_ID,
            pc.privilege_at_showup_client,
            pc.privilege_at_showup_kiosk, 
            pc.privilege_at_showup_web 
        FROM
            activity a
        JOIN
           activity_group ag
        ON
            a.activity_group_id = ag.id
        JOIN
           participation_configurations pc
       ON
            a.id = pc.activity_id