# subscription_price
Stores subscription-related data, including lifecycle and financial context. It is typically used where change-tracking timestamps are available; it appears in approximately 813 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `from_date` | Date for from. | `DATE` | No | No | - | - | `2025-01-31` |
| `to_date` | Date for to. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `subscription_center` | Foreign key field linking this record to `subscriptions`. | `int4` | No | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - | `101` |
| `subscription_id` | Foreign key field linking this record to `subscriptions`. | `int4` | No | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - | `1001` |
| `price` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `binding` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `1` |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `notified` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `applied` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `cancelled` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `approved` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `pending` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `approved_employee_center` | Center part of the reference to related approved employee data. | `int4` | Yes | No | - | - | `101` |
| `approved_employee_id` | Identifier of the related approved employee record. | `int4` | Yes | No | - | - | `1001` |
| `approved_entry_time` | Epoch timestamp for approved entry. | `int8` | Yes | No | - | - | `1738281600000` |
| `cancelled_employee_center` | Center part of the reference to related cancelled employee data. | `int4` | Yes | No | - | - | `101` |
| `cancelled_employee_id` | Identifier of the related cancelled employee record. | `int4` | Yes | No | - | - | `1001` |
| `cancelled_entry_time` | Epoch timestamp for cancelled entry. | `int8` | Yes | No | - | - | `1738281600000` |
| `aggregated_change_date` | Date for aggregated change. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `template_id` | Identifier of the related template record. | `int4` | Yes | No | - | [templates](templates.md) via (`template_id` -> `id`) | `1001` |
| `event_config_id` | Identifier of the related event config record. | `int4` | Yes | No | - | - | `1001` |
| `prorata_sessions` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `prorata_sessions_total` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (794 query files), [persons](persons.md) (696 query files), [products](products.md) (675 query files), [centers](centers.md) (529 query files), [subscriptiontypes](subscriptiontypes.md) (515 query files), [person_ext_attrs](person_ext_attrs.md) (337 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [campaign_codes](campaign_codes.md), [card_clip_usages](card_clip_usages.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
