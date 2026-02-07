# daily_member_status_changes
Operational table for daily member status changes records in the Exerp schema. It is typically used where it appears in approximately 36 query files; common companions include [persons](persons.md), [state_change_log](state_change_log.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `1001` |
| `change_date` | Date for change. | `DATE` | No | No | - | - | `2025-01-31` |
| `change` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `member_number_delta` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `extra_number_delta` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `secondary_member_number_delta` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `entry_start_time` | Epoch timestamp for entry start. | `int8` | No | No | - | - | `1738281600000` |
| `entry_stop_time` | Epoch timestamp for entry stop. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- Commonly used with: [persons](persons.md) (36 query files), [state_change_log](state_change_log.md) (27 query files), [person_ext_attrs](person_ext_attrs.md) (24 query files), [journalentries](journalentries.md) (22 query files), [entityidentifiers](entityidentifiers.md) (20 query files), [account_receivables](account_receivables.md) (16 query files).
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
