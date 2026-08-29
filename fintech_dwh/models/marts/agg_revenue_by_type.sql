-- agg_revenue_by_type.sql
select
    date(created_at)              as transaction_date,
    transaction_type,
    count(*)                      as transaction_count,
    sum(amount)                   as gross_volume,
    sum(commission_amount)        as total_commission_revenue
from {{ ref('fact_transactions') }}
where status = 'SETTLED'
group by date(created_at), transaction_type
order by transaction_date, transaction_type