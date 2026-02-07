# invoice_lines_mt.reason
Maps code values from `invoice_lines_mt.reason` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|0|UNKNOWN|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|1|DEFAULT|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|2|FREEZE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|3|PERSONTYPECHANGE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|4|UPGRADE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|5|DOWNGRADE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|6|TRANSFER|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|7|REGRET|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|8|STOPMEMBERSHIP|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|9|AUTORENEW|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|10|SAVEDFREEDAYS|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|11|PAYOUTMEMBERSHIP|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|12|CHANGEMEMBERSHIP|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|13|DCSTOPMEMBERSHIP|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|14|WRONGSALE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|15|PRODUCTRETURNED|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|16|FREECREDITLINE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|17|MANUALPRICEADJUST|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|18|SANCTION|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|19|CHARGEDMESSAGEUNDELIVERABLE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|20|DCSENDAGENCY|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|21|MANUALRENEW|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|22|PRIVILEGEUSAGECANCELLED|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|23|DOCUMENTATION|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|24|WRITEOFF|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|25|PAYMENTCOLLECTIONFEEREVERSED|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|26|APPLYSTEP|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|27|SALEONACCOUNT|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|28|REMINDERFEE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|29|MEMBERCARDRETURNED|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|30|MEMBERSHIPSALE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|31|SHOPSALE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|32|CHANGESTARTDATE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|33|BUYOUTCLIPCARD|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|34|FAMILYPERSONTYPECHANGE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|35|FAMILYSUBSCRIPTIONCHANGE|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|36|REASSIGN|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
|37|REGRETCLIPCARD|integer|[invoice_lines_mt](../exerp/invoice_lines_mt.md)|
