select
    biller_id,
    biller_name,
    biller_category,
    country_code
from {{ ref('stg_billers') }}