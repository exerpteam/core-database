# journalentries
Operational table for journalentries records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 328 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_subid` | Business attribute `person_subid` used by journalentries workflows and reporting. | `int4` | Yes | No | - | - |
| `jetype` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | [journalentries_jetype](../master%20tables/journalentries_jetype.md) |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `creatorcenter` | Center component of the composite reference to the creator staff member. | `int4` | Yes | No | - | - |
| `creatorid` | Identifier component of the composite reference to the creator staff member. | `int4` | Yes | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `text` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `big_text_mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `big_text` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `document_name` | Business attribute `document_name` used by journalentries workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `document_layout` | Business attribute `document_layout` used by journalentries workflows and reporting. | `int4` | Yes | No | - | - |
| `document_mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `document` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `signable` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `ref_globalid` | Operational field `ref_globalid` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `ref_center` | Center component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_subid` | Operational field `ref_subid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `expiration_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `checked_signed_doc` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `s3bucket` | Business attribute `s3bucket` used by journalentries workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `s3key` | Business attribute `s3key` used by journalentries workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `text_encrypted` | Business attribute `text_encrypted` used by journalentries workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `big_text_encrypted` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `encryption_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `custom_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `issue_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `replaced_by` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [journalentries](journalentries.md) via (`replaced_by` -> `id`) | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(20)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (292 query files), [centers](centers.md) (204 query files), [subscriptions](subscriptions.md) (181 query files), [person_ext_attrs](person_ext_attrs.md) (152 query files), [products](products.md) (146 query files), [employees](employees.md) (124 query files).
- FK-linked tables: outgoing FK to [journalentries](journalentries.md), [persons](persons.md); incoming FK from [cashcollectionjournalentries](cashcollectionjournalentries.md), [doc_requirement_items](doc_requirement_items.md), [journalentries](journalentries.md), [journalentry_and_role_link](journalentry_and_role_link.md), [journalentry_signatures](journalentry_signatures.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
