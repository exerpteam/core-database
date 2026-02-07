CREATE TABLE 
    accountgroupmembers 
    ( 
        accountgroupcenter int4 NOT NULL, 
        accountgroupid int4 NOT NULL, 
        accountcenter int4 NOT NULL, 
        accountid int4 NOT NULL, 
        PRIMARY KEY (accountcenter, accountid, accountgroupcenter, accountgroupid) 
    );
