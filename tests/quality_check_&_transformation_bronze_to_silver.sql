/*

Quality Checks

Script Purpose:
This script performs various quality checks for data consistency, accuracy,
and standardization across the 'silver' schemas. It includes checks for:
- Null or duplicate primary keys.
- Unwanted spaces in string fields.
- Data standardization and consistency.
- Invalid date ranges and orders.
- Data consistency between related fields.

Usage Notes:
- Run these checks after data loading Silver Layer.
- Investigate and resolve any discrepancies found during the checks.

*/
-- =============================================================================================================================================================
/* building silver layer 
   Clean & Load (crm_cust_info )
*/
-- 1. DUPLICATE CHECK --

SELECT *FROM bronze.crm_cust_info;
SELECT
cst_id,
COUNT(cst_id) 
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(cst_id) != 1 OR cst_id IS NULL;

SELECT *
FROM bronze.crm_cust_info
WHERE cst_id = 29466;

/* building silver layer 
   Clean & Load (crm_sales_details )
*/
-- 1. Check for (Duplicates)  in primary key
SELECT *FROM bronze.crm_sales_details;

SELECT *FROM bronze.crm_sales_details
WHERE sls_price != TRIM(sls_price);

SELECT *FROM bronze.crm_sales_details
WHERE sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0 OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL;

SELECT 
ABS(sls_sales) AS sls_sales , 
ABS(sls_quantity) AS sls_quantity , 
ABS(sls_price) AS  sls_price
FROM bronze.crm_sales_details
WHERE ABS(sls_sales) != ABS(sls_quantity) * ABS(sls_price);


SELECT
sls_due_dt
FROM bronze.crm_sales_details
WHERE LENGTH(sls_due_dt) != 8 ;

SELECT sls_order_dt,sls_ship_dt  
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_ship_dt > sls_due_dt;


SELECT *FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN ( SELECT cst_id FROM silver.crm_cust_info );




SELECT NEWC FROM(
SELECT
sls_ord_num,
CASE 
    WHEN sls_order_dt = 0 THEN null
    ELSE sls_order_dt 
END NEWC ,
sls_order_dt
FROM bronze.crm_sales_details)t
WHERE NEWC IS NULL;




SELECT 
sls_ord_num
sls_order_dt,
CAST(IFNULL(sls_order_dt,NULL) AS DATE ) AS Dls_order_dt,
sls_ship_dt,
CAST(sls_ship_dt AS DATE)  Dls_ship_dt,
sls_due_dt,
CAST(sls_due_dt AS DATE)  Dls_due_dt
FROM bronze.crm_sales_details;

SET SESSION sql_mode = '';

/* building silver layer 
   Clean & Load (erp_cust_az12 )
*/



SELECT  *FROM bronze.erp_cust_az12 ;
SELECT *FROM silver.crm_cust_info WHERE cst_key LIKE '%NASAW00011%';

 SELECT 
 TRIM(REPLACE(cid ,'NAS','')) AS cid
 FROM bronze.erp_cust_az12 
 WHERE NOT EXISTS  ( SELECT distinct 1  
                     FROM silver.crm_cust_info AS S
					WHERE S.cst_key = TRIM(REPLACE(cid ,'NAS','')) );
 
 
 SELECT TRIM(REPLACE(cid ,'NAS','')) FROM bronze.erp_cust_az12 WHERE cid LIKE '%NASAW00011%';
 
SELECT distinct bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > now();
 
SELECT  *FROM bronze.erp_cust_az12
WHERE  gen != 'Male' AND gen != 'Female' OR gen = '';

/* building silver layer 
   Clean & Load (erp_loc_a101 )
*/


SELECT distinct *FROM bronze.erp_loc_a101;
SELECT *FROM bronze.crm_cust_info;

SELECT 
REPLACE(cid,'-','') AS cid
FROM bronze.erp_loc_a101
WHERE NOT EXISTS (SELECT 1 FROM silver.crm_cust_info AS S
                  where S.cst_key = REPLACE(cid,'-',''))
;

SELECT distinct cntry  FROM bronze.erp_loc_a101;

/* building silver layer 
   Clean & Load (erp_px_cat_g1v2 )
*/
SELECT *FROM bronze.erp_px_cat_g1v2;
SELECT *FROM silver.crm_prd_info;

SELECT DISTINCT id
FROM bronze.erp_px_cat_g1v2
WHERE NOT EXISTS (SELECT 1 
                  FROM silver.crm_prd_info AS S
                  WHERE S.cat_id = id)
;
SELECT 
DISTINCT id 
FROM bronze.erp_px_cat_g1v2 
WHERE id NOT IN (SELECT DISTINCT cat_id FROM silver.crm_prd_info);

SELECT DISTINCTROW
subcat
FROM bronze.erp_px_cat_g1v2;

SELECT 
id
cat,
subcat,
maintanance
FROM bronze.erp_px_cat_g1v2
WHERE id != trim(id) OR cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintanance != TRIM(maintanance);
