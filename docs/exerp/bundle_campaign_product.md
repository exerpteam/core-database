# bundle_campaign_product
Operational table for bundle campaign product records in the Exerp schema. It is typically used where it appears in approximately 3 query files; common companions include [product_group](product_group.md), [activity](activity.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `bundle_campaign` | Identifier of the related bundle campaign record used by this row. | `int4` | Yes | No | [bundle_campaign](bundle_campaign.md) via (`bundle_campaign` -> `id`) | - |
| `rebated` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `ref_type` | Classification code describing the ref type category (for example: PERSON). | `text(2147483647)` | No | No | - | - |
| `ref_globalid` | Operational field `ref_globalid` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `ref_center` | Center component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `units` | Business attribute `units` used by bundle campaign product workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [product_group](product_group.md) (3 query files), [activity](activity.md) (2 query files), [activity_group](activity_group.md) (2 query files), [booking_resource_usage](booking_resource_usage.md) (2 query files), [staff_usage](staff_usage.md) (2 query files), [subscription_addon](subscription_addon.md) (2 query files).
- FK-linked tables: outgoing FK to [bundle_campaign](bundle_campaign.md).
- Second-level FK neighborhood includes: [bundle_campaign_usages](bundle_campaign_usages.md).
