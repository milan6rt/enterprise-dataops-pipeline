-- Multi-Environment Customer Table Script
-- This script will be deployed across DEV → PRE-PROD → PROD

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
        UpdatedDate DATETIME DEFAULT GETDATE()
    );
    
    PRINT 'SUCCESS: customers table created in environment!';
END
ELSE
BEGIN
    PRINT 'INFO: customers table already exists in this environment.';
END

-- Insert environment-specific sample data
IF NOT EXISTS (SELECT * FROM customers WHERE Email LIKE '%@enterprise.com')
BEGIN
    INSERT INTO customers (Name, Email, Phone, Department)
    VALUES 
        ('John Enterprise', 'john@enterprise.com', '555-0101', 'Engineering'),
        ('Sarah DataOps', 'sarah@enterprise.com', '555-0102', 'Data Analytics'),
        ('Mike Pipeline', 'mike@enterprise.com', '555-0103', 'DevOps');
    
    PRINT 'SUCCESS: Enterprise sample data inserted!';
END
ELSE
BEGIN
    PRINT 'INFO: Enterprise sample data already exists.';
END

-- Show environment status
SELECT 
    COUNT(*) as TotalCustomers,
    DB_NAME() as DatabaseName,
    GETDATE() as DeploymentTime
FROM customers;

-- Show recent customers
SELECT TOP 5 Name, Email, Department, CreatedDate 
FROM customers 
ORDER BY CreatedDate DESC;
