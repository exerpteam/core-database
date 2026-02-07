# jbm_msg
Operational table for jbm msg records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `message_id` | Primary key identifier for this record. | `int8` | No | Yes | - | [messages](messages.md) via (`message_id` -> `id`) |
| `reliable` | Business attribute `reliable` used by jbm msg workflows and reporting. | `bpchar(1)` | Yes | No | - | - |
| `expiration` | Business attribute `expiration` used by jbm msg workflows and reporting. | `int8` | Yes | No | - | - |
| `TIMESTAMP` | Operational field `TIMESTAMP` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `priority` | Business attribute `priority` used by jbm msg workflows and reporting. | `int2` | Yes | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `int2` | Yes | No | - | - |
| `headers` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `payload` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
