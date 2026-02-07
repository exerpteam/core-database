# cashcollectionservices
Financial/transactional table for cashcollectionservices records. It is typically used where lifecycle state codes are present; it appears in approximately 4 query files; common companions include [cashcollectioncases](cashcollectioncases.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the related top node record. | `int4` | Yes | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `servicetype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `datasupplier_id` | Identifier of the related datasupplier record. | `text(2147483647)` | Yes | No | - | - |
| `account_center` | Center part of the reference to related account data. | `int4` | Yes | No | - | [accounts](accounts.md) via (`account_center`, `account_id` -> `center`, `id`) |
| `account_id` | Identifier of the related account record. | `int4` | Yes | No | - | - |
| `serial` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `ledger_number` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `interests_account_center` | Center part of the reference to related interests account data. | `int4` | Yes | No | - | - |
| `interests_account_id` | Identifier of the related interests account record. | `int4` | Yes | No | - | - |
| `client_identification` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `exclude_subscription_by_age` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `invoice_fee_account_center` | Center part of the reference to related invoice fee account data. | `int4` | Yes | No | - | - |
| `invoice_fee_account_id` | Identifier of the related invoice fee account record. | `int4` | Yes | No | - | - |
| `reminder_fee_account_center` | Center part of the reference to related reminder fee account data. | `int4` | Yes | No | - | - |
| `reminder_fee_account_id` | Identifier of the related reminder fee account record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [cashcollectioncases](cashcollectioncases.md) (4 query files), [persons](persons.md) (4 query files), [account_receivables](account_receivables.md) (2 query files), [centers](centers.md) (2 query files), [cashcollection_requests](cashcollection_requests.md) (2 query files).
- FK-linked tables: incoming FK from [cashcollection_in](cashcollection_in.md), [cashcollection_out](cashcollection_out.md), [cashcollectioncases](cashcollectioncases.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [cashcollection_requests](cashcollection_requests.md), [cashcollectionjournalentries](cashcollectionjournalentries.md), [persons](persons.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
