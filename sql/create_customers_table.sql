-- Multi-Environment Customer Table Script
-- Last updated: 2025-07-02 - Added Lisa CloudOps for testing enterprise workflow
-- This script will be deployed across DEV → PRE-PROD → PROD environments
-- Version: 1.1.0

-- =================================================================
-- ENTERPRISE CUSTOMER TABLE DEPLOYMENT
-- =================================================================

-- Create customers table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'customers' AND type = 'U')
BEGIN
    CREATE TABLE customers (
        CustomerID INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) UNIQUE NOT NULL,
        Phone NVARCHAR(20),
        Department NVARCHAR(50),
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1,
        Notes NVARCHAR(500)
    );
    
    -- Add indexes for better performance
    CREATE INDEX IX_customers_email ON customers(Email);
    CREATE INDEX IX_customers_department ON customers(Department);
    CREATE INDEX IX_customers_created_date ON customers(CreatedDate);
    
    PRINT 'SUCCESS: customers table created in environment with indexes!';
END
ELSE
BEGIN
    PRINT 'INFO: customers table already exists in this environment.';
    
    -- Check if new columns need to be added (for schema evolution)
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('customers') AND name = 'IsActive')
    BEGIN
        ALTER TABLE customers ADD IsActive BIT DEFAULT 1;
        PRINT 'SUCCESS: Added IsActive column to existing customers table.';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('customers') AND name = 'Notes')
    BEGIN
        ALTER TABLE customers ADD Notes NVARCHAR(500);
        PRINT 'SUCCESS: Added Notes column to existing customers table.';
    END
END

-- =================================================================
-- INSERT ENTERPRISE SAMPLE DATA
-- =================================================================

-- Insert environment-specific sample data
IF NOT EXISTS (SELECT * FROM customers WHERE Email LIKE '%@enterprise.com')
BEGIN
    INSERT INTO customers (Name, Email, Phone, Department, Notes)
    VALUES 
        ('John Enterprise', 'john@enterprise.com', '555-0101', 'Engineering', 'Lead Software Engineer - Database Systems'),
        ('Sarah DataOps', 'sarah@enterprise.com', '555-0102', 'Data Analytics', 'Senior Data Analyst - Business Intelligence'),
        ('Mike Pipeline', 'mike@enterprise.com', '555-0103', 'DevOps', 'DevOps Engineer - CI/CD Infrastructure'),
        ('Lisa CloudOps', 'lisa@enterprise.com', '555-0104', 'Cloud Operations', 'Cloud Operations Specialist - Azure Infrastructure');
    
    PRINT 'SUCCESS: Enterprise sample data inserted (4 customers)!';
END
ELSE
BEGIN
    PRINT 'INFO: Enterprise sample data already exists. Checking for new additions...';
    
    -- Add Lisa CloudOps if she doesn't exist (for incremental deployments)
    IF NOT EXISTS (SELECT * FROM customers WHERE Email = 'lisa@enterprise.com')
    BEGIN
        INSERT INTO customers (Name, Email, Phone, Department, Notes)
        VALUES ('Lisa CloudOps', 'lisa@enterprise.com', '555-0104', 'Cloud Operations', 'Cloud Operations Specialist - Azure Infrastructure');
        PRINT 'SUCCESS: Added Lisa CloudOps to existing customer data!';
    END
    ELSE
    BEGIN
        PRINT 'INFO: Lisa CloudOps already exists in customer data.';
    END
    
    -- Update any customers with missing phone numbers or notes
    UPDATE customers 
    SET Phone = CASE 
        WHEN Email = 'john@enterprise.com' AND (Phone IS NULL OR Phone = '') THEN '555-0101'
        WHEN Email = 'sarah@enterprise.com' AND (Phone IS NULL OR Phone = '') THEN '555-0102'
        WHEN Email = 'mike@enterprise.com' AND (Phone IS NULL OR Phone = '') THEN '555-0103'
        WHEN Email = 'lisa@enterprise.com' AND (Phone IS NULL OR Phone = '') THEN '555-0104'
        ELSE Phone
    END,
    Notes = CASE 
        WHEN Email = 'john@enterprise.com' AND (Notes IS NULL OR Notes = '') THEN 'Lead Software Engineer - Database Systems'
        WHEN Email = 'sarah@enterprise.com' AND (Notes IS NULL OR Notes = '') THEN 'Senior Data Analyst - Business Intelligence'
        WHEN Email = 'mike@enterprise.com' AND (Notes IS NULL OR Notes = '') THEN 'DevOps Engineer - CI/CD Infrastructure'
        WHEN Email = 'lisa@enterprise.com' AND (Notes IS NULL OR Notes = '') THEN 'Cloud Operations Specialist - Azure Infrastructure'
        ELSE Notes
    END,
    UpdatedDate = GETDATE()
    WHERE Email LIKE '%@enterprise.com' 
    AND (Phone IS NULL OR Phone = '' OR Notes IS NULL OR Notes = '');
    
    IF @@ROWCOUNT > 0
        PRINT 'SUCCESS: Updated existing customer records with missing data.';
