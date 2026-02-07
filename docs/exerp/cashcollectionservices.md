# cashcollectionservices
Financial/transactional table for cashcollectionservices records. It is typically used where lifecycle state codes are present; it appears in approximately 4 query files; common companions include [cashcollectioncases](cashcollectioncases.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the top hierarchy node used to organize scoped records. | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `servicetype` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `datasupplier_id` | Identifier for the related datasupplier entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `account_center` | Center component of the composite reference to the related account record. | `int4` | Yes | No | - | [accounts](accounts.md) via (`account_center`, `account_id` -> `center`, `id`) |
| `account_id` | Identifier component of the composite reference to the related account record. | `int4` | Yes | No | - | - |
| `serial` | Business attribute `serial` used by cashcollectionservices workflows and reporting. | `int4` | No | No | - | - |
| `ledger_number` | Business attribute `ledger_number` used by cashcollectionservices workflows and reporting. | `int4` | Yes | No | - | - |
| `interests_account_center` | Center component of the composite reference to the related interests account record. | `int4` | Yes | No | - | - |
| `interests_account_id` | Identifier component of the composite reference to the related interests account record. | `int4` | Yes | No | - | - |
| `client_identification` | Business attribute `client_identification` used by cashcollectionservices workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `exclude_subscription_by_age` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `invoice_fee_account_center` | Center component of the composite reference to the related invoice fee account record. | `int4` | Yes | No | - | - |
| `invoice_fee_account_id` | Identifier component of the composite reference to the related invoice fee account record. | `int4` | Yes | No | - | - |
| `reminder_fee_account_center` | Center component of the composite reference to the related reminder fee account record. | `int4` | Yes | No | - | - |
| `reminder_fee_account_id` | Identifier component of the composite reference to the related reminder fee account record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [cashcollectioncases](cashcollectioncases.md) (4 query files), [persons](persons.md) (4 query files), [account_receivables](account_receivables.md) (2 query files), [centers](centers.md) (2 query files), [cashcollection_requests](cashcollection_requests.md) (2 query files).
- FK-linked tables: incoming FK from [cashcollection_in](cashcollection_in.md), [cashcollection_out](cashcollection_out.md), [cashcollectioncases](cashcollectioncases.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [cashcollection_requests](cashcollection_requests.md), [cashcollectionjournalentries](cashcollectionjournalentries.md), [persons](persons.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
