# jbm_msg
Operational table for jbm msg records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `message_id` | Identifier of the related message record. | `int8` | No | Yes | - | [messages](messages.md) via (`message_id` -> `id`) |
| `reliable` | Text field containing descriptive or reference information. | `bpchar(1)` | Yes | No | - | - |
| `expiration` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `TIMESTAMP` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `priority` | Numeric field used for identifiers, counters, or coded values. | `int2` | Yes | No | - | - |
| `type` | Numeric field used for identifiers, counters, or coded values. | `int2` | Yes | No | - | - |
| `headers` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `payload` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
