CREATE TABLE 
    apple_passes 
    ( 
        id int4 NOT NULL, 
        record_id      VARCHAR(50) NOT NULL, 
        description    VARCHAR(100) NOT NULL, 
        card_uid       VARCHAR(50) NOT NULL, 
        pass_layout_id VARCHAR(50) NOT NULL, 
        valid_from int8, 
        valid_until int8, 
        creation_time int8 NOT NULL, 
        member_center int4, 
        member_id int4, 
        PRIMARY KEY (id) 
    );
