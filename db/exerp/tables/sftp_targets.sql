CREATE TABLE 
    sftp_targets 
    ( 
        id int4 NOT NULL, 
        scope_type VARCHAR(1) NOT NULL, 
        scope_id int4 NOT NULL, 
        name VARCHAR(50) NOT NULL, 
        host VARCHAR(100) NOT NULL, 
        port int4 NOT NULL, 
        username    VARCHAR(50) NOT NULL, 
        password    VARCHAR(50) NOT NULL, 
        private_key VARCHAR(4000), 
        public_key  VARCHAR(4000), 
        status      VARCHAR(20) NOT NULL, 
        PRIMARY KEY (id) 
    );
