select
    biller_id,
    trim(biller_name)                      as biller_name,
    biller_category,
    upper(country_code)                    as country_code
from {{ source('bronze', 'raw_billers') }}