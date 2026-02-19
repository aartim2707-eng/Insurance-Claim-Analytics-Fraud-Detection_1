-- ** PROJECT NAME: INSURANCE CLAIM ANALYTICS & FRAUD DETECTION PROJECT **
-- TAGLINE:TURNING CLAIM DATA INTO INSIGHTS FOR FRAUD PREVENTION, EFFICIENCY, AND CUSTOMER TRUST.

-- *************************GENERAL INFORMATION************************* 

use`final_insurance_project`;

-- Product name:-
SELECT DISTINCT(Product_name) FROM customer;

-- Total policies sales:-
SELECT COUNT(Policy_number) as Total_Policy_Sold from customer; 

  -- Total sales:-
  SELECT SUM(Premium_amount) AS Total_Sales from customer;
  
  -- Number of claim:-
SELECT COUNT(ï»¿Claim_id) as claim_count from claims; 

  -- Total claims received amount:-
   SELECT SUM(Claim_amount) AS Total_claim from claims;
   
--  Total sales person
SELECT COUNT(RM_id) as sales_employee from customer;

--  Total claim officer
SELECT COUNT(Claim_approved_by_emp_id) as claim_officer from claims;

-- Customer
SELECT DISTINCT(customer_name) from customer; 

-- Highest primium
SELECT MAX(Premium_amount) as Highest_primium from customer;

-- Lowest primium
SELECT MIN(Premium_amount) as Lowest_primium from customer;

-- Highest claim
SELECT MAX(claim_amount) as  Highest_Claim from claims;

-- *************************PS-1:FRAUD DETECTION IN CLAIMS*************************

-- PS1.Q1:-Identify all fraudulent claims
SELECT c.Customer_name, cl.ï»¿Claim_id, cl.Claim_amount, cl.Claim_fraud_flag
FROM customer c
JOIN claims cl ON c.ï»¿Customer_id = cl.Customer_id
WHERE cl.Claim_fraud_flag = 'Yes';
-- Business Insight: Detecting fraudulent claims helps reduce financial losses

-- PS1.Q2:-Customers with more than two fraud claims?
SELECT Customer_id, COUNT(*) AS fraud_count
FROM claims
WHERE Claim_fraud_flag = 'Yes'
GROUP BY Customer_id
HAVING COUNT(*) > 2;
-- Business Insight: Frequent fraudsters can be flagged for stricter monitoring.

-- PS1.Q3:- Categorize claims by risk level?
SELECT ï»¿Claim_id, Claim_amount,
       CASE 
         WHEN Claim_amount > 100000 THEN 'High Risk'
         WHEN Claim_amount BETWEEN 50000 AND 100000 THEN 'Medium Risk'
         ELSE 'Low Risk'
       END AS risk_category
FROM claims;
-- Business Insight: Risk categorization helps prioritize claim reviews.

-- PS1.Q4:- Rank fraudulent claims by amount?
SELECT Customer_id, ï»¿Claim_id, Claim_amount,
       RANK() OVER (PARTITION BY Customer_id ORDER BY Claim_amount DESC) AS fraud_rank
FROM claims
WHERE Claim_fraud_flag = 'Yes';
-- Business Insight: Ranking highlights the biggest fraud risks per customer.

-- **********************PS-2:CUSTOMER EXPERIENCE & CLAIM SETTLEMENT DELAYS********************

-- PS2.Q1:- Average settlement days per claim type?
SELECT Claim_type,
       ROUND(AVG(DATEDIFF(Claim_approved_dt, Claim_registered_dt)), 2) AS avg_days
FROM claims
GROUP BY Claim_type;
-- Business Insight: Identifies claim types causing customer dissatisfaction.

-- PS2.Q2:- Round settlement days for clarity?
SELECT ï»¿Claim_id, ROUND(DATEDIFF(Claim_approved_dt, Claim_registered_dt),0) AS settlement_days
FROM claims;
-- Business Insight: Rounded values make reporting cleaner.

-- PS2.Q3:- Rank claims by delay?
SELECT ï»¿Claim_id, Customer_id,
       DATEDIFF(Claim_approved_dt, Claim_registered_dt) AS delay_days,
       RANK() OVER (ORDER BY DATEDIFF(Claim_approved_date, Claim_registered_date) DESC) AS delay_rank
FROM claims;
-- Business Insight: Longest delays can be targeted for process improvement.

-- *************************PS-3:POLICY & CLAIM DATA INTEGRATION*************************

-- PS3.Q1:- Find mismatched policy vs claim status?
SELECT cl.ï»¿Claim_id, cl.Policy_number, cl.Policy_status, cl.Claim_status
FROM claims cl
JOIN customer c ON cl.Policy_number = c.Policy_number
WHERE cl.Policy_status <> cl.Claim_status;
-- Business Insight: Ensures policy records align with claim outcomes.

-- PS3.Q2:- Customers with active policies but rejected claims?
SELECT ï»¿Customer_id, Customer_name
FROM customer
WHERE Policy_number IN (
    SELECT Policy_number
    FROM claims
    WHERE Claim_status = 'Rejected' AND Policy_status = 'Active');
