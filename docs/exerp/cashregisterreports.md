# cashregisterreports
Financial/transactional table for cashregisterreports records. It is typically used where rows are center-scoped; it appears in approximately 31 query files; common companions include [cashregistertransactions](cashregistertransactions.md), [credit_notes](credit_notes.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `starttime` | Operational field `starttime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `reporttime` | Business attribute `reporttime` used by cashregisterreports workflows and reporting. | `int8` | No | No | - | - |
| `cashinitial` | Business attribute `cashinitial` used by cashregisterreports workflows and reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `cashend` | Business attribute `cashend` used by cashregisterreports workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `employeecenter` | Center component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `employeeid` | Identifier component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `sales_total` | Business attribute `sales_total` used by cashregisterreports workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `sales_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `credits_total` | Business attribute `credits_total` used by cashregisterreports workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `credits_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `control_device_id` | Identifier for the related control device entity used by this record. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [cashregistertransactions](cashregistertransactions.md) (28 query files), [credit_notes](credit_notes.md) (27 query files), [invoices](invoices.md) (27 query files), [products](products.md) (24 query files), [account_receivables](account_receivables.md) (24 query files), [ar_trans](ar_trans.md) (24 query files).
- FK-linked tables: outgoing FK to [employees](employees.md); incoming FK from [cashregistertransactions](cashregistertransactions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
