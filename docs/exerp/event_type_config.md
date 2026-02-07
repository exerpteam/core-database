# event_type_config
Configuration table for event type config behavior and defaults. It is typically used where lifecycle state codes are present; it appears in approximately 18 query files; common companions include [templates](templates.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `event_type_id` | Identifier of the related event type record. | `int4` | Yes | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `event_source` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `event_source_service` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `action_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `url` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `push_message_target_id` | Foreign key field linking this record to `push_message_targets`. | `int4` | Yes | No | [push_message_targets](push_message_targets.md) via (`push_message_target_id` -> `id`) | - |
| `push_template_id` | Identifier of the related push template record. | `int4` | Yes | No | - | - |
| `event_filter_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `action_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `asynchronous` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `batch_job` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `last_changed_date` | Date for last changed. | `int8` | No | No | - | - |
| `action_overridable_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `action_properties_mapping` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `event_conditions` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [templates](templates.md) (12 query files), [persons](persons.md) (8 query files), [centers](centers.md) (7 query files), [messages](messages.md) (6 query files), [sms](sms.md) (5 query files), [push_message_targets](push_message_targets.md) (5 query files).
- FK-linked tables: outgoing FK to [push_message_targets](push_message_targets.md); incoming FK from [message_type_config_relations](message_type_config_relations.md).
- Second-level FK neighborhood includes: [templates](templates.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
