# bundle_campaign_product
Operational table for bundle campaign product records in the Exerp schema. It is typically used where it appears in approximately 3 query files; common companions include [product_group](product_group.md), [activity](activity.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `bundle_campaign` | Foreign key field linking this record to `bundle_campaign`. | `int4` | Yes | No | [bundle_campaign](bundle_campaign.md) via (`bundle_campaign` -> `id`) | - | `42` |
| `rebated` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `ref_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `ref_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `ref_center` | Center part of the reference to related ref data. | `int4` | Yes | No | - | - | `101` |
| `ref_id` | Identifier of the related ref record. | `int4` | Yes | No | - | - | `1001` |
| `units` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [product_group](product_group.md) (3 query files), [activity](activity.md) (2 query files), [activity_group](activity_group.md) (2 query files), [booking_resource_usage](booking_resource_usage.md) (2 query files), [staff_usage](staff_usage.md) (2 query files), [subscription_addon](subscription_addon.md) (2 query files).
- FK-linked tables: outgoing FK to [bundle_campaign](bundle_campaign.md).
- Second-level FK neighborhood includes: [bundle_campaign_usages](bundle_campaign_usages.md).
