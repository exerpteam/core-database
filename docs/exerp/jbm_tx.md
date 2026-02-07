# jbm_tx
Operational table for jbm tx records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `node_id` | Identifier of the related node record. | `int4` | Yes | No | - | - |
| `transaction_id` | Identifier of the related transaction record. | `int8` | No | Yes | - | - |
| `branch_qual` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `format_id` | Identifier of the related format record. | `int4` | Yes | No | - | - |
| `global_txid` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
