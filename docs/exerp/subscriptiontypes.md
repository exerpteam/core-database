# subscriptiontypes
Stores subscription-related data, including lifecycle and financial context. It is typically used where rows are center-scoped; it appears in approximately 1384 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `change_requiredrole` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `reactivation_allowed` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `st_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `use_individual_price` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `productnew_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`productnew_center`, `productnew_id` -> `center`, `id`) | - | `101` |
| `productnew_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`productnew_center`, `productnew_id` -> `center`, `id`) | - | `1001` |
| `floatingperiod` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `prorataperiodcount` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `extend_binding_by_prorata` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `initialperiodcount` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `extend_binding_by_initial` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `bindingperiodcount` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `periodunit` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `periodcount` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `age_restriction_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `age_restriction_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `sex_restriction` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `freezelimit` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `freezeperiodproduct_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`freezeperiodproduct_center`, `freezeperiodproduct_id` -> `center`, `id`) | - | `101` |
| `freezeperiodproduct_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`freezeperiodproduct_center`, `freezeperiodproduct_id` -> `center`, `id`) | - | `1001` |
| `freezestartupproduct_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`freezestartupproduct_center`, `freezestartupproduct_id` -> `center`, `id`) | - | `101` |
| `freezestartupproduct_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`freezestartupproduct_center`, `freezestartupproduct_id` -> `center`, `id`) | - | `1001` |
| `transferproduct_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`transferproduct_center`, `transferproduct_id` -> `center`, `id`) | - | `101` |
| `transferproduct_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`transferproduct_center`, `transferproduct_id` -> `center`, `id`) | - | `1001` |
| `add_on_to_center` | Center part of the reference to related add on to data. | `int4` | Yes | No | - | - | `101` |
| `add_on_to_id` | Identifier of the related add on to record. | `int4` | Yes | No | - | - | `1001` |
| `renew_window` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `is_addon_subscription` | Boolean flag indicating whether addon subscription applies. | `bool` | No | No | - | - | `true` |
| `prorataproduct_center` | Center part of the reference to related prorataproduct data. | `int4` | Yes | No | - | - | `101` |
| `prorataproduct_id` | Identifier of the related prorataproduct record. | `int4` | Yes | No | - | - | `1001` |
| `adminfeeproduct_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`adminfeeproduct_center`, `adminfeeproduct_id` -> `center`, `id`) | - | `101` |
| `adminfeeproduct_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`adminfeeproduct_center`, `adminfeeproduct_id` -> `center`, `id`) | - | `1001` |
| `info_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `clearing_house_restriction` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `is_price_update_excluded` | Boolean flag indicating whether price update excluded applies. | `bool` | Yes | No | - | - | `true` |
| `start_date_limit_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `start_date_limit_unit` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `start_date_restriction` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `auto_stop_on_binding_end_date` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `roundup_end_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `buyoutfeeproduct_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`buyoutfeeproduct_center`, `buyoutfeeproduct_id` -> `center`, `id`) | - | `101` |
| `buyoutfeeproduct_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`buyoutfeeproduct_center`, `buyoutfeeproduct_id` -> `center`, `id`) | - | `1001` |
| `rec_clipcard_product_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`rec_clipcard_product_center`, `rec_clipcard_product_id` -> `center`, `id`) | - | `101` |
| `rec_clipcard_product_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`rec_clipcard_product_center`, `rec_clipcard_product_id` -> `center`, `id`) | - | `1001` |
| `rec_clipcard_product_clips` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `sale_startup_clipcard` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `autorenew_binding_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `autorenew_binding_unit` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `autorenew_binding_notice_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `autorenew_binding_notice_unit` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `unrestricted_freeze_allowed` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `buyout_fee_percentage` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `can_be_reassigned` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `reassign_product_center` | Center part of the reference to related reassign product data. | `int4` | Yes | No | - | - | `101` |
| `reassign_product_id` | Identifier of the related reassign product record. | `int4` | Yes | No | - | - | `1001` |
| `reassign_template` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `rec_clipcard_pack_size` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `age_restriction_min_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `age_restriction_max_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `documentation_setting_id` | Identifier of the related documentation setting record. | `int4` | Yes | No | - | [documentation_settings](documentation_settings.md) via (`documentation_setting_id` -> `id`) | `1001` |
| `reassign_restrict_quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `reassign_restrict_span_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `reassign_restrict_span_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `reassign_restrict_type_id` | Identifier of the related reassign restrict type record. | `int4` | Yes | No | - | - | `1001` |
| `family_membership_type` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - | `Sample value` |
| `renewal_requires_privilege` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `is_member_operations_restricted_around_deduction_date` | Boolean flag indicating whether member operations restricted around deduction date applies. | `bool` | No | No | - | - | `true` |
| `member_operations_restricted_days_before_deduction_date` | Date for member operations restricted days before deduction. | `int4` | No | No | - | - | `42` |
| `member_operations_restricted_days_after_deduction_date` | Date for member operations restricted days after deduction. | `int4` | No | No | - | - | `42` |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (1321 query files), [persons](persons.md) (1156 query files), [products](products.md) (1105 query files), [centers](centers.md) (927 query files), [person_ext_attrs](person_ext_attrs.md) (526 query files), [subscription_price](subscription_price.md) (515 query files).
- FK-linked tables: outgoing FK to [products](products.md); incoming FK from [subscription_sales](subscription_sales.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [campaign_codes](campaign_codes.md), [centers](centers.md), [clipcards](clipcards.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [employees](employees.md), [families](families.md), [gift_cards](gift_cards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
