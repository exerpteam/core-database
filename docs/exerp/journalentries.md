# journalentries
Operational table for journalentries records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 328 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_subid` | Sub-identifier for related person detail rows. | `int4` | Yes | No | - | - |
| `jetype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `creatorcenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `creatorid` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | No | No | - | - |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `big_text_mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `big_text` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `document_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `document_layout` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `document_mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `document` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `signable` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `ref_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `ref_center` | Center part of the reference to related ref data. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier of the related ref record. | `int4` | Yes | No | - | - |
| `ref_subid` | Sub-identifier for related ref detail rows. | `int4` | Yes | No | - | - |
| `expiration_date` | Date for expiration. | `DATE` | Yes | No | - | - |
| `checked_signed_doc` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `s3bucket` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `s3key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `text_encrypted` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `big_text_encrypted` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `encryption_time` | Epoch timestamp for encryption. | `int8` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `custom_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `issue_date` | Date for issue. | `DATE` | Yes | No | - | - |
| `replaced_by` | Foreign key field linking this record to `journalentries`. | `int4` | Yes | No | [journalentries](journalentries.md) via (`replaced_by` -> `id`) | - |
| `STATE` | State code representing the current processing state. | `VARCHAR(20)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (292 query files), [centers](centers.md) (204 query files), [subscriptions](subscriptions.md) (181 query files), [person_ext_attrs](person_ext_attrs.md) (152 query files), [products](products.md) (146 query files), [employees](employees.md) (124 query files).
- FK-linked tables: outgoing FK to [journalentries](journalentries.md), [persons](persons.md); incoming FK from [cashcollectionjournalentries](cashcollectionjournalentries.md), [doc_requirement_items](doc_requirement_items.md), [journalentries](journalentries.md), [journalentry_and_role_link](journalentry_and_role_link.md), [journalentry_signatures](journalentry_signatures.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
