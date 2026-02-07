# booking_program_levels
Operational table for booking program levels records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `booking_program_type_id` | Foreign key field linking this record to `booking_program_types`. | `int4` | No | No | [booking_program_types](booking_program_types.md) via (`booking_program_type_id` -> `id`) | - | `1001` |
| `required_showup` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |

# Relations
- FK-linked tables: outgoing FK to [booking_program_types](booking_program_types.md); incoming FK from [booking_program_skills](booking_program_skills.md).
- Second-level FK neighborhood includes: [booking_program_person_skills](booking_program_person_skills.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md), [booking_time_configs](booking_time_configs.md), [employees](employees.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
