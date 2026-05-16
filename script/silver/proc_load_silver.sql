
DELIMITER //
CREATE  PROCEDURE silver.load_silver()
BEGIN
SELECT 'LOADING SILVER LAYER'AS '';
		TRUNCATE silver.crm_cust_info;
		INSERT INTO silver.crm_cust_info
		( cst_id,  
		cst_key ,
		cst_firstname  ,
		cst_lastname ,
		cst_material_status ,
		cst_gndr  ,
		cst_create_date  
		)
		WITH CTE_duplicate AS
		(
		SELECT * 
		FROM(
			SELECT *,
			row_number() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS RANKED
			FROM bronze.crm_cust_info
			WHERE cst_id != 0
			)t
		WHERE RANKED = 1
		)
		SELECT 
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE 
			WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
			ELSE 'n\a'
		END cst_material_status,
		CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Femel'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'n\a'
		END cst_gndr,
		cst_create_date
		FROM CTE_duplicate;
		-- =====================================================================================================================================================================
		TRUNCATE silver.crm_prd_info;
		INSERT INTO silver.crm_prd_info(
		prd_id ,
		cat_id  ,
		prd_key , 
		prd_nm ,
		prd_cost , 
		prd_line , 
		prd_start_dt , 
		prd_end_dt 
		)
		WITH CTE_distinct AS(
		SELECT distinctrow 
			prd_id ,
			prd_key ,
			prd_nm , 
			prd_cost ,
			prd_line , 
			prd_start_dt , 
			prd_end_dt 
		FROM bronze.crm_prd_info
		)
		SELECT
		prd_id ,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
		SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key,
		prd_nm ,    
		prd_cost ,
		CASE UPPER(TRIM(prd_line)) 
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'M' THEN 'Mountain'
			WHEN 'T' THEN 'Touring'
			ELSE 'n\a'
		END  prd_line , 
		prd_start_dt , 
		IFNULL(DATE_SUB(LEAD( prd_start_dt) OVER( PARTITION BY prd_key ORDER BY prd_start_dt ),INTERVAL 1 DAY),NULL) AS prd_end_dt
		FROM CTE_distinct ;
		-- =========================================================================================================================================================
		TRUNCATE silver.crm_sales_details;
		INSERT INTO silver.crm_sales_details(
		sls_ord_num , 
		sls_prd_key ,
		sls_cust_id ,
		sls_order_dt ,
		sls_ship_dt ,
		sls_due_dt ,
		sls_sales , 
		sls_quantity ,
		sls_price 
		)
		SELECT distinctrow
		sls_ord_num ,
		sls_prd_key , 
		sls_cust_id ,
				CASE 
					WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN null
					ELSE CAST(sls_order_dt AS DATE)
				END  sls_order_dt ,
			   CASE 
					WHEN sls_ship_dt =0 OR LENGTH(sls_ship_dt) != 8 THEN null 
					ELSE CAST(sls_ship_dt AS DATE)
				END  sls_ship_dt,
			   CASE 
					WHEN sls_due_dt =0 OR LENGTH(sls_due_dt) != 8 THEN null 
					ELSE CAST(sls_due_dt AS DATE)
				END  sls_due_dt,
		CASE 
			WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales != sls_quantity * sls_price THEN sls_quantity * ABS(sls_price) 
			ELSE sls_sales
		END sls_sales,
		ABS(sls_quantity) AS  sls_quantity,
		CASE 
		   WHEN sls_price  IS NULL OR sls_price <= 0 THEN sls_sales / IFNULL(sls_quantity,0)
		   ELSE sls_price
		END sls_price
		FROM bronze.crm_sales_details;
		-- =====================================================================================================================================================================
		TRUNCATE silver.erp_cust_az12;
		INSERT INTO silver.erp_cust_az12( 
		cid,
		bdate,
		gen )


		SELECT 
		CASE 
			WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))
			ELSE cid
		END AS cid,
		CASE 
			WHEN bdate > NOW() THEN NULL
			ELSE bdate
		END bdate,
		CASE 
			WHEN UPPER(TRIM(gen )) IN ('M', 'MALE') THEN 'Male'
			WHEN UPPER(TRIM(gen )) IN ('F', 'FEMALE') THEN 'Female'
			WHEN gen = ''  THEN 'n\a'
			ELSE gen  
		END gen
		FROM bronze.erp_cust_az12;
		-- ================================================================================================================================================================
		TRUNCATE silver.erp_loc_a101;
		INSERT INTO silver.erp_loc_a101(
		cid,
		cntry
		)
		SELECT 
		REPLACE(cid,'-','') AS cid,
		CASE 
			WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
			WHEN TRIM(cntry) = '' OR NULL THEN 'n\a'
			else TRIM(cntry)
		END cntry
		FROM bronze.erp_loc_a101;
		-- ===================================================================================================================================================================

        
		TRUNCATE silver.erp_px_cat_g1v2;
		INSERT INTO silver.erp_px_cat_g1v2 (
		id,
		cat,
		subcat,
		maintanance)
		SELECT 
		id,
		cat,
		subcat,
		maintanance
		FROM bronze.erp_px_cat_g1v2;
END //

CALL silver.load_silver();
