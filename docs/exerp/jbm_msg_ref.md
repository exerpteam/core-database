# jbm_msg_ref
Operational table for jbm msg ref records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `message_id` | Primary key component used to uniquely identify this record. | `int8` | No | Yes | - | [messages](messages.md) via (`message_id` -> `id`) |
| `channel_id` | Primary key component used to uniquely identify this record. | `int8` | No | Yes | - | - |
| `transaction_id` | Identifier for the related transaction entity used by this record. | `int8` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `bpchar(1)` | Yes | No | - | - |
| `ord` | Business attribute `ord` used by jbm msg ref workflows and reporting. | `int8` | Yes | No | - | - |
| `page_ord` | Business attribute `page_ord` used by jbm msg ref workflows and reporting. | `int8` | Yes | No | - | - |
| `delivery_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `sched_delivery` | Business attribute `sched_delivery` used by jbm msg ref workflows and reporting. | `int8` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
