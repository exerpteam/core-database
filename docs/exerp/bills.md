# bills
Operational table for bills records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 2 query files; common companions include [account_trans](account_trans.md), [accounts](accounts.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `bill_no` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `trans_time` | Epoch timestamp for trans. | `int8` | No | No | - | - |
| `text` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `text2` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `total_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |

# Relations
- Commonly used with: [account_trans](account_trans.md) (2 query files), [accounts](accounts.md) (2 query files), [aggregated_transactions](aggregated_transactions.md) (2 query files).
- FK-linked tables: outgoing FK to [employees](employees.md); incoming FK from [bill_lines_mt](bill_lines_mt.md), [cashregistertransactions](cashregistertransactions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [billlines_vat_at_link](billlines_vat_at_link.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
