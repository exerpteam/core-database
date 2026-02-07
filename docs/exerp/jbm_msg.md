# jbm_msg
Operational table for jbm msg records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `message_id` | Identifier of the related message record. | `int8` | No | Yes | - | [messages](messages.md) via (`message_id` -> `id`) | `1001` |
| `reliable` | Text field containing descriptive or reference information. | `bpchar(1)` | Yes | No | - | - | `Sample value` |
| `expiration` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `TIMESTAMP` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `priority` | Numeric field used for identifiers, counters, or coded values. | `int2` | Yes | No | - | - | `42` |
| `type` | Numeric field used for identifiers, counters, or coded values. | `int2` | Yes | No | - | - | `1` |
| `headers` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `payload` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
