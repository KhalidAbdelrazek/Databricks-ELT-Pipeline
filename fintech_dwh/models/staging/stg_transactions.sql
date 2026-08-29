select
    transaction_id,
    transaction_type,
    account_id,
    merchant_id,
    biller_id,
    destination_account_id,
    biller_reference_number,
    cast(amount as decimal(12,2))      as amount,
    currency,
    channel,
    card_number is not null            as has_card,
    channel in ('Web','Mobile')        as is_online,
    status,
    cast(created_at as timestamp)      as created_at,
    cast(updated_at as timestamp)      as updated_at
from {{ source('bronze', 'raw_transactions') }}