select
    account_id,
    customer_id,
    account_type,
    account_status,
    currency,
    created_at as account_opened_at
from {{ ref('stg_accounts') }}