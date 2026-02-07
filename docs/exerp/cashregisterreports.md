# cashregisterreports
Financial/transactional table for cashregisterreports records. It is typically used where rows are center-scoped; it appears in approximately 31 query files; common companions include [cashregistertransactions](cashregistertransactions.md), [credit_notes](credit_notes.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `reporttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `cashinitial` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `cashend` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `employeecenter` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - | `42` |
| `employeeid` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - | `42` |
| `sales_total` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `sales_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `credits_total` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `credits_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `control_device_id` | Identifier of the related control device record. | `text(2147483647)` | Yes | No | - | - | `1001` |

# Relations
- Commonly used with: [cashregistertransactions](cashregistertransactions.md) (28 query files), [credit_notes](credit_notes.md) (27 query files), [invoices](invoices.md) (27 query files), [products](products.md) (24 query files), [account_receivables](account_receivables.md) (24 query files), [ar_trans](ar_trans.md) (24 query files).
- FK-linked tables: outgoing FK to [employees](employees.md); incoming FK from [cashregistertransactions](cashregistertransactions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