-- Business Insight: Highlights gaps between active policies and rejected claims.

-- *************************PS-4:FINANCIAL IMPACT & PREMIUM ANALYSIS*************************

-- PS4.Q1:- Compare premiums vs claims per customer?
SELECT c.ï»¿Customer_id, c.Customer_name,
       SUM(c.Premium_amount) AS total_premium,
       SUM(cl.Claim_amount) AS total_claims
FROM customer c
JOIN claims cl ON c.Policy_number = cl.Policy_number
GROUP BY c.ï»¿Customer_id, c.Customer_name;
-- Business Insight: Shows profitability per customer.

-- PS4.Q2:- Profitability flag?
SELECT c.ï»¿Customer_id, c.Customer_name,
       SUM(c.Premium_amount) AS total_premium,
       SUM(cl.Claim_amount) AS total_claims,
       CASE 
         WHEN SUM(cl.Claim_amount) > SUM(c.Premium_amount) THEN 'Loss'
         ELSE 'Profit'
       END AS profitability
FROM customer c
JOIN claims cl ON c.Policy_number = cl.Policy_number
GROUP BY c.ï»¿Customer_id, c.Customer_name;
-- Business Insight: Identifies loss-making customers

-- PS4.Q23:- Net paid amount rounded?
SELECT ï»¿Claim_id, claim_amount,ROUND(Claim_amount - Claim_deducted_amount,2) AS net_paid
FROM claims;
-- Business Insight: Shows actual payout after deductions.

-- *************************PS-5:OPERATIONAL EFFICIENCY & EMPLOYEE PERFORMANCE*************************

-- PS5.Q1:- Average approval days per employee?
SELECT Claim_approved_by_emp_id, Claim_approved_by_emp_name,
       ROUND(AVG(DATEDIFF(Claim_approved_dt, Claim_registered_dt))) AS avg_days
FROM claims
GROUP BY Claim_approved_by_emp_id, Claim_approved_by_emp_name
HAVING AVG(DATEDIFF(Claim_approved_dt, Claim_registered_dt)) > 5;
-- Business Insight: Identifies employees causing delays

-- PS5.Q2:- Employee performance ranking?
SELECT Claim_approved_by_emp_name,
       AVG(DATEDIFF(Claim_approved_dt, Claim_registered_dt)) AS avg_days,
       RANK() OVER (ORDER BY AVG(DATEDIFF(Claim_approved_dt, Claim_registered_dt))) AS performance_rank
FROM claims
GROUP BY Claim_approved_by_emp_name;
-- Business Insight: Ranks employees by efficiency.

-- PS5.Q3:- Employees with most escalations?
SELECT Claim_approved_by_emp_name, escalations
FROM (
    SELECT Claim_approved_by_emp_name, COUNT(*) AS escalations
    FROM claims
    WHERE Escalation_flag = 'Yes'
    GROUP BY Claim_approved_by_emp_name
) AS emp_escalations
ORDER BY escalations DESC;
-- Business Insight: Pinpoints employees linked to poor handling.


-- *************************PS-6: CLAIM RATINGS ANALYSIS *************************

-- PS6.Q1:- Find average rating per claim type?
SELECT Claim_type, AVG(Customer_rating) AS avg_rating
FROM claims
GROUP BY Claim_type;
-- Business Insight: Shows overall customer satisfaction levels for each claim type.

-- PS6.Q2:- Find average rating per claim type?
SELECT ï»¿Claim_id, Claim_type, customer_rating
FROM claims
WHERE customer_rating < 3;

-- Business Insight: Highlights dissatisfied customers and claim types needing process improvement.

-- PS6.Q3:- Find average rating per claim type?
SELECT ï»¿Claim_id, Claim_type, Customer_rating
FROM claims
WHERE Customer_rating >= 4;
-- Business Insight: Highlights satisfied customers and claim types performing well, which can be promoted as success stories.

-- ==================================*BUSINESS IMPROVEMENT POINT*======================================

-- 📌📌 Business Improvement Recommendations
-- - Strengthen fraud detection with predictive analytics and automated alerts.
-- - Reduce settlement delays by streamlining approval workflows and enhancing employee performance monitoring.
-- - Integrate customer, policy, and claim data for a single source of truth.
-- - Balance premium pricing with claim ratios to ensure profitability.
-- - Improve customer satisfaction through transparent communication and faster resolution.

-- 👉 Short Closing Note:
-- This project highlights key operational and financial gaps in claim management. Continuous improvement in fraud prevention, 
-- customer experience, and data integration will drive efficiency, profitability, and trust in the insurance business.

-- 👉 SQL Benefits for Organizations
-- SQL helps organizations turn raw data into actionable insights by detecting fraud, 
-- improving efficiency, and enhancing customer satisfaction. It enables accurate reporting, better decision-making, and sustainable profitability through data-driven strategies

-- =====================================# THANK YOU #=======================================
































































