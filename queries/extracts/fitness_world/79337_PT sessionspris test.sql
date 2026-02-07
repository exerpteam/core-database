-- This is the version from 2026-02-05
--  
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT cu.*
,convert(date, usage_time) AS Date
	,c.PERSON_ID
	,per.HOME_CENTER_PERSON_ID
	,per.PERSON_GENDER
	,per.PERSON_DATE_OF_BIRTH
	,floor(datediff(day, convert(date, per.PERSON_DATE_OF_BIRTH), getdate())/365.25) AS MemberAge_Today
	,s.PRODUCT_ID
	,c.CLIPS_INITIAL
	,s.TOTAL_AMOUNT_TXT
	,p.NAME
  FROM [FWBI].[exerp_].[Clipcard_Usage] cu
  left join [FWBI].[exerp_].[Clipcards] c
  on cu.CLIPCARD_ID = c.CLIPCARD_ID
  left join [FWBI].[exerp_].Sales_Log s
  on c.SALES_LINE_ID = s.SALES_LINE_ID
  left join [FWBI].[exerp_].Products p
  on s.PRODUCT_ID = p.PRODUCT_ID
   left join [FWBI].[bi_model_].[v_dim_persons] per
  on s.PERSON_ID = per.PERSON_ID
  where 1=1
  --and c.CLIPCARD_ID='624cc24860id804'
  and USAGE_TIME between '2021-11-01' and '2021-11-30'
  and type='PRIVILEGE'
  and cu.state <> 'CANCELLED'