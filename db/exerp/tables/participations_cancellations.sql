CREATE TABLE 
    participations_cancellations 
    ( 
        participation_center int4 NOT NULL, 
        participation_id int4 NOT NULL, 
        cancellation_processed_time int8, 
        cancellation_processed_result int4 NOT NULL, 
        PRIMARY KEY (participation_center, participation_id) 
    );
