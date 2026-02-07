# extract_parameter
Operational table for extract parameter records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `EXTRACT` | Identifier of the related extract record used by this row. | `int4` | Yes | No | [extract](extract.md) via (`EXTRACT` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `label` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |
| `default_value_text_value` | Business attribute `default_value_text_value` used by extract parameter workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `default_value_mime_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `default_value_mime_value` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [extract](extract.md).
- Second-level FK neighborhood includes: [extract_group_link](extract_group_link.md), [extract_usage](extract_usage.md), [roles](roles.md).
