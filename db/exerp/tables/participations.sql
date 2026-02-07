CREATE TABLE 
    participations 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        configuration int4, 
        creation_time int8, 
        last_modified int8, 
        creation_by_center int4, 
        creation_by_id int4, 
        participation_number int4, 
        start_time int8, 
        stop_time int8, 
        booking_center int4, 
        booking_id int4, 
        participant_center int4, 
        participant_id int4, 
        showup_time int8, 
        showup_interface_type int4, 
        showup_using_card bool, 
        showup_by_center int4, 
        showup_by_id int4, 
        on_waiting_list bool DEFAULT FALSE NOT NULL, 
        STATE              text(2147483647), 
        cancelation_reason text(2147483647), 
        cancelation_time int8, 
        cancelation_interface_type int4, 
        cancelation_by_center int4, 
        cancelation_by_id int4, 
        user_interface_type int4, 
        reminder_message_attempted bool DEFAULT FALSE NOT NULL, 
        no_show_up_punish_state int4, 
        moved_up_time int8, 
        cancelation_notified bool NOT NULL, 
        print_time int8, 
        finish_time int8, 
        invoice_line_center int4, 
        invoice_line_id int4, 
        invoice_line_subid int4, 
        energy_consumption_kcal NUMERIC(0,0), 
        external_id             text(2147483647), 
        seat_id int4, 
        owner_center int4, 
        owner_id int4, 
        seat_state text(2147483647), 
        used_owner_privilege bool DEFAULT FALSE NOT NULL, 
        booking_participation_type text(2147483647), 
        reviewed_by_center int4, 
        reviewed_by_id int4, 
        reviewed_time int8, 
        last_checkin_autoshowup int4, 
        tentative_cutoff_time int8, 
        showup_entry_time int8, 
        pickup_by_center int4, 
        pickup_by_id int4, 
        dropoff_by_center int4, 
        dropoff_by_id int4, 
        recurring_participation_key int4, 
        after_sale_process bool, 
        confirmation_process bool, 
        PRIMARY KEY (center, id), 
        CONSTRAINT participations_to_bookings_fk FOREIGN KEY (booking_center, booking_id) 
        REFERENCES "exerp"."bookings" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT pa_to_invoiceline_fk FOREIGN KEY (invoice_line_center, invoice_line_id, 
    invoice_line_subid) REFERENCES "exerp"."invoice_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT participations_to_conf_fk FOREIGN KEY (configuration) REFERENCES 
    "exerp"."participation_configurations" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT pa_to_cancelation_by_fk FOREIGN KEY (cancelation_by_center, cancelation_by_id) 
    REFERENCES "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT pa_to_creation_by_fk FOREIGN KEY (creation_by_center, creation_by_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT pa_to_showup_by_fk FOREIGN KEY (showup_by_center, showup_by_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT participations_to_persons_fk FOREIGN KEY (participant_center, participant_id) 
    REFERENCES "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT pa_to_rec_pa_fk FOREIGN KEY (recurring_participation_key) REFERENCES 
    "exerp"."recurring_participations" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
