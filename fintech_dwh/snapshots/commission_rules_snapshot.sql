{% snapshot commission_rules_snapshot %}
{{
    config(
        target_schema='gold',
        unique_key='commission_rule_id',
        strategy='check',
        check_cols=['commission_value']
    )
}}
select * from {{ source('bronze', 'raw_commission_rules') }}
{% endsnapshot %}