#!/usr/bin/env python3
"""
Data Quality Tests for Multi-Environment Pipeline
"""

import pymssql
import sys
import os

def test_table_exists(cursor):
    """Test that customers table exists"""
    cursor.execute("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'customers'")
    table_exists = cursor.fetchone()[0]
    assert table_exists > 0, "customers table not found"
    print("✅ Test 1 passed: customers table exists")

def test_no_null_emails(cursor):
    """Test that no customers have null or empty emails"""
    cursor.execute("SELECT COUNT(*) FROM customers WHERE Email IS NULL OR Email = ''")
    null_emails = cursor.fetchone()[0]
    assert null_emails == 0, "Found customers with null/empty emails"
    print("✅ Test 2 passed: No null emails found")

def test_email_format(cursor):
    """Test that all emails have valid format"""
    cursor.execute("SELECT COUNT(*) FROM customers WHERE Email NOT LIKE '%@%'")
    invalid_emails = cursor.fetchone()[0]
    assert invalid_emails == 0, "Found customers with invalid email format"
    print("✅ Test 3 passed: All emails have valid format")

def test_customer_count(cursor):
    """Test that we have at least some customers"""
    cursor.execute("SELECT COUNT(*) FROM customers")
    count = cursor.fetchone()[0]
    assert count > 0, "No customers found in database"
    print(f"✅ Test 4 passed: Found {count} customers")

def main():
    """Run all data quality tests"""
    # These will be provided by the pipeline
    server = os.environ.get('SQL_SERVER')
    database = os.environ.get('SQL_DATABASE') 
    username = os.environ.get('SQL_USERNAME')
    password = os.environ.get('SQL_PASSWORD')
    
    if not all([server, database, username, password]):
        print("❌ Missing database connection environment variables")
        sys.exit(1)
    
    try:
        print(f"🧪 Running data quality tests on {database}...")
        
        conn = pymssql.connect(
            server=server,
            user=username,
            password=password,
            database=database
        )
        cursor = conn.cursor()
        
        # Run all tests
        test_table_exists(cursor)
        test_no_null_emails(cursor)
        test_email_format(cursor)
        test_customer_count(cursor)
        
        conn.close()
        print("🎉 All data quality tests passed!")
        
    except Exception as e:
        print(f"❌ Data quality tests failed: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
