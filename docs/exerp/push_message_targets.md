# push_message_targets
Operational table for push message targets records in the Exerp schema. It is typically used where it appears in approximately 6 query files; common companions include [event_type_config](event_type_config.md), [templates](templates.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `url` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `username` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `password` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `target_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `use_security_header` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `auth_url` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `auth_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `secret_key_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `secret_key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `properties_config_type` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - | `Sample value` |
| `properties_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
- Commonly used with: [event_type_config](event_type_config.md) (5 query files), [templates](templates.md) (5 query files).
- FK-linked tables: incoming FK from [event_type_config](event_type_config.md).
- Second-level FK neighborhood includes: [message_type_config_relations](message_type_config_relations.md).
