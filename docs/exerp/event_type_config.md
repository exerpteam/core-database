# event_type_config
Configuration table for event type config behavior and defaults. It is typically used where lifecycle state codes are present; it appears in approximately 18 query files; common companions include [templates](templates.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `event_type_id` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `event_source` | Business attribute `event_source` used by event type config workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `event_source_service` | Business attribute `event_source_service` used by event type config workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `action_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `url` | Business attribute `url` used by event type config workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `push_message_target_id` | Identifier of the related push message targets record used by this row. | `int4` | Yes | No | [push_message_targets](push_message_targets.md) via (`push_message_target_id` -> `id`) | - |
| `push_template_id` | Identifier for the related push template entity used by this record. | `int4` | Yes | No | - | - |
| `event_filter_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `action_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `asynchronous` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `batch_job` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `last_changed_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int8` | No | No | - | - |
| `action_overridable_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `action_properties_mapping` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `event_conditions` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [templates](templates.md) (12 query files), [persons](persons.md) (8 query files), [centers](centers.md) (7 query files), [messages](messages.md) (6 query files), [sms](sms.md) (5 query files), [push_message_targets](push_message_targets.md) (5 query files).
- FK-linked tables: outgoing FK to [push_message_targets](push_message_targets.md); incoming FK from [message_type_config_relations](message_type_config_relations.md).
- Second-level FK neighborhood includes: [templates](templates.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
