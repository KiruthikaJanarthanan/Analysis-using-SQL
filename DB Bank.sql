
/* ANALYSIS ON BANK DATABASE */

use bank;              #to use the database bank
show tables;           #to view the tables under the database bank

/*1..What is the total balance amount held by each customer across all account types?*/
select bd.customer_id, bc.customer_name, SUM(bd.Balance_amount) as Total_Balance
from bank_account_details bd
join bank_customer bc on bd.customer_id = bc.customer_id
group by bd.customer_id, bc.customer_name
order by Total_Balance desc;

/*Analysis:
This query aggregates the balance amount across all accounts a customer holds, 
giving a total sum per customer.
 This helps in understanding the wealth distribution among customers and identifying high-value clients*/


/*2..Which customers have inactive accounts, and what type of accounts are they?*/
select bd.customer_id, bc.customer_name,bd.Account_Number, bd.account_type 
from bank_account_details bd join bank_customer bc on bd.customer_id = bc.customer_id
where Account_status="inactive";

/*Analysis:
This query helps the bank track inactive accounts,
 which may require re-engagement efforts or regulatory checks. 
 Identifying the type of inactive accounts (Savings, Recurring Deposits, Credit Cards) 
 can assist in strategizing personalized offers or reminders*/




/*3.What is the total transaction amount per province, and which province has the highest transaction activity?*/
select province,abs(sum(transaction_amount)) as total_transaction
from bank_account_transaction
group by Province
order by Total_Transaction desc;

/*Analysis:
This query helps in assessing transaction trends across different provinces, 
identifying high-activity areas. The results can be used for targeted financial services,
 marketing campaigns, or fraud detection based on unusual transaction patterns.*/


/*4.Which customers have more than one account, and what types of accounts do they hold?*/
select bd.customer_id, bc.customer_name, group_concat(distinct bd.account_type),count(bd.Account_Number) as totalnum_of_accounts
from bank_account_details bd join bank_customer bc on bd.customer_id = bc.customer_id
group by bd.customer_id, bc.customer_name
having totalnum_of_accounts > 1
order by totalnum_of_accounts desc;

/*Analysis:
This query identifies customers with multiple accounts and lists the types of accounts they hold. 
It helps in understanding customer engagement with the bank and in targeting them for specialized financial products.*/



/*5. What is the average transaction amount for each type of transaction channel?*/
select Transcation_channel,abs(round(avg(transaction_amount),2))as avg_transaction_amount ,count(*) transactions_count
from bank_account_transaction
group by Transcation_channel
order by avg_transaction_amount desc;

/*Analysis:
This query helps in analyzing the average amount transacted through different channels (ATM, POS, Net Banking, etc.). 
It can be useful for identifying preferred transaction methods and optimizing banking services*/



/*6.Which customers have savings accounts with a balance of more than 500,000?*/
select bd.customer_id, bc.customer_name, bd.account_Number, bd.balance_amount
from bank_account_details bd join bank_customer bc on bd.customer_id = bc.customer_id
where bd.Account_type = 'savings' AND bd.Balance_amount > 500000
order by bd.Balance_amount desc;

/*Analysis:
This query helps in identifying high-value savings account holders. 
These customers can be targeted for premium banking services, investment opportunities, or loyalty programs*/





/*7.Which customers have made the most transactions, and how much have they transacted in total?*/
select bd.customer_id, bc.customer_name, count(bt.Account_Number) as Transaction_Count,abs(sum(bt.Transaction_amount))as Total_Transaction
from bank_account_transaction bt join bank_account_details bd on bt.Account_Number = bd.Account_Number
join bank_customer bc on bd.customer_id = bc.customer_id
group by bd.customer_id, bc.customer_name
order by Transaction_Count desc;

/*Analysis:
This query helps identify highly active customers based on their transaction count and total transaction amount. 
The bank can use this data for customer relationship management, fraud monitoring, or offering tailored financial products*/



/*8.What is the total balance amount held by customers in each state?*/
select bc.state_code, sum(bd.Balance_amount) as Total_Balance
from bank_account_details bd join bank_customer bc on bd.customer_id = bc.customer_id
group by bc.state_code
order by Total_Balance desc;

/*Analysis:
This query provides insights into the distribution of bank funds across different states. 
It helps in regional financial planning, targeted marketing, and assessing state-wise banking performance*/



/*9.Print credit card transactions with the sum of transaction_amount on all Fridays and the sum of transaction_amount on all other days.*/
select 
case
 when dayname(Transaction_Date) = 'Friday' then 'Friday'else 'Other Days'
end as Day_Type,
abs(sum(Transaction_amount)) as Total_Transaction_Amount
from bank_account_transaction bt join bank_account_details bd on bt.Account_Number = bd.Account_Number
where bd.Account_type in ('Credit Card', 'Add-on Credit Card')
group by Day_Type;

/*Analysis:
  If the Friday total is significantly higher, it may indicate that customers prefer using credit cards for weekend purchases, shopping, or entertainment.
If the other days total is higher, it suggests more distributed spending throughout the week*/ 

    
/*9a.Further analysis on Transaction Channel,where those credit card transactions done on fridays and other days*/
select Transcation_channel,
case
 when dayname(Transaction_Date) = 'Friday' then 'Friday'else 'Other Days'
