CREATE TABLE 
    participation_configurations 
    ( 
        id int4 NOT NULL, 
        activity_id int4, 
        name text(2147483647) NOT NULL, 
        excluzive bool NOT NULL, 
        ordinal int4 NOT NULL, 
        min_participants_at_creation int4 NOT NULL, 
        max_participants_at_creation int4, 
        minimum_showups int4 NOT NULL, 
        max_participants_absolute int4, 
        max_participants_percentage int4, 
        access_group_id int4, 
        owner_participation bool NOT NULL, 
        participate_in_all_recurring bool NOT NULL, 
        privilege_at_showup_client bool DEFAULT FALSE NOT NULL, 
        privilege_at_showup_kiosk bool DEFAULT FALSE NOT NULL, 
        privilege_at_showup_web bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT part_config_to_activity_fk FOREIGN KEY (activity_id) REFERENCES 
        "exerp"."activity" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT part_conf_to_access_grp_fk FOREIGN KEY (access_group_id) REFERENCES 
    "exerp"."booking_privilege_groups" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
