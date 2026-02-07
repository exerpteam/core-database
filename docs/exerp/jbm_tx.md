# jbm_tx
Operational table for jbm tx records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `node_id` | Identifier of the related node record. | `int4` | Yes | No | - | - | `1001` |
| `transaction_id` | Identifier of the related transaction record. | `int8` | No | Yes | - | - | `1001` |
| `branch_qual` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `format_id` | Identifier of the related format record. | `int4` | Yes | No | - | - | `1001` |
| `global_txid` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
