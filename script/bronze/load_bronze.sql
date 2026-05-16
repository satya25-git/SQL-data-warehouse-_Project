
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE "secure_file_priv";

TRUNCATE TABLE bronze.crm_cust_info;
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\sql-data-warehouse-project-main\\sql-data-warehouse-project-main\\datasets\\source_crm\\cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

 
 TRUNCATE TABLE bronze.crm_prd_info;
 LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\sql-data-warehouse-project-main\\sql-data-warehouse-project-main\\datasets\\source_crm\\prd_info.csv'
 INTO TABLE bronze.crm_prd_info
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\r\n'
 IGNORE 1 ROWS ;

TRUNCATE bronze.crm_sales_details;
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\sql-data-warehouse-project-main\\sql-data-warehouse-project-main\\datasets\\source_crm\\sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

TRUNCATE bronze.erp_cust_az12;
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\sql-data-warehouse-project-main\\sql-data-warehouse-project-main\\datasets\\source_erp\\CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY  ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

TRUNCATE bronze.erp_loc_a101;
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\sql-data-warehouse-project-main\\sql-data-warehouse-project-main\\datasets\\source_erp\\LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY  ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

TRUNCATE bronze.erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\sql-data-warehouse-project-main\\sql-data-warehouse-project-main\\datasets\\source_erp\\PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY  ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


