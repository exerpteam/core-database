CREATE TABLE 
    usage_point_resources 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        usage_point_center int4, 
        usage_point_id int4, 
        name text(2147483647) DEFAULT 'Attend'::text NOT NULL, 
        resource_order int4 NOT NULL, 
        resource_usage text(2147483647), 
        gate_center int4, 
        gate_id int4, 
        check_out bool NOT NULL, 
        handback_check bool DEFAULT TRUE NOT NULL, 
        only_accessible bool DEFAULT FALSE NOT NULL, 
        print_ticket bool DEFAULT TRUE NOT NULL, 
        auto_execution_kiosk bool DEFAULT FALSE NOT NULL, 
        shortcut_key text(2147483647), 
        block_unsigned_documents bool DEFAULT FALSE NOT NULL, 
        block_incomplete_agreement bool DEFAULT FALSE NOT NULL, 
        no_reentry_before_checkout bool DEFAULT FALSE NOT NULL, 
        no_check_in bool DEFAULT FALSE NOT NULL, 
        exit_previous_attend bool DEFAULT FALSE NOT NULL, 
        exit_resource_center int4, 
        exit_resource_id int4, 
        block_expired_hc bool DEFAULT FALSE NOT NULL, 
        notify_on_access_error bool DEFAULT FALSE NOT NULL, 
        enter_attend_duration bool DEFAULT FALSE NOT NULL, 
        show_attendance_history bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT upr_to_gate_fk FOREIGN KEY (gate_center, gate_id) REFERENCES "exerp"."gates" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT upr_to_up_fk FOREIGN KEY (usage_point_center, usage_point_id) REFERENCES 
    "exerp"."usage_points" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
