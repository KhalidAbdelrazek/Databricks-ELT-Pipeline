select
    customer_id,
    trim(first_name)                       as first_name,
    trim(last_name)                        as last_name,
    lower(trim(primary_email))             as primary_email,
    lower(trim(secondary_email))           as secondary_email,
    phone_number,
    upper(country_code)                    as country_code,
    cast(credit_score as int)              as credit_score,
    upper(kyc_status)                      as kyc_status,
    cast(signup_date as date)              as signup_date,
    cast(created_at as timestamp)          as created_at,
    cast(updated_at as timestamp)          as updated_at
from {{ source('bronze', 'raw_customers') }}