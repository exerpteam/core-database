# jbm_postoffice
Operational table for jbm postoffice records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `postoffice_name` | Text field containing descriptive or reference information. | `VARCHAR(255)` | No | Yes | - | - |
| `node_id` | Identifier of the related node record. | `int4` | No | Yes | - | - |
| `queue_name` | Text field containing descriptive or reference information. | `VARCHAR(255)` | No | Yes | - | - |
| `cond` | Text field containing descriptive or reference information. | `VARCHAR(1023)` | Yes | No | - | - |
| `selector` | Text field containing descriptive or reference information. | `VARCHAR(1023)` | Yes | No | - | - |
| `channel_id` | Identifier of the related channel record. | `int8` | Yes | No | - | - |
| `clustered` | Text field containing descriptive or reference information. | `bpchar(1)` | Yes | No | - | - |
| `all_nodes` | Text field containing descriptive or reference information. | `bpchar(1)` | Yes | No | - | - |

# Relations
