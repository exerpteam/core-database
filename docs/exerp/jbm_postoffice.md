# jbm_postoffice
Operational table for jbm postoffice records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `postoffice_name` | Text field containing descriptive or reference information. | `VARCHAR(255)` | No | Yes | - | - | `Example Name` |
| `node_id` | Identifier of the related node record. | `int4` | No | Yes | - | - | `1001` |
| `queue_name` | Text field containing descriptive or reference information. | `VARCHAR(255)` | No | Yes | - | - | `Example Name` |
| `cond` | Text field containing descriptive or reference information. | `VARCHAR(1023)` | Yes | No | - | - | `Sample value` |
| `selector` | Text field containing descriptive or reference information. | `VARCHAR(1023)` | Yes | No | - | - | `Sample value` |
| `channel_id` | Identifier of the related channel record. | `int8` | Yes | No | - | - | `1001` |
| `clustered` | Text field containing descriptive or reference information. | `bpchar(1)` | Yes | No | - | - | `Sample value` |
| `all_nodes` | Text field containing descriptive or reference information. | `bpchar(1)` | Yes | No | - | - | `Sample value` |

# Relations
