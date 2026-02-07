CREATE TABLE 
    task_types 
    ( 
        id int4 NOT NULL, 
        status      text(2147483647) NOT NULL, 
        name        text(2147483647) NOT NULL, 
        description text(2147483647), 
        workflow_id int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        external_id text(2147483647) NOT NULL, 
        follow_up_interval_type int4, 
        follow_up_interval int4, 
        roles            text(2147483647), 
        manager_roles    text(2147483647), 
        unassigned_roles text(2147483647), 
        booking_search_id int4, 
        membership_sales_access bool DEFAULT TRUE, 
        staff_groups text(2147483647), 
        available_in_lead_creation bool DEFAULT FALSE, 
        follow_up_overdue_type int4, 
        follow_up_overdue_interval int4, 
        task_center_selection_type text(2147483647) DEFAULT 'PERSON_HOME_CLUB'::text NOT NULL, 
        task_specific_center int4, 
        PRIMARY KEY (id), 
        CONSTRAINT tsktype_to_workflow_fk FOREIGN KEY (workflow_id) REFERENCES "exerp"."workflows" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
