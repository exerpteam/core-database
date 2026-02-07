# booking_program_levels
Operational table for booking program levels records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `rank` | Operational field `rank` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `booking_program_type_id` | Identifier of the related booking program types record used by this row. | `int4` | No | No | [booking_program_types](booking_program_types.md) via (`booking_program_type_id` -> `id`) | - |
| `required_showup` | Business attribute `required_showup` used by booking program levels workflows and reporting. | `int4` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [booking_program_types](booking_program_types.md); incoming FK from [booking_program_skills](booking_program_skills.md).
- Second-level FK neighborhood includes: [booking_program_person_skills](booking_program_person_skills.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md), [booking_time_configs](booking_time_configs.md), [employees](employees.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