END

-- =================================================================
-- ADD SAMPLE EXTERNAL CUSTOMERS (for testing)
-- =================================================================

-- Add some external customers for realistic data
IF NOT EXISTS (SELECT * FROM customers WHERE Email LIKE '%@external.com')
BEGIN
    INSERT INTO customers (Name, Email, Phone, Department, Notes)
    VALUES 
        ('Alice Johnson', 'alice@external.com', '555-0201', 'Marketing', 'External Marketing Consultant'),
        ('Bob Wilson', 'bob@external.com', '555-0202', 'Sales', 'External Sales Representative'),
        ('Carol Martinez', 'carol@external.com', '555-0203', 'Support', 'External Customer Support Specialist');
    
    PRINT 'SUCCESS: External customer sample data inserted (3 additional customers)!';
END
ELSE
BEGIN
    PRINT 'INFO: External customer sample data already exists.';
END

-- =================================================================
-- DEPLOYMENT VERIFICATION AND REPORTING
-- =================================================================

-- Show environment status and deployment summary
DECLARE @CustomerCount INT;
DECLARE @EnterpriseCount INT;
DECLARE @ExternalCount INT;
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @DeploymentTime DATETIME;

SELECT @CustomerCount = COUNT(*) FROM customers;
SELECT @EnterpriseCount = COUNT(*) FROM customers WHERE Email LIKE '%@enterprise.com';
SELECT @ExternalCount = COUNT(*) FROM customers WHERE Email LIKE '%@external.com';
SELECT @DatabaseName = DB_NAME();
SELECT @DeploymentTime = GETDATE();

PRINT '=================================================================';
PRINT 'DEPLOYMENT SUMMARY REPORT';
PRINT '=================================================================';
PRINT 'Database: ' + @DatabaseName;
PRINT 'Deployment Time: ' + CONVERT(VARCHAR, @DeploymentTime, 120);
PRINT 'Total Customers: ' + CAST(@CustomerCount AS VARCHAR);
PRINT 'Enterprise Customers: ' + CAST(@EnterpriseCount AS VARCHAR);
PRINT 'External Customers: ' + CAST(@ExternalCount AS VARCHAR);
PRINT '=================================================================';

-- Return summary data for pipeline verification
SELECT 
    @CustomerCount as TotalCustomers,
    @EnterpriseCount as EnterpriseCustomers,
    @ExternalCount as ExternalCustomers,
    @DatabaseName as DatabaseName,
    @DeploymentTime as DeploymentTime;

-- Show recent customers (for verification)
SELECT TOP 5 
    CustomerID,
    Name, 
    Email, 
    Department,
    Phone,
    CreatedDate,
    CASE WHEN Email LIKE '%@enterprise.com' THEN 'Enterprise' ELSE 'External' END as CustomerType
FROM customers 
ORDER BY CreatedDate DESC;

-- Show department distribution
SELECT 
    Department,
    COUNT(*) as CustomerCount,
    STRING_AGG(Name, ', ') as Customers
FROM customers 
GROUP BY Department
ORDER BY COUNT(*) DESC;

PRINT '✅ Enterprise customer table deployment completed successfully!';