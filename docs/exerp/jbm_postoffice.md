# jbm_postoffice
Operational table for jbm postoffice records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `postoffice_name` | Primary key component used to uniquely identify this record. | `VARCHAR(255)` | No | Yes | - | - |
| `node_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `queue_name` | Primary key component used to uniquely identify this record. | `VARCHAR(255)` | No | Yes | - | - |
| `cond` | Business attribute `cond` used by jbm postoffice workflows and reporting. | `VARCHAR(1023)` | Yes | No | - | - |
| `selector` | Business attribute `selector` used by jbm postoffice workflows and reporting. | `VARCHAR(1023)` | Yes | No | - | - |
| `channel_id` | Identifier for the related channel entity used by this record. | `int8` | Yes | No | - | - |
| `clustered` | Business attribute `clustered` used by jbm postoffice workflows and reporting. | `bpchar(1)` | Yes | No | - | - |
| `all_nodes` | Business attribute `all_nodes` used by jbm postoffice workflows and reporting. | `bpchar(1)` | Yes | No | - | - |

# Relations
