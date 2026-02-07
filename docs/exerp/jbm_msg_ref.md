# jbm_msg_ref
Operational table for jbm msg ref records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `message_id` | Identifier of the related message record. | `int8` | No | Yes | - | [messages](messages.md) via (`message_id` -> `id`) |
| `channel_id` | Identifier of the related channel record. | `int8` | No | Yes | - | - |
| `transaction_id` | Identifier of the related transaction record. | `int8` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `bpchar(1)` | Yes | No | - | - |
| `ord` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `page_ord` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `delivery_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `sched_delivery` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
