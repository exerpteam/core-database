-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    center, 
    shortname, 
    p.name,
    price, 
    globalid, 
    show_in_sale, 
    show_on_web, 
    CASE p.requiredrole
        WHEN '5868'  THEN 'old product access'
        WHEN '8673'  THEN 'Sell Staff Subscriptions'
        WHEN '4250'  THEN 'Admin support'
        WHEN '3243'  THEN 'HQ ATC'
        WHEN '11284' THEN 'MKT Offeer'
        WHEN '11283' THEN 'Assign invitations with permissions'
        WHEN '539'   THEN 'Exerp'
        WHEN '7269'  THEN 'ExtAtt_Gympass'
        WHEN '4251'  THEN 'Sales Secretary'
        WHEN '14498' THEN 'Join Journey Visibility'
        ELSE p.requiredrole::text
    END AS requiredrole_match,
    CASE 
        WHEN p.center >= 700 THEN 'Portugal'
        ELSE 'Spain'
    END AS country,
    CASE p.product_account_config_id
        WHEN '4404' THEN 'Seguro de accidentes add-on'
        WHEN '1'    THEN 'Subscription DD'
        WHEN '1001' THEN 'Joining Fee SP'
        WHEN '4401' THEN 'Subscription ONE'
        WHEN '4601' THEN 'Subscription FLEX'
        WHEN '4801' THEN 'Subscription PRIME'
        WHEN '201'  THEN 'Subscriptions Cash'
        WHEN '601'  THEN 'Subscripciones mensuales'
        WHEN '602'  THEN 'Subscripciones prepago 6 M'
        WHEN '603'  THEN 'Freezers'
        WHEN '604'  THEN 'Pase de día'
        WHEN '605'  THEN 'Seguro de accidentes'
        WHEN '801'  THEN 'Subscripciones prepago 3 M'
        WHEN '802'  THEN 'Subscripciones prepago 12 M'
        WHEN '803'  THEN 'Merchandising SP'
        WHEN '1002' THEN 'Taquillas'
        WHEN '1201' THEN 'Subscripciones Premium'
        WHEN '1401' THEN 'Cargos de devolución'
        WHEN '1402' THEN 'Otros servicios'
        WHEN '1601' THEN 'Clipcards - Personal Training'
        WHEN '1801' THEN 'Servicios de Personal Training'
        WHEN '2001' THEN 'Rejeição DD'
        WHEN '2201' THEN 'Clipcards'
        WHEN '2401' THEN 'Bring a friend'
        WHEN '2601' THEN 'Merchandising PT'
        WHEN '2801' THEN 'Yanga'
        WHEN '3001' THEN 'Candados Alquiler'
        WHEN '3201' THEN 'Yanga - Clipcard'
        WHEN '3401' THEN 'Otros Servicios (add-on)'
        WHEN '3601' THEN 'Ingresos cambio subscripcion'
        WHEN '3802' THEN 'Subscripcion Platino'
        WHEN '3803' THEN 'Subscripcion Zone'
        WHEN '4001' THEN 'Drink'
        WHEN '4201' THEN 'Subscripcion Club'
        WHEN '4202' THEN 'Subscripcion Iberia'
        WHEN '4402' THEN 'LevelUp Sesiones'
        WHEN '4403' THEN 'Passaporte Canarias'
        WHEN '4602' THEN 'Vivabox'
        WHEN '4802' THEN 'Cuota Boxeo Senior'
        WHEN '4803' THEN 'One Experience Plus'
        WHEN '4804' THEN 'PT EXPERIENCE'
        WHEN '5001' THEN 'Cuota Boxeo Junior'
        WHEN '5002' THEN 'Passaporte 200'
        WHEN '5201' THEN 'Joining Fee Boxeo'
        WHEN '5202' THEN 'PT Sesiones'
        WHEN '5401' THEN 'Parking'
        WHEN '5601' THEN 'PT Basic'
        WHEN '5801' THEN 'PT Basic Service'
        WHEN '6001' THEN 'Squash'
        WHEN '6002' THEN '7 Days passes'
        WHEN '6201' THEN 'Subscripcion One <18'
        WHEN '6401' THEN 'Subscripcion One Disc'
        WHEN '6601' THEN 'Subscripcion One +65'
        WHEN '6801' THEN 'Taquillas - Service'
        WHEN '7201' THEN 'Drink Pack'
        WHEN '7401' THEN 'Boxer - King of the ring'
        WHEN '7601' THEN 'Boxer - Padwork Boxing'
        ELSE p.product_account_config_id::text
    END AS product_account_config_match
FROM products AS p
LEFT JOIN centers AS c ON p.center = c.id
WHERE p.name IN (
    'Criação IBERIA', 'Criação ZONE', 'Criação CLUB', 
    'Creation Cuota IBERIA', 'Creation Cuota ZONE', 'Creation Cuota CLUB',
    'Creation Cuota ONE', 'Creation Cuota FLEX', 'Creation Cuota PRIME', 
    'Criação PRIME', 'Criação FLEX', 'Criação ONE'
)
ORDER BY p.center;