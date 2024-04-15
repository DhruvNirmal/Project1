USE Project1;

SELECT purpose, Final_Maturity_Date, Sale_date
FROM California
where purpose = 'Health Care Facilities';

-- Timeline of recorded dataset
SELECT max(Sale_date) AS start_date, 
MIN(Sale_date) AS end_date 
FROM California;

-- Who has the most number of bonds in California
SELECT issuer,
COUNT(*) AS number_of_bonds_by_issuer,
SUM(Principal_Amount) total_amount,
AVG(Principal_Amount) AS Average_amount_per_bond
FROM California
GROUP BY issuer
ORDER BY number_of_bonds_by_issuer DESC;

-- For which Purpose most number of bonds are issued
SELECT Purpose,
COUNT(*) AS number_of_bonds_by_purpose,
SUM(Principal_Amount) total_amount,
AVG(Principal_Amount) AS Average_amount_per_bond,
AVG(DATEDIFF(day, Final_Maturity_Date, Sale_date)) as Average_bond_length
FROM California
GROUP BY Purpose
ORDER BY number_of_bonds_by_purpose DESC;

-- Number of bonds per year by issuer and by purpose
SELECT YEAR(Sale_date) AS year,
issuer,
purpose,
SUM(Principal_Amount) AS Sum_principal_amount, 
COUNT(*) AS projects_by_year
FROM California
GROUP BY YEAR(Sale_date), issuer, purpose;

-- Is debt policy applied to issuers who have bad ratings or high principal amount? If yes what is the threshold 

Select Principal_Amount, New_money, Sale_Date, S_and_P_Rating, Moody_Rating, Fitch_rating
from California
where Principal_Amount > New_Money

-- Average expense in issuing a bond

SELECT 
purpose,
year(Sale_Date) as Years,
SUM(Principal_Amount) Total,
SUM(COALESCE([Total_Issuance_Costs],0) + COALESCE([UW_Takedown],0) + COALESCE([UW_Mngmt_Fee],0) + COALESCE([UW_Expenses],0) + COALESCE([UW_Total_Discount_Spread],0) + COALESCE([Placement_Agent_Fee],0) + COALESCE([Financial_Advisor_Fee],0) + COALESCE([Bond_Counsel_Fee],0) + COALESCE([Co_Bond_Counsel_Fee],0) + COALESCE([Disclosure_Counsel_Fee],0) + COALESCE([Borrower_Counsel_Fee],0) + COALESCE([Trustee_Fee],0) + COALESCE([Credit_Enhancement_Fee],0) + COALESCE([Rating_Agency_Fee],0) + COALESCE([Other_Issuance_Expenses],0)) as Average_Expenses,
AVG(TIC_Interest_Rate) as Average_interest_rate
from California
WHERE Principal_Amount <> 0
GROUP BY year(Sale_Date), purpose
Order BY Years;

-- interest rate 


SELECT AVG(TIC_Interest_Rate) as Average_interest_rate,
year(Sale_date) as Years
From California
GROUP BY year(Sale_date)
ORDER BY year(Sale_date);

