# tasks
Task-oriented table supporting workflow execution for tasks. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 84 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - | `1` |
| `step_id` | Foreign key field linking this record to `task_steps`. | `int4` | Yes | No | [task_steps](task_steps.md) via (`step_id` -> `id`) | - | `1001` |
| `title` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `source_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `1001` |
| `creator_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - | `101` |
| `creator_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - | `1001` |
| `owner_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - | `101` |
| `owner_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - | `1001` |
| `asignee_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`asignee_center`, `asignee_id` -> `center`, `id`) | - | `101` |
| `asignee_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`asignee_center`, `asignee_id` -> `center`, `id`) | - | `1001` |
| `type_id` | Foreign key field linking this record to `task_types`. | `int4` | No | No | [task_types](task_types.md) via (`type_id` -> `id`) | - | `1001` |
| `invoice_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - | `101` |
| `invoice_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - | `1001` |
| `follow_up` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | Yes | No | - | - | `1738281600000` |
| `last_update_time` | Epoch timestamp for last update. | `int8` | Yes | No | - | - | `1738281600000` |
| `permanent_note` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `last_choice_id` | Foreign key field linking this record to `task_user_choices`. | `int4` | Yes | No | [task_user_choices](task_user_choices.md) via (`last_choice_id` -> `id`) | - | `1001` |
| `task_category_id` | Foreign key field linking this record to `task_categories`. | `int4` | Yes | No | [task_categories](task_categories.md) via (`task_category_id` -> `id`) | - | `1001` |
| `center` | Center identifier associated with the record. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `follow_up_time` | Epoch timestamp for follow up. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- Commonly used with: [persons](persons.md) (82 query files), [centers](centers.md) (60 query files), [task_steps](task_steps.md) (42 query files), [person_ext_attrs](person_ext_attrs.md) (41 query files), [task_log](task_log.md) (32 query files), [task_log_details](task_log_details.md) (23 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [task_categories](task_categories.md), [task_steps](task_steps.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md); incoming FK from [task_log](task_log.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
