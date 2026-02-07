# documentation_requirements
Operational table for documentation requirements records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 2 query files; common companions include [area_centers](area_centers.md), [areas](areas.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `documentation_setting_key` | Foreign key field linking this record to `documentation_settings`. | `int4` | No | No | [documentation_settings](documentation_settings.md) via (`documentation_setting_key` -> `id`) | - |
| `source_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `source_center` | Center part of the reference to related source data. | `int4` | Yes | No | - | - |
| `source_id` | Identifier of the related source record. | `int4` | Yes | No | - | - |
| `source_sub_id` | Identifier of the related source sub record. | `int4` | Yes | No | - | - |
| `source_owner_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`source_owner_center`, `source_owner_id` -> `center`, `id`) | - |
| `source_owner_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`source_owner_center`, `source_owner_id` -> `center`, `id`) | - |
| `STATE` | State code representing the current processing state. | `VARCHAR(20)` | No | No | - | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | No | No | - | - |
| `completion_time` | Epoch timestamp for completion. | `int8` | Yes | No | - | - |
| `documentation_setting_type` | Text field containing descriptive or reference information. | `VARCHAR(20)` | No | No | - | - |
| `is_needed` | Boolean flag indicating whether needed applies. | `bool` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [area_centers](area_centers.md) (2 query files), [areas](areas.md) (2 query files), [centers](centers.md) (2 query files).
- FK-linked tables: outgoing FK to [documentation_settings](documentation_settings.md), [persons](persons.md); incoming FK from [doc_requirement_items](doc_requirement_items.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
