SELECT
    COUNT(center) messages_sent,
    center,
    SUBJECT,
    DELIVERYCODE,
    DELIVERYMETHOD,
    TEMPLATE_TYPE,
    MESSAGE_TYPE
FROM
    (
        SELECT DISTINCT
            m.CENTER,
            m.ID,
            m.SUBID,
            m.SUBJECT,
            DECODE (m.DELIVERYCODE,0,'undelivered',1,'staff',2,'email',3,'expired',4,'kiosk',5,'web',6,'sms',7,'canceled',8,'letter',9,'failed',10,'unchargable',11,'undeliverable') AS DELIVERYCODE,
            DECODE (m.DELIVERYMETHOD,0,'staff',1,'email',2,'sms',3,'personalInterface',4,'blockPersonalInterface',5,'letter')                                                        AS DELIVERYMETHOD,
            DECODE (
                CASE
                    WHEN m.TEMPLATETYPE IS NOT NULL
                    THEN m.TEMPLATETYPE
                    ELSE t.TTYPE
                END ,7,'EFTAgreement',9,'CustomerContract',10,'CashSubscriptionRenewalReminder',13,'CashCollectionNotification',14,'CashCollectionReminder',17,'CustomerReceipt',18,'CustomerCreditNote',19,'AttendanceTicket',29,'CompanyAgreement',30,'StaffToCustomer',31,'Invoice',34,'GiftCard',35,'OtherEFTPayer',38,'PaymentNote',39,'EftSubscriptionTermination',40,'CreateFreezeReceipt',41,'ChangeFreezeReceipt',43,'PersonTypeDocumentationReceipt',45,'UpgradeDowngradeReceipt',46,'TransferReceipt',47,'AnticipatedCashSubscriptionTerminationReceipt',48,'VoucherReceipt',50,'SavedFreeDaysUseReceipt',51,'ParticipationPrintList',55,'CashCollectionRequestRemainingAndStop',56,'SubscriptionRegret',57,'OtherEFTPayerStopped',60,'CashoutReceipt',62,'DocumentationReminder',63,'DocumentationExpired',64,'SubscriptionPriceChange',65,'SendPassword',66,'TodoNotification',67,'CashCollectionBlockSubscription',68,'WebSale',69,'NewsLetter',70,'WebSaleSubsciptionContract',71,'WebCreateCustomer',72,
                'ParticipationCashPenalty',73,'ParticipationClipCardPenalty',74,'ParticipationEFTPenalty',75,'ParticipationBookingRestrictionPenalty',76,'TrainingProgram',77,'AccountPaymentNote',78,'BillReceipt',79,'ParticipationShowup',80,'SanctionDayBlockWarning',81,'SanctionClipWarning',82,'SanctionServiceProductWarning',83,'SanctionBookingRestrictionWarning',84,'ParticipationCancel',85,'ParticipationMovedUp',86,'ParticipationContactList',87,'Signature',88,'SubscriptionSale',89,'StaffCancel',90,'ParticipationCreation',91,'ParticipationMove',92,'EftCancelSubscriptionTermination',93,'BookingSchedule',94,'CancelFreezeReceipt',95,'InternalUse',96,'InventoryStatus',97,'BookingReminderCourt',98,'BookingReminderStaff',99,'BookingReminderClass',100,'ParticipationConfirmationClass',101,'ParticipationConfirmationCourt',102,'ParticipationConfirmationStaff',103,'FreezeEnd',104,'AccountTransactions',105,'SignedReceipt',106,'CashRegisterStatus',107,'AssignFreePeriodReceipt',108,
                'CancelFreePeriodReceipt',109,'Birthday',110,'PasswordExpirationWarning',111,'CashAccountCredit',112,'VendingMachineRefill',113,'VendingMachineSalesRegistration',114,'PaymentRequestNotification',115,'AddonTermination',116,'AddonTerminationCancellation',117,'AddonSale',118,'ChildRelationContract',119,'AdvancedAgreementNotification',120,'ChildCareContactsList',121,'BookingStaffChange',122,'WebPrivacyStatement',123,'WebPersonInfo',124,'WebSubscriptionCreationInfo',125,'WebTermsAndConditions',126,'WebSaleReceipt',127,'PaymentAgreementCreation',128,'Questionnaire',129,'CheckIn',130,'Attend',131,'PersonCreated',132,'PersonDetailsChanged',133,'PersonStateChanged',134,'PersonTransferred',135,'CompanyDetailsChanged',136,'CompanyAgreementDetailsChanged',137,'ParticipationStateChanged',138,'BookingCreated',139,'BookingCancelled',140,'BookingChanged',141,'PaymentAgreementExpiration',142,'SignupPage',143,'EftPaymentMethod',144,'CCPaymentMethod',145,'CustomerDetailsWebTemplate',146
                , 'SelectMembershipWebTemplate',147,'ConfirmationPageWebTemplate',149,'PaymentSuccessPage',151,'PaymentFailedPage',152,'WebMenu',153,'WebSubMenu',154,'LeadOnlineSalesDiscontinued',155,'ProductSale',156,'ProductCredit',157,'CaldavFailure') AS TEMPLATE_TYPE,
            DECODE (m.MESSAGE_TYPE_ID,0,'REMINDER_STUDENT_DOCUMENTATION',1,'REMINDER_FRIEND_DOCUMENTATION',2,'REMINDER_CORPORATE_DOCUMENTATION',3,'REMINDER_FAMILY_DOCUMENTATION',4,'REMINDER_SENIOR_DOCUMENTATION',5,'EXPIRED_STUDENT_DOCUMENTATION',6,'EXPIRED_FRIEND_DOCUMENTATION',7,'EXPIRED_CORPORATE_DOCUMENTATION',8,'EXPIRED_FAMILY_DOCUMENTATION',9,'EXPIRED_SENIOR_DOCUMENTATION',10,'STAFF_TO_CUSTOMER',11,'CASH_SUBSCRIPTION_RENEWAL_REMINDER',12,'SUBSCRIPTION_PRICE_CHANGE',15,'SEND_PASSWORD',16,'PAY_FOR_OTHER_PERSONS_EFT_SUBSCRIPTION_START',17,'PAY_FOR_OTHER_PERSONS_EFT_SUBSCRIPTION_STOP',19,'CASH_COLLECTION_REMINDER',20,'CASH_COLLECTION_NOTIFICATION',21,'CASH_COLLECTION_REQUEST_REMAINING_AND_STOP',22,'TODO_COMPLETED',23,'WEB_SALES',24,'CASH_COLLECTION_BLOCK',25,'NEWS_LETTER',26,'WEB_SALES_SUBSCRIPTION_CONTRACT',27,'WEB_CREATE_CUSTOMER',28,'SANCTION_SERVICE_PRODUCT_PUNISHMENT',29,'SANCTION_DAY_BLOCK_PUNISHMENT',30,'SANCTION_CLIP_PUNISHMENT',31,'SANCTION_BOOKING_RESTRICTION_PUNISHMENT',
            32, 'SANCTION_SERVICE_PRODUCT_WARNING',33,'SANCTION_DAY_BLOCK_WARNING',34,'SANCTION_CLIP_WARNING',35,'SANCTION_BOOKING_RESTRICTION_WARNING',36,'PARTICIPATION_CANCELATION_BY_STAFF',37,'PARTICIPATION_MOVEDUP',38,'SUBSCRIPTION_SALE',39,'STAFF_CANCELATION',40,'PARTICIPATION_CREATION',41,'PARTICIPATION_MOVE',42,'BOOKING_REMINDER_COURT',43,'BOOKING_REMINDER_STAFF',44,'BOOKING_REMINDER_CLASS',45,'PARTICIPATION_CONFIRMATION_CLASS',46,'PARTICIPATION_CONFIRMATION_COURT',47,'PARTICIPATION_CONFIRMATION_STAFF',48,'FREEZE_CREATION',49,'FREEZE_END',50,'SUBSCRIPTION_TERMINATION',51,'BIRTHDAY',52,'PASSWORD_EXPIRATION_WARNING',53,'PAYMENT_REQUEST_NOTIFICATION',54,'ADVANCED_AGREEMENT_NOTIFICATION',55,'TODO_ASSIGNED',56,'PARTICIPATION_CONFIRMATION_CHILD_CARE',57,'PARTICIPATION_CANCELATION_BY_MEMBER',58,'BOOKING_STAFF_CHANGE',59,'BOOKING_STAFF_CHANGE_TO_STAFF',60,'TODO_DELETED',61,'PAYMENT_AGREEMENT_CREATION',62,'CREDIT_CARD_AGREEMENT_FINISH_ONLINE',63,'CHECK_IN',64,'ATTEND',65,
            'PERSON_CREATED',66, 'PERSON_DETAILS_CHANGED',67,'PERSON_STATE_CHANGED',68,'PERSON_TRANSFERRED',69,'COMPANY_DETAILS_CHANGED',70,'COMPANY_AGREEMENT_DETAILS_CHANGED',71,'PARTICIPATION_STATE_CHANGED',72,'EFT_AGREEMENT_FINISH_EXTERNALLY',73,'BOOKING_CREATED',74,'BOOKING_CANCELLED',75,'BOOKING_CHANGED',76,'PAYMENT_AGREEMENT_EXPIRATION',77,'LEAD_ONLINE_SALES_DISCONTINUED',78,'PRODUCT_SALE',79,'PRODUCT_CREDIT',80,'CALDAV_FAILURE',101,'FAILED_PAYMENT_REQUEST_NOTIFICATION') AS MESSAGE_TYPE
        FROM
            SATS.MESSAGES m
        LEFT JOIN SATS.TEMPLATES t
        ON
            t.ID = m.TEMPLATEID
            WHERE
                m.CENTER IN (:scope)
                AND m.SENTTIME BETWEEN :sentFrom AND :sentTo
    )
GROUP BY
    center,
    SUBJECT,
    DELIVERYCODE,
    DELIVERYMETHOD,
    TEMPLATE_TYPE,
    MESSAGE_TYPE