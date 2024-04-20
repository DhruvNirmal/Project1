
USE Project1
--Drop procedure dbo.bonds;
Select Distinct(Year(Sale_date)) from California order by Year(Sale_date) ;
-- Timeline of recorded dataset
SELECT max(Sale_date) AS start_date, 
MIN(Sale_date) AS end_date 
FROM California;

Select Purpose, Year(Sale_date), Year(Final_Maturity_Date), AVG(DATEDIFF(day, Sale_date, Final_Maturity_Date  )) as Average_bond_length 
 from California where Purpose = 'Single-Family Housing' AND Year(Sale_date) = '1985' AND Year(Final_Maturity_Date) != '1900' group by Purpose, Year(Sale_date), Year(Final_Maturity_Date);
-- Stored Procedure 1 to see bonds by issuer and purpose

GO

CREATE PROCEDURE bonds 
    @para NVARCHAR(30) 
AS 
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = '
        SELECT ' + QUOTENAME(@para) + ' AS ' + QUOTENAME(@para) + ',
               COUNT(*) AS number_of_bonds,
               SUM(Principal_Amount) AS total_amount,
               AVG(Principal_Amount) AS Average_amount_per_bond
        FROM California
        GROUP BY ' + QUOTENAME(@para) + '
        ORDER BY number_of_bonds DESC;
    ';

    EXEC sp_executesql @sql;
END;

EXEC bonds @para = 'Purpose'; -- Table 1
EXEC bonds @para = 'Issuer'; -- Table 2

-- Stored procedure 2 to see famous underwriters and gurantors 

GO 
Create procedure famous @param Varchar(30)
AS 
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = '
        SELECT ' + QUOTENAME(@param) + ', 
                COUNT(Guarantor) as Number_of_bonds,
                COUNT(case when Moody_Rating LIKE ''%Aa%'' OR Moody_Rating LIKE ''M:P-1'' THEN 1 END) AS good_bonds_by_moody,
                COUNT(case when S_and_P_Rating LIKE ''%AA%'' OR S_and_P_Rating LIKE ''S:A-1%'' THEN 1 END) AS good_bonds_by_SandP,
                AVG(Principal_Amount) AS Average_principal_amount 
        from California
        GROUP BY ' + QUOTENAME(@param) + '
        ORDER BY Number_of_bonds DESC;
    ';

    EXEC sp_executesql @sql;
END;
EXEC famous @param = 'Guarantor'; -- Table 3
EXEC famous @param = 'Underwriter'; -- Table 4

-- Number of bonds per year by issuer and by purpose (feels extra but lets see) (Table 5)

SELECT YEAR(Sale_date) AS year,
issuer,
purpose,
SUM(Principal_Amount) AS Sum_principal_amount, 
COUNT(*) AS projects_by_year
FROM California
GROUP BY YEAR(Sale_date), issuer, purpose;

-- Is debt policy applied to issuers who have bad ratings or high principal amount? If yes what is the threshold 

Select Principal_Amount, Debt_Policy, Sale_Date, S_and_P_Rating
from California
where S_and_P_Rating NOT LIKE '%A%' 

-- Average expense in issuing a bond (Do different for TIC NIC) (Table 6)

SELECT 
purpose,
year(Sale_Date) as Years,
SUM(Principal_Amount) Total,
AVG(COALESCE([Total_Issuance_Costs],0) + COALESCE([UW_Takedown],0) + COALESCE([UW_Mngmt_Fee],0) + COALESCE([UW_Expenses],0) + COALESCE([UW_Total_Discount_Spread],0) + COALESCE([Placement_Agent_Fee],0) + COALESCE([Financial_Advisor_Fee],0) + COALESCE([Bond_Counsel_Fee],0) + COALESCE([Co_Bond_Counsel_Fee],0) + COALESCE([Disclosure_Counsel_Fee],0) + COALESCE([Borrower_Counsel_Fee],0) + COALESCE([Trustee_Fee],0) + COALESCE([Credit_Enhancement_Fee],0) + COALESCE([Rating_Agency_Fee],0) + COALESCE([Other_Issuance_Expenses],0)) as Average_Expenses,
AVG(CASE WHEN Interest_Type = 'TIC' THEN TIC_Interest_Rate END) as Average_interest_rate_TIC,
AVG(CASE WHEN Interest_Type = 'NIC' THEN NIC_Interest_Rate END) as Average_interest_rate_NIC,
AVG(DATEDIFF(year, Sale_date, Final_Maturity_Date  )) as Average_bond_length_in_years
from California
WHERE Principal_Amount != 0 AND Year(Final_Maturity_Date) != '1900' 
GROUP BY year(Sale_Date), purpose
Order BY Years;

-- interest rate (Table 7)


SELECT year(Sale_date) as Years,
AVG(CASE WHEN Interest_Type = 'TIC' THEN TIC_Interest_Rate END) as Average_interest_rate_TIC,
AVG(CASE WHEN Interest_Type = 'NIC' THEN NIC_Interest_Rate END) as Average_interest_rate_NIC
From California
GROUP BY year(Sale_date)
ORDER BY year(Sale_date);

-- Average bond time length by purpose (Table 8)

SELECT 
purpose,
year(Sale_date) as years,
AVG(DATEDIFF(day, Sale_date, Final_Maturity_Date)) as Average_bond_length
from California
where Final_Maturity_Date <> '1900-01-01'
GROUP BY purpose, year(Sale_date)
order by years;

-- Issue sale type comp/neg   (gotta split tables by NIC and TIC) Table 9

Select [Sale_Type_Comp_Neg], 
year(Sale_date) as years,
AVG([TIC_Interest_Rate]) as Average_interest_rate,
AVG(COALESCE([Total_Issuance_Costs],0) + COALESCE([UW_Takedown],0) + COALESCE([UW_Mngmt_Fee],0) + COALESCE([UW_Expenses],0) + COALESCE([UW_Total_Discount_Spread],0) + COALESCE([Placement_Agent_Fee],0) + COALESCE([Financial_Advisor_Fee],0) + COALESCE([Bond_Counsel_Fee],0) + COALESCE([Co_Bond_Counsel_Fee],0) + COALESCE([Disclosure_Counsel_Fee],0) + COALESCE([Borrower_Counsel_Fee],0) + COALESCE([Trustee_Fee],0) + COALESCE([Credit_Enhancement_Fee],0) + COALESCE([Rating_Agency_Fee],0) + COALESCE([Other_Issuance_Expenses],0)) as Average_Expenses
from California
GROUP BY [Sale_Type_Comp_Neg], year(Sale_date)
ORDER BY years;

-- Top 5 Trusted trustee 

Select Top 5 Trustee, Count(*) as Number_of_bonds
from California
Where Trustee is not Null
Group By Trustee
Order By Number_of_bonds DESC;

-- top 5 trustees by issuer (Table 10)

WITH RankedTrustees AS (
    SELECT Issuer, Trustee, COUNT(*) AS Number_of_bonds,
           ROW_NUMBER() OVER (PARTITION BY Issuer ORDER BY COUNT(*) DESC) AS RowNum
    FROM California
    WHERE Trustee IS NOT NULL
    GROUP BY Issuer, Trustee
)
SELECT Issuer, Trustee, Number_of_bonds
FROM RankedTrustees
WHERE RowNum <= 5;
