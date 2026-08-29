select
    customer_id,
    first_name,
    last_name,
    primary_email,
    secondary_email,
    phone_number,
    country_code,
    credit_score,
    kyc_status,
    signup_date
from {{ ref('stg_customers') }}