# doc_requirement_items
Operational table for doc requirement items records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `documentation_requirement_key` | Foreign key field linking this record to `documentation_requirements`. | `int4` | No | No | [documentation_requirements](documentation_requirements.md) via (`documentation_requirement_key` -> `id`) | - |
| `type` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - |
| `item_type_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `itm_instance_journal_entry_key` | Foreign key field linking this record to `journalentries`. | `int4` | Yes | No | [journalentries](journalentries.md) via (`itm_instance_journal_entry_key` -> `id`) | - |
| `item_instance_center` | Center part of the reference to related item instance data. | `int4` | Yes | No | - | - |
| `item_instance_id` | Identifier of the related item instance record. | `int4` | Yes | No | - | - |
| `item_instance_sub_id` | Identifier of the related item instance sub record. | `int4` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `VARCHAR(20)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [documentation_requirements](documentation_requirements.md), [journalentries](journalentries.md).
- Second-level FK neighborhood includes: [cashcollectionjournalentries](cashcollectionjournalentries.md), [documentation_settings](documentation_settings.md), [journalentry_and_role_link](journalentry_and_role_link.md), [journalentry_signatures](journalentry_signatures.md), [persons](persons.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
