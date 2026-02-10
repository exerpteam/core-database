-- The extract is extracted from Exerp on 2026-02-08
-- ES-16524
ST-8260
select		cast(ec.id as varchar(25)) AS RefId,
			ec.filename,
			exp.attempt,
			TO_CHAR(TO_TIMESTAMP(op.start_time/1000), 'YYYY-MM-DD HH:MI') AS StartTime
from		exchanged_file ec
				JOIN exchanged_file_exp exp ON exp.exchanged_file_id=ec.id
				JOIN exchanged_file_op op ON op.exchanged_file_id=ec.id 
where		ec.exported=0
			AND ec.status='GENERATED'
			AND exp.status='WAITING'
			AND ec.schedule_id IS NOT NULL
			AND ec.entry_time BETWEEN
    			CASE
        			WHEN $$offset$$=-1
        				THEN 0
        			ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    				END
    			AND 
					CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000