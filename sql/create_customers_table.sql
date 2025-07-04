-- Simple Customer Table Script
-- Updated: 2025-07-02 - Added Lisa CloudOps for testing
-- Deploys to: DEV → PRE-PROD → PROD

-- Create customers table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'customers')
BEGIN
    CREATE TABLE customers (
        CustomerID INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) UNIQUE NOT NULL,
        Department NVARCHAR(50),
        CreatedDate DATETIME DEFAULT GETDATE()
    );
    
    PRINT 'SUCCESS: customers table created!';
END
ELSE
BEGIN
    PRINT 'INFO: customers table already exists.';
END

-- Clear existing data to avoid conflicts
DELETE FROM customers;
PRINT 'INFO: Cleared existing customer data for fresh deployment.';

-- Insert fresh customer data
INSERT INTO customers (Name, Email, Department)
VALUES 
    ('John Enterprise', 'john@enterprise.com', 'Data Ops'),
    ('Sarah DataOps', 'sarah@enterprise.com', 'Data Analytics'),
    ('Mike Pipeline', 'mike@enterprise.com', 'DevOps'),
    ('Lisa CloudOps', 'lisa@enterprise.com', 'Cloud Operations');

PRINT 'SUCCESS: Inserted 4 enterprise customers!';

-- Show results
SELECT COUNT(*) as TotalCustomers FROM customers;
SELECT Name, Email, Department FROM customers ORDER BY Name;

PRINT 'DEPLOYMENT COMPLETED SUCCESSFULLY!';