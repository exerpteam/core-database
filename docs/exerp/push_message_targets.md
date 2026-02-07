# push_message_targets
Operational table for push message targets records in the Exerp schema. It is typically used where it appears in approximately 6 query files; common companions include [event_type_config](event_type_config.md), [templates](templates.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `url` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `username` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `password` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `target_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `use_security_header` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `auth_url` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `auth_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `secret_key_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `secret_key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `properties_config_type` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |
| `properties_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [event_type_config](event_type_config.md) (5 query files), [templates](templates.md) (5 query files).
- FK-linked tables: incoming FK from [event_type_config](event_type_config.md).
- Second-level FK neighborhood includes: [message_type_config_relations](message_type_config_relations.md).
