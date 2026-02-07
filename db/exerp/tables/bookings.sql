CREATE TABLE 
    bookings 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        starttime int8 NOT NULL, 
        stoptime int8 NOT NULL, 
        creation_time int8, 
        last_modified int8, 
        creator_center int4, 
        creator_id int4, 
        activation_time int8, 
        activation_by_center int4, 
        activation_by_id int4, 
        cancelation_time int8, 
        cancellation_reason text(2147483647), 
        cancelation_by_center int4, 
        cancelation_by_id int4, 
        STATE text(2147483647) NOT NULL, 
        conflict bool DEFAULT FALSE NOT NULL, 
        last_participation_seq int4, 
        queue_run_time int8, 
        queue_run_by_center int4, 
        queue_run_by_id int4, 
        class_capacity int4, 
        waiting_list_capacity int4, 
        maximum_sub_staff_usages int4, 
        name        text(2147483647), 
        description text(2147483647), 
        coment      text(2147483647), 
        activity int4, 
        main_booking_center int4, 
        main_booking_id int4, 
        recurrence_type int4, 
        recurrence_data text(2147483647), 
        recurrence_end  DATE, 
        recurrence_for  DATE, 
        recurrence_at_planned bool DEFAULT TRUE NOT NULL, 
        owner_center int4, 
        owner_id int4, 
        colour_group_id int4, 
        booking_program_id int4, 
        external_id VARCHAR(200), 
        deadline_showup_percentage int4, 
        available_for_substitution bool DEFAULT FALSE NOT NULL, 
        one_off_cancellation bool, 
        min_age int4, 
        max_age int4, 
        min_age_strict bool, 
        not_shown_notification_sent bool, 
        streaming_id    VARCHAR(2000), 
        additional_info VARCHAR(200), 
        main_preparation_booking_id int4, 
        main_preparation_booking_center int4, 
        PRIMARY KEY (center, id), 
        CONSTRAINT book_to_activity_fk FOREIGN KEY (activity) REFERENCES "exerp"."activity" ("id") 
        ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bo_course_fk FOREIGN KEY (booking_program_id) REFERENCES "exerp"."booking_programs" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT book_to_main_book_fk FOREIGN KEY (main_booking_center, main_booking_id) REFERENCES 
    "exerp"."bookings" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bookings_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bo_activation_by_fk FOREIGN KEY (activation_by_center, activation_by_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bo_cancelation_by_fk FOREIGN KEY (cancelation_by_center, cancelation_by_id) 
    REFERENCES "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bo_queue_run_by_fk FOREIGN KEY (queue_run_by_center, queue_run_by_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bookings_to_owner_fk FOREIGN KEY (owner_center, owner_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bookings_to_persons_fk FOREIGN KEY (creator_center, creator_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
