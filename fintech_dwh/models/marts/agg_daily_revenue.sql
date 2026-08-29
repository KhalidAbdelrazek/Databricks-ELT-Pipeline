-- agg_daily_revenue.sql
select
    date(created_at)              as transaction_date,
    count(*)                      as transaction_count,
    sum(amount)                   as gross_volume,
    sum(commission_amount)        as total_commission_revenue,
    sum(net_amount)               as total_net_amount
from {{ ref('fact_transactions') }}
where status = 'SETTLED'
group by date(created_at)
order by transaction_date