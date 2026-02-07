SELECT 
					*
				FROM 
					CHECKIN_LOG 
where rownum <= 100 and checked_out!=1
