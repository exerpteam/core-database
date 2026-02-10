# report_periods
Operational table for report periods records in the Exerp schema. It is typically used where it appears in approximately 46 query files; common companions include [account_receivables](account_receivables.md), [ar_trans](ar_trans.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | [report_periods_scope_id](../master%20tables/report_periods_scope_id.md) |
| `period_name` | Business attribute `period_name` used by report periods workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `close_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `hard_close_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (46 query files), [ar_trans](ar_trans.md) (46 query files), [centers](centers.md) (43 query files), [persons](persons.md) (35 query files), [account_trans](account_trans.md) (30 query files), [art_match](art_match.md) (27 query files).
- Interesting data points: `start_date` and `end_date` are frequently used for period-window filtering.
