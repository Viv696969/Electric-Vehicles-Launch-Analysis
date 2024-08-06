-- 1.
with cte as (
select d.fiscal_year,maker,
sum(electric_vehicles_sold) as ev_sold
from electric_vehicle_sales_by_makers ev join dim_date d
using(`date`)
where d.fiscal_year=2023 and ev.vehicle_category='2-Wheelers'
group by maker
order by ev_sold desc
limit 3
),
cte1 as (
select d.fiscal_year,maker,
sum(electric_vehicles_sold) as ev_sold
from electric_vehicle_sales_by_makers ev join dim_date d
using(`date`)
where d.fiscal_year=2024 and ev.vehicle_category='2-Wheelers'
group by maker
order by ev_sold desc
limit 3
)
select * from cte
union
select * from cte1;


-- 1
with cte as (
select d.fiscal_year,maker,
sum(electric_vehicles_sold) as ev_sold
from electric_vehicle_sales_by_makers ev join dim_date d
using(`date`)
where d.fiscal_year=2023 and ev.vehicle_category='2-Wheelers'
group by maker
order by ev_sold 
limit 3
),
cte1 as (
select d.fiscal_year,maker,
sum(electric_vehicles_sold) as ev_sold
from electric_vehicle_sales_by_makers ev join dim_date d
using(`date`)
where d.fiscal_year=2024 and ev.vehicle_category='2-Wheelers'
group by maker
order by ev_sold 
limit 3
)
select * from cte
union
select * from cte1;

-- 2
with cte_2_wheeler as (
select ev.vehicle_category , state , 
sum(electric_vehicles_sold)*100/sum(total_vehicles_sold) as `penetration rate`
from electric_vehicle_sales_by_state ev 
join dim_date d using (`date`)
where d.fiscal_year=2024 and vehicle_category='2-Wheelers'
group by ev.vehicle_category , state
order by `penetration rate` desc
limit 5
),
cte_4_wheeler as (
select ev.vehicle_category , state , 
sum(electric_vehicles_sold)*100/sum(total_vehicles_sold) as `penetration rate`
from electric_vehicle_sales_by_state ev 
join dim_date d using (`date`)
where d.fiscal_year=2024 and vehicle_category='4-Wheelers'
group by ev.vehicle_category , state
order by `penetration rate` desc
limit 5
)
select * from cte_2_wheeler
union
select * from cte_4_wheeler;

-- 3
with cte_2022 as (
select state,sum(electric_vehicles_sold)*100/sum(total_vehicles_sold) as `penetration rate`
from electric_vehicle_sales_by_state ev join dim_date d using(`date`)
where d.fiscal_year=2022
group by state
),
cte_2024 as (
select state,sum(electric_vehicles_sold)*100/sum(total_vehicles_sold) as `penetration rate`
from electric_vehicle_sales_by_state ev join dim_date d using(`date`)
where d.fiscal_year=2024
group by state
),
cte_2023 as (
select state,sum(electric_vehicles_sold)*100/sum(total_vehicles_sold) as `penetration rate`
from electric_vehicle_sales_by_state ev join dim_date d using(`date`)
where d.fiscal_year=2023
group by state
)
select state,cte_2022.`penetration rate` as `penetration rate 2022`,
cte_2023.`penetration rate` as `penetration rate 2023`,
cte_2024.`penetration rate` as `penetration rate 2024`
from cte_2022  join cte_2024 using (state) join cte_2023 using(state)
-- where cte_2024.`penetration rate`> cte_2022.`penetration rate`
order by `penetration rate 2024` desc
limit 5
;

-- p rate by fiscal years
select 
fiscal_year,round(sum(electric_vehicles_sold)*100/sum(total_vehicles_sold),2) as `penetration rate`
from electric_vehicle_sales_by_state ev join dim_date d using(`date`)
group by fiscal_year
;

-- ev sold per category in eachfiscal year
select fiscal_year,vehicle_category,sum(electric_vehicles_sold)/100000 as `Total EV Sold in Lakhs` 
from electric_vehicle_sales_by_state ev join dim_date d using(date)
group by fiscal_year,vehicle_category
order by fiscal_year,`Total EV Sold in Lakhs` desc ;

-- pr per ctegory in a fiscal year
select fiscal_year,vehicle_category,
sum(electric_vehicles_sold)*100/sum(total_vehicles_sold) as `Penetration rate` 
from electric_vehicle_sales_by_state ev join dim_date d using(date)
group by fiscal_year,vehicle_category
order by fiscal_year,`Penetration rate`  desc ;

-- top 3 states in each fiscal year by the ev sold 
with cte as (
select fiscal_year,state,sum(electric_vehicles_sold)/100000 as ev_sold 
from electric_vehicle_sales_by_state join dim_date using(date)
group by fiscal_year,state
order by ev_sold desc
),
cte_find_rank as (
select *,
dense_rank() over(partition by fiscal_year order by ev_sold desc) as `rank`
from cte
)
select fiscal_year,state,ev_sold as `EV sold in Lakhs`  from cte_find_rank where `rank` in (1,2,3);

