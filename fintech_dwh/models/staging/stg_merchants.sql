select
    merchant_id,
    trim(merchant_name)                    as merchant_name,
    mcc_code,
    upper(country_code)                    as country_code,
    cast(onboarded_at as date)             as onboarded_at
from {{ source('bronze', 'raw_merchants') }}