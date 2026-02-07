# report_periods
Operational table for report periods records in the Exerp schema. It is typically used where it appears in approximately 46 query files; common companions include [account_receivables](account_receivables.md), [ar_trans](ar_trans.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - |
| `period_name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `start_date` | Date when the record becomes effective. | `DATE` | Yes | No | - | - |
| `end_date` | Date when the record ends or expires. | `DATE` | Yes | No | - | - |
| `close_time` | Epoch timestamp for close. | `int8` | No | No | - | - |
| `hard_close_time` | Epoch timestamp for hard close. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (46 query files), [ar_trans](ar_trans.md) (46 query files), [centers](centers.md) (43 query files), [persons](persons.md) (35 query files), [account_trans](account_trans.md) (30 query files), [art_match](art_match.md) (27 query files).
- Interesting data points: `start_date` and `end_date` are frequently used for period-window filtering.
