with tx as (
    select * from {{ ref('stg_transactions') }}
),

merch as (
    select merchant_id, mcc_code from {{ ref('dim_merchants') }}
),

biller as (
    select biller_id, biller_category from {{ ref('dim_billers') }}
),

tx_scoped as (
    select
        tx.*,
        case
            when tx.transaction_type = 'purchase'     then merch.mcc_code
            when tx.transaction_type = 'bill_payment'  then biller.biller_category
            when tx.transaction_type = 'transfer'      then 'internal'
        end as scope_value
    from tx
    left join merch  on tx.merchant_id = merch.merchant_id
    left join biller on tx.biller_id = biller.biller_id
),

rules as (
    select * from {{ ref('commission_rules_snapshot') }}
)

select
    tx_scoped.*,
    rules.commission_rule_id,
    rules.commission_type,
    rules.commission_value,
    case
        when rules.commission_type = 'percentage' then round(tx_scoped.amount * rules.commission_value, 2)
        when rules.commission_type = 'flat'        then rules.commission_value
        else null
    end as commission_amount,
    tx_scoped.amount - coalesce(
        case
            when rules.commission_type = 'percentage' then round(tx_scoped.amount * rules.commission_value, 2)
            when rules.commission_type = 'flat'        then rules.commission_value
            else 0
        end, 0
    ) as net_amount
from tx_scoped
left join rules
  on rules.scope_type  = tx_scoped.transaction_type
 and rules.scope_value = tx_scoped.scope_value
 and date(tx_scoped.created_at) >= date(rules.dbt_valid_from)
 and (rules.dbt_valid_to is null or date(tx_scoped.created_at) < date(rules.dbt_valid_to))