# Enterprise DataOps Pipeline

Multi-environment CI/CD pipeline for database deployments with DEV → PRE-PROD → PROD workflow.

## Environment Flow

GitHub Push → DEV (auto) → PRE-PROD (auto + tests) → PROD (manual approval + tests)

## Project Structure

enterprise-dataops-pipeline/
├── sql/                          # Database scripts
│   └── create_customers_table.sql
├── environments/                 # Environment-specific configs
│   ├── dev/config.yml
│   ├── preprod/config.yml
│   └── prod/config.yml
├── tests/                        # Data quality tests
│   └── data_quality_tests.py
├── azure-pipelines.yml           # Multi-environment pipeline
└── README.md

## Features

- ✅ Multi-environment deployment
- ✅ Automated data quality testing
- ✅ Manual production approvals  
- ✅ Environment isolation
- ✅ Rollback capabilities
