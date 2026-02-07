# jbm_tx_ex
Operational table for jbm tx ex records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `transaction_id` | Identifier of the related transaction record. | `int8` | No | Yes | - | - | `1001` |
| `start_time` | Epoch timestamp for start. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
