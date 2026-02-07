# daily_member_status_changes
Operational table for daily member status changes records in the Exerp schema. It is typically used where it appears in approximately 36 query files; common companions include [persons](persons.md), [state_change_log](state_change_log.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `change_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `change` | Operational field `change` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `member_number_delta` | Operational field `member_number_delta` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `extra_number_delta` | Business attribute `extra_number_delta` used by daily member status changes workflows and reporting. | `int4` | No | No | - | - |
| `secondary_member_number_delta` | Business attribute `secondary_member_number_delta` used by daily member status changes workflows and reporting. | `int4` | No | No | - | - |
| `entry_start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `entry_stop_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (36 query files), [state_change_log](state_change_log.md) (27 query files), [person_ext_attrs](person_ext_attrs.md) (24 query files), [journalentries](journalentries.md) (22 query files), [entityidentifiers](entityidentifiers.md) (20 query files), [account_receivables](account_receivables.md) (16 query files).
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
