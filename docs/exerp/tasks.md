# tasks
Task-oriented table supporting workflow execution for tasks. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 84 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `step_id` | Identifier of the related task steps record used by this row. | `int4` | Yes | No | [task_steps](task_steps.md) via (`step_id` -> `id`) | - |
| `title` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `source_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `creator_center` | Center component of the composite reference to the creator staff member. | `int4` | No | No | [persons](persons.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - |
| `creator_id` | Identifier component of the composite reference to the creator staff member. | `int4` | No | No | [persons](persons.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - |
| `owner_center` | Center component of the composite reference to the owner person. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `owner_id` | Identifier component of the composite reference to the owner person. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `asignee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [persons](persons.md) via (`asignee_center`, `asignee_id` -> `center`, `id`) | - |
| `asignee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [persons](persons.md) via (`asignee_center`, `asignee_id` -> `center`, `id`) | - |
| `type_id` | Identifier of the related task types record used by this row. | `int4` | No | No | [task_types](task_types.md) via (`type_id` -> `id`) | - |
| `invoice_center` | Center component of the composite reference to the related invoice record. | `int4` | Yes | No | [persons](persons.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |
| `invoice_id` | Identifier component of the composite reference to the related invoice record. | `int4` | Yes | No | [persons](persons.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |
| `follow_up` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `last_update_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `permanent_note` | Business attribute `permanent_note` used by tasks workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `last_choice_id` | Identifier of the related task user choices record used by this row. | `int4` | Yes | No | [task_user_choices](task_user_choices.md) via (`last_choice_id` -> `id`) | - |
| `task_category_id` | Identifier of the related task categories record used by this row. | `int4` | Yes | No | [task_categories](task_categories.md) via (`task_category_id` -> `id`) | - |
| `center` | Operational field `center` used in query filtering and reporting transformations. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) |
| `follow_up_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (82 query files), [centers](centers.md) (60 query files), [task_steps](task_steps.md) (42 query files), [person_ext_attrs](person_ext_attrs.md) (41 query files), [task_log](task_log.md) (32 query files), [task_log_details](task_log_details.md) (23 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [task_categories](task_categories.md), [task_steps](task_steps.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md); incoming FK from [task_log](task_log.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
