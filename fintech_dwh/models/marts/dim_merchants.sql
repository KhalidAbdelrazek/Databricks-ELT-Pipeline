select
    merchant_id,
    merchant_name,
    mcc_code,
    country_code,
    onboarded_at
from {{ ref('stg_merchants') }}