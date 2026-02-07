# doc_requirement_items
Operational table for doc requirement items records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `documentation_requirement_key` | Identifier of the related documentation requirements record used by this row. | `int4` | No | No | [documentation_requirements](documentation_requirements.md) via (`documentation_requirement_key` -> `id`) | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `VARCHAR(30)` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `VARCHAR(50)` | No | No | - | - |
| `item_type_key` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `itm_instance_journal_entry_key` | Identifier of the related journalentries record used by this row. | `int4` | Yes | No | [journalentries](journalentries.md) via (`itm_instance_journal_entry_key` -> `id`) | - |
| `item_instance_center` | Center component of the composite reference to the related item instance record. | `int4` | Yes | No | - | - |
| `item_instance_id` | Identifier component of the composite reference to the related item instance record. | `int4` | Yes | No | - | - |
| `item_instance_sub_id` | Identifier for the related item instance sub entity used by this record. | `int4` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(20)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [documentation_requirements](documentation_requirements.md), [journalentries](journalentries.md).
- Second-level FK neighborhood includes: [cashcollectionjournalentries](cashcollectionjournalentries.md), [documentation_settings](documentation_settings.md), [journalentry_and_role_link](journalentry_and_role_link.md), [journalentry_signatures](journalentry_signatures.md), [persons](persons.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
