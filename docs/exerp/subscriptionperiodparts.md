# subscriptionperiodparts
Stores subscription-related data, including lifecycle and financial context. It is typically used where rows are center-scoped; it appears in approximately 317 query files; common companions include [subscriptions](subscriptions.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [subscriptions](subscriptions.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [subscriptions](subscriptions.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `spp_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `spp_state` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `period_number` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `from_date` | Date for from. | `DATE` | No | No | - | - | `2025-01-31` |
| `to_date` | Date for to. | `DATE` | No | No | - | - | `2025-01-31` |
| `old_billed_until_date` | Date for old billed until. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `subscription_price` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `addons_price` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `cancellation_time` | Epoch timestamp for cancellation. | `int8` | Yes | No | - | - | `1738281600000` |
| `campaign_code_id` | Identifier of the related campaign code record. | `int4` | Yes | No | - | [campaign_codes](campaign_codes.md) via (`campaign_code_id` -> `id`) | `1001` |
| `had_hard_close_role` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `sync_date` | Date for sync. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `prorata_sessions` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `prorata_sessions_total` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (278 query files), [products](products.md) (253 query files), [persons](persons.md) (246 query files), [centers](centers.md) (222 query files), [subscriptiontypes](subscriptiontypes.md) (194 query files), [spp_invoicelines_link](spp_invoicelines_link.md) (189 query files).
- FK-linked tables: outgoing FK to [subscriptions](subscriptions.md); incoming FK from [spp_invoicelines_link](spp_invoicelines_link.md).
- Second-level FK neighborhood includes: [campaign_codes](campaign_codes.md), [centers](centers.md), [clipcards](clipcards.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [products](products.md), [recurring_participations](recurring_participations.md), [startup_campaign](startup_campaign.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
