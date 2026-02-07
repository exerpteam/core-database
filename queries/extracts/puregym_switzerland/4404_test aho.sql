WITH
    date_range AS materialized
    (
       select cast(:date as date)
            
    )
select * from date_range;    