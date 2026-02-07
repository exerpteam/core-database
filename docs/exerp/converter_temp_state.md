# converter_temp_state
Intermediate/cache table used to accelerate converter temp state processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `entitytype` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(40)` | No | No | - | - |
| `oldid` | Operational field `oldid` used in query filtering and reporting transformations. | `VARCHAR(255)` | No | No | - | - |
| `newcenter` | Center component of the composite reference to the related new record. | `int4` | No | No | - | - |
| `newid` | Identifier component of the composite reference to the related new record. | `int4` | No | No | - | - |
| `newsubid` | Business attribute `newsubid` used by converter temp state workflows and reporting. | `int4` | No | No | - | - |
| `datatype` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(20)` | No | No | - | - |
| `lastupdated` | Business attribute `lastupdated` used by converter temp state workflows and reporting. | `TIMESTAMP` | No | No | - | - |

# Relations
