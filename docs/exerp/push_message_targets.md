# push_message_targets
Operational table for push message targets records in the Exerp schema. It is typically used where it appears in approximately 6 query files; common companions include [event_type_config](event_type_config.md), [templates](templates.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `url` | Business attribute `url` used by push message targets workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `username` | Business attribute `username` used by push message targets workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `password` | Business attribute `password` used by push message targets workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `target_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `use_security_header` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `auth_url` | Business attribute `auth_url` used by push message targets workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `auth_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `secret_key_name` | Business attribute `secret_key_name` used by push message targets workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `secret_key` | Business attribute `secret_key` used by push message targets workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `properties_config_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(200)` | Yes | No | - | - |
| `properties_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [event_type_config](event_type_config.md) (5 query files), [templates](templates.md) (5 query files).
- FK-linked tables: incoming FK from [event_type_config](event_type_config.md).
- Second-level FK neighborhood includes: [message_type_config_relations](message_type_config_relations.md).
