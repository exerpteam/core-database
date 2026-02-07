# subscriptiontypes
Stores subscription-related data, including lifecycle and financial context. It is typically used where rows are center-scoped; it appears in approximately 1384 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - |
| `change_requiredrole` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `reactivation_allowed` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - |
| `st_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `use_individual_price` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `productnew_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`productnew_center`, `productnew_id` -> `center`, `id`) | - |
| `productnew_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`productnew_center`, `productnew_id` -> `center`, `id`) | - |
| `floatingperiod` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `prorataperiodcount` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `extend_binding_by_prorata` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `initialperiodcount` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `extend_binding_by_initial` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `bindingperiodcount` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `periodunit` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `periodcount` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `age_restriction_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `age_restriction_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `sex_restriction` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `freezelimit` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `freezeperiodproduct_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`freezeperiodproduct_center`, `freezeperiodproduct_id` -> `center`, `id`) | - |
| `freezeperiodproduct_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`freezeperiodproduct_center`, `freezeperiodproduct_id` -> `center`, `id`) | - |
| `freezestartupproduct_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`freezestartupproduct_center`, `freezestartupproduct_id` -> `center`, `id`) | - |
| `freezestartupproduct_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`freezestartupproduct_center`, `freezestartupproduct_id` -> `center`, `id`) | - |
| `transferproduct_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`transferproduct_center`, `transferproduct_id` -> `center`, `id`) | - |
| `transferproduct_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`transferproduct_center`, `transferproduct_id` -> `center`, `id`) | - |
| `add_on_to_center` | Center part of the reference to related add on to data. | `int4` | Yes | No | - | - |
| `add_on_to_id` | Identifier of the related add on to record. | `int4` | Yes | No | - | - |
| `renew_window` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `is_addon_subscription` | Boolean flag indicating whether addon subscription applies. | `bool` | No | No | - | - |
| `prorataproduct_center` | Center part of the reference to related prorataproduct data. | `int4` | Yes | No | - | - |
| `prorataproduct_id` | Identifier of the related prorataproduct record. | `int4` | Yes | No | - | - |
| `adminfeeproduct_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`adminfeeproduct_center`, `adminfeeproduct_id` -> `center`, `id`) | - |
| `adminfeeproduct_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`adminfeeproduct_center`, `adminfeeproduct_id` -> `center`, `id`) | - |
| `info_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `clearing_house_restriction` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `is_price_update_excluded` | Boolean flag indicating whether price update excluded applies. | `bool` | Yes | No | - | - |
| `start_date_limit_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `start_date_limit_unit` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `start_date_restriction` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `auto_stop_on_binding_end_date` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `roundup_end_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `buyoutfeeproduct_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`buyoutfeeproduct_center`, `buyoutfeeproduct_id` -> `center`, `id`) | - |
| `buyoutfeeproduct_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`buyoutfeeproduct_center`, `buyoutfeeproduct_id` -> `center`, `id`) | - |
| `rec_clipcard_product_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`rec_clipcard_product_center`, `rec_clipcard_product_id` -> `center`, `id`) | - |
| `rec_clipcard_product_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`rec_clipcard_product_center`, `rec_clipcard_product_id` -> `center`, `id`) | - |
| `rec_clipcard_product_clips` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `sale_startup_clipcard` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `autorenew_binding_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `autorenew_binding_unit` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `autorenew_binding_notice_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `autorenew_binding_notice_unit` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `unrestricted_freeze_allowed` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `buyout_fee_percentage` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `can_be_reassigned` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `reassign_product_center` | Center part of the reference to related reassign product data. | `int4` | Yes | No | - | - |
| `reassign_product_id` | Identifier of the related reassign product record. | `int4` | Yes | No | - | - |
| `reassign_template` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `rec_clipcard_pack_size` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `age_restriction_min_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `age_restriction_max_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `documentation_setting_id` | Identifier of the related documentation setting record. | `int4` | Yes | No | - | [documentation_settings](documentation_settings.md) via (`documentation_setting_id` -> `id`) |
| `reassign_restrict_quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `reassign_restrict_span_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `reassign_restrict_span_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `reassign_restrict_type_id` | Identifier of the related reassign restrict type record. | `int4` | Yes | No | - | - |
| `family_membership_type` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - |
| `renewal_requires_privilege` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `is_member_operations_restricted_around_deduction_date` | Boolean flag indicating whether member operations restricted around deduction date applies. | `bool` | No | No | - | - |
| `member_operations_restricted_days_before_deduction_date` | Date for member operations restricted days before deduction. | `int4` | No | No | - | - |
| `member_operations_restricted_days_after_deduction_date` | Date for member operations restricted days after deduction. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (1321 query files), [persons](persons.md) (1156 query files), [products](products.md) (1105 query files), [centers](centers.md) (927 query files), [person_ext_attrs](person_ext_attrs.md) (526 query files), [subscription_price](subscription_price.md) (515 query files).
- FK-linked tables: outgoing FK to [products](products.md); incoming FK from [subscription_sales](subscription_sales.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [campaign_codes](campaign_codes.md), [centers](centers.md), [clipcards](clipcards.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [employees](employees.md), [families](families.md), [gift_cards](gift_cards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