-- top 3 states in each fiscal year by their penetration rate
with cte as (
select fiscal_year,state,sum(electric_vehicles_sold)*100/sum(total_vehicles_sold) as pr 
from electric_vehicle_sales_by_state join dim_date using(date)
group by fiscal_year,state
order by pr desc
),
cte_find_rank as (
select *,
dense_rank() over(partition by fiscal_year order by pr desc) as `rank`
from cte
)
select fiscal_year,state,pr as `EV sold in Lakhs`  from cte_find_rank where `rank` in (1,2,3);


-- total ev sold per category in states where the states have highest penetration rate
with cte as(
select state,sum(electric_vehicles_sold)*100/sum(total_vehicles_sold) as pr
from electric_vehicle_sales_by_state join dim_date using(date)
group by state
order by pr desc
limit 5
)
select state,vehicle_category , sum(electric_vehicles_sold)/1000 as ev_sold
from electric_vehicle_sales_by_state
where state in (select state from cte)
group by state,vehicle_category
order by state,ev_sold desc;



-- MAKER analysis
with cte as(
select maker,sum(electric_vehicles_sold) as ev_sold from 
electric_vehicle_sales_by_makers
where vehicle_category='4-Wheelers'
group by maker
order by ev_sold desc
limit 5
)
select fiscal_year,`quarter`,maker,
sum(electric_vehicles_sold) as ev_sold_
from electric_vehicle_sales_by_makers join dim_date d using(date)
where vehicle_category='4-Wheelers' and maker in (select maker from cte)
group by fiscal_year,`quarter`,maker
order by fiscal_year,`quarter`,maker;

with cte as(
select maker,sum(electric_vehicles_sold) as ev_sold from 
electric_vehicle_sales_by_makers
where vehicle_category='4-Wheelers'
group by maker
order by ev_sold desc
limit 5
)
select `quarter`,maker,
sum(electric_vehicles_sold) as ev_sold_
from electric_vehicle_sales_by_makers join dim_date d using(date)
where vehicle_category='4-Wheelers' and maker in (select maker from cte)
group by `quarter`,maker
order by `quarter`,maker;

select quarter,vehicle_category,round(sum(electric_vehicles_sold)/1000,2)
from electric_vehicle_sales_by_makers join dim_date d using(date)
group by quarter,vehicle_category
order by quarter,vehicle_category;

select fiscal_year,vehicle_category,round(sum(electric_vehicles_sold)/1000,2) as `EV Sold `
from electric_vehicle_sales_by_makers join dim_date d using(date)
group by fiscal_year,vehicle_category
order by fiscal_year,vehicle_category;

-- 5

select state,sum(electric_vehicles_sold)/100000 as `EV Sold`
,round(sum(electric_vehicles_sold)*100/sum(total_vehicles_sold),2) as `Penetration Rate` 
from electric_vehicle_sales_by_state ev join dim_date d using(date)
where state in ('Delhi','Karnataka') and fiscal_year=2024
group by state
order by state desc; 

-- 6
with cte as (
select maker,sum(electric_vehicles_sold) as ev_sold
from electric_vehicle_sales_by_makers join dim_date d using(date)
where vehicle_category='4-Wheelers'
group by maker
order by  ev_sold desc
limit 5
),cte1 as(
select fiscal_year,maker,
sum(electric_vehicles_sold) as `EV Sold`
from electric_vehicle_sales_by_makers join dim_date d using(date)
where vehicle_category='4-Wheelers' and maker in (select maker from cte)
group by fiscal_year,maker
order by maker
),cte2 as (
select *,
lead(`EV Sold`,2) over(partition by maker order by fiscal_year) as ending_value
from cte1
)
select maker,round((power((ending_value/`EV Sold`),1.0/3)-1 )*100,2) as CAGR
from cte2
where ending_value is not null;






-- select maker,sum(electric_vehicles_sold) as ev_sold
-- from electric_vehicle_sales_by_makers join dim_date d using(date)
-- where vehicle_category='4-Wheelers'
-- group by maker
-- order by  ev_sold desc
-- limit 5;



with cte as (
select maker,sum(electric_vehicles_sold) as ev_sold
from electric_vehicle_sales_by_makers join dim_date d using(date)
where vehicle_category='4-Wheelers'
group by maker
order by  ev_sold desc
limit 5
)
select fiscal_year,maker,
sum(electric_vehicles_sold) as `EV Sold`
from electric_vehicle_sales_by_makers join dim_date d using(date)
where vehicle_category='4-Wheelers' and maker in (select maker from cte)
group by fiscal_year,maker
order by maker;

-- 8
with cte_2022 as (
select fiscal_year,state,sum(total_vehicles_sold) as beginning
from electric_vehicle_sales_by_state join dim_date d using(date)
where fiscal_year=2022
group by fiscal_year,state
),cte_2024 as (
select fiscal_year,state,sum(total_vehicles_sold) as ending
from electric_vehicle_sales_by_state join dim_date d using(date)
where fiscal_year=2024
group by fiscal_year,state
)
select state,
round((power((ending/beginning),(1/3))-1)*100,2) as CAGR
 from cte_2022 join cte_2024 using(state)
 order by CAGR desc
 limit 10;

