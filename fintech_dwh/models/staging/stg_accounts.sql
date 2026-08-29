select
    account_id,
    customer_id,
    initcap(account_type)                  as account_type,
    initcap(account_status)                as account_status,
    upper(currency)                        as currency,
    cast(created_at as timestamp)          as created_at,
    cast(updated_at as timestamp)          as updated_at
from {{ source('bronze', 'raw_accounts') }}