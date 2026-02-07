# campaign_code_usages
Operational table for campaign code usages records in the Exerp schema. It is typically used where it appears in approximately 4 query files; common companions include [campaign_codes](campaign_codes.md), [privilege_usages](privilege_usages.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `campaign_code_id` | Foreign key field linking this record to `campaign_codes`. | `int4` | No | No | [campaign_codes](campaign_codes.md) via (`campaign_code_id` -> `id`) | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - |
| `usage_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [campaign_codes](campaign_codes.md) (4 query files), [privilege_usages](privilege_usages.md) (3 query files).
- FK-linked tables: outgoing FK to [campaign_codes](campaign_codes.md).
- Second-level FK neighborhood includes: [privilege_usages](privilege_usages.md), [subscription_retention_campaigns](subscription_retention_campaigns.md), [subscriptions](subscriptions.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier.
