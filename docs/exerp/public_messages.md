# public_messages
Operational table for public messages records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `version` | Operational field `version` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `created_at` | Business attribute `created_at` used by public messages workflows and reporting. | `int8` | No | No | - | - |
| `created_by_center` | Center component of the composite reference to the related created by record. | `int4` | No | No | [employees](employees.md) via (`created_by_center`, `created_by_id` -> `center`, `id`) | - |
| `created_by_id` | Identifier component of the composite reference to the related created by record. | `int4` | No | No | [employees](employees.md) via (`created_by_center`, `created_by_id` -> `center`, `id`) | - |
| `valid_from` | Operational field `valid_from` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `valid_to` | Operational field `valid_to` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `subject` | Operational field `subject` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `body` | Business attribute `body` used by public messages workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `important` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `deleted` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `deleted_at` | Business attribute `deleted_at` used by public messages workflows and reporting. | `int8` | Yes | No | - | - |
| `deleted_by_center` | Center component of the composite reference to the related deleted by record. | `int4` | Yes | No | [employees](employees.md) via (`deleted_by_center`, `deleted_by_id` -> `center`, `id`) | - |
| `deleted_by_id` | Identifier component of the composite reference to the related deleted by record. | `int4` | Yes | No | [employees](employees.md) via (`deleted_by_center`, `deleted_by_id` -> `center`, `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [employees](employees.md); incoming FK from [public_messages_person](public_messages_person.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
