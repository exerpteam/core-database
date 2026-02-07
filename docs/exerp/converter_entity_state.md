# converter_entity_state
Operational table for converter entity state records in the Exerp schema. It is typically used where it appears in approximately 39 query files; common companions include [persons](persons.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `entitytype` | Text field containing descriptive or reference information. | `VARCHAR(40)` | No | No | - | - |
| `oldentityid` | Text field containing descriptive or reference information. | `VARCHAR(255)` | No | No | - | - |
| `newentitycenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `newentityid` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `newentitysubid` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `writername` | Text field containing descriptive or reference information. | `VARCHAR(40)` | No | No | - | - |
| `lastupdated` | Table field used by operational and reporting workloads. | `TIMESTAMP` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (37 query files), [subscriptions](subscriptions.md) (29 query files), [products](products.md) (22 query files), [person_ext_attrs](person_ext_attrs.md) (20 query files), [subscriptiontypes](subscriptiontypes.md) (18 query files), [subscription_price](subscription_price.md) (14 query files).