end as Day_Type,
abs(sum(Transaction_amount)) as Total_Transaction_Amount
from bank_account_transaction bt join bank_account_details bd on bt.Account_Number = bd.Account_Number
where bd.Account_type in ('Credit Card', 'Add-on Credit Card')
group by Transcation_channel,Day_Type;

/*Analysis:
This helps determine where customers are using their credit cards the most 
i.e.in which transaction channel(e.g., Online Shopping, POS, ATMs, etc.)*/


    

/*10.Show the details of credit cards along with the aggregate transaction amount during holidays and non-holidays.*/
select 
case
 when bt.Transaction_Date in (select Holiday from bank_holidays) then'Holiday'else'Non-Holiday'
end as Day_Type,
bd.customer_id,bc.customer_name,bd.Account_Number,bd.Account_type,abs(sum(Transaction_amount))as Total_Transaction_Amount
from bank_account_transaction bt join bank_account_details bd on bt.Account_Number = bd.Account_Number
join bank_customer bc ON bd.customer_id = bc.customer_id
where bd.Account_type in ('Credit Card', 'Add-on Credit Card')
group by Day_Type, bd.customer_id, bc.customer_name, bd.Account_Number, bd.Account_type;

/*Analysis:
If holiday transactions are significantly higher, it indicates that customers use credit cards more for holiday shopping, travel, or dining.
If non-holiday transactions dominate, spending is more routine, suggesting no major seasonal impact.*/





/*11.customers who done transaction in the holiday month of march and send a holiday greeting message*/
select t1.*,t3.Account_Number, t2.account_type, t3.Transaction_Date,"HAPPY HOLIDAY"AS Holiday_Greeting 
from bank_customer t1 join bank_account_details t2 on t1.customer_id=t2.Customer_id
 join bank_account_transaction t3 on t2.account_number = t3.account_number
where t3.Transaction_Date in (select HOLIDAY from BANK_HOLIDAYS where month(HOLIDAY)=3);

/*Analysis:
Identifying customers who made transactions on bank holidays in March.
Send them a personalized greeting message: "Happy Holiday" as a part of customer engagement.*/


/*12.What is the total interest accrued for each account type?*/
select bd.Account_type,abs(sum(bd.Balance_amount * bi.interest_rate)) as Total_Interest_Accrued
from bank_account_details bd
join bank_interest_rate bi on bd.Account_type = bi.account_type
group by bd.Account_type
order by Total_Interest_Accrued desc;

/*Analysis: 
This query helps the bank understand which account types generate the most interest liabilities.*/




/*13. What is the interest accrued on the highest and lowest balance accounts*/
(select bd.customer_id,bc.customer_name,bd.Account_Number,bd.Balance_amount,bi.interest_rate,
ROUND((bd.Balance_amount * bi.interest_rate), 2) as Accrued_Interest,"highest_balance_account"as balance
from bank_account_details bd
join bank_customer bc on bd.customer_id = bc.customer_id
join bank_interest_rate bi on bd.Account_type = bi.account_type
order by bd.Balance_amount desc
limit 1)
union all
(select bd.customer_id,bc.customer_name,bd.Account_Number,bd.Balance_amount,bi.interest_rate,
ROUND((bd.Balance_amount * bi.interest_rate), 2) as Accrued_Interest,"lowest_balance_account"as balance
from bank_account_details bd
join bank_customer bc on bd.customer_id = bc.customer_id
join bank_interest_rate bi on bd.Account_type = bi.account_type
order by bd.Balance_amount asc
limit 1);

/*Analysis: 
Helps track customers with extreme balances and evaluate their interest earnings for banking strategies.


/*14.Find customers whose total interest earnings exceed 50,000.*/
select bd.customer_id,bc.customer_name,sum(bd.Balance_amount * bi.interest_rate) as Total_Interest
from bank_account_details bd
join bank_customer bc on bd.customer_id = bc.customer_id
join bank_interest_rate bi on bd.Account_type = bi.account_type
group by bd.customer_id, bc.customer_name
having Total_Interest > 50000
order by Total_Interest desc;

/*Analysis:
 Identifies high-interest-earning customers who may need premium banking services or targeted investment plans*/



/*15.What is the difference between interest payable and interest receivable for the bank?*/
select sum(case 
        when bd.Account_type in ('savings', 'recurring deposits') then bd.Balance_amount * bi.interest_rate else 0 
    END) as Total_Interest_Payable,
sum(case
        when bd.Account_type in ('credit card', 'Loan') then bd.Balance_amount * bi.interest_rate else 0 
    end) as Total_Interest_Receivable,
sum((case
	when bd.Account_type in ('Credit Card', 'Loan') then bd.Balance_amount * bi.interest_rate else 0 
        end) - 
	(case
	when bd.Account_type in ('savings', 'recurring deposits') then bd.Balance_amount * bi.interest_rate else 0 
        end)
    ) as Net_Interest_Revenue
from bank_account_details bd
join bank_interest_rate bi on bd.Account_type = bi.account_type;

/*Analysis:
 Calculates the bank's net revenue from interest 
by comparing interest payable (on deposits) vs. interest receivable (on loans & credit cards)*/
