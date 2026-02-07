CREATE TABLE 
    booking_partic_counts_cache 
    ( 
        booking_center int4 NOT NULL, 
        booking_id int4 NOT NULL, 
        showups int4 NOT NULL, 
        on_normal_list int4 NOT NULL, 
        on_waiting_list int4 NOT NULL, 
        participating int4, 
        seats_booked int4, 
        PRIMARY KEY (booking_center, booking_id) 
    );
