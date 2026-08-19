CREATE DATABASE sales_db;
USE sales_db;

CREATE TABLE vendors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    business_info TEXT,ledger_entries
    id_number VARCHAR(100),
    verification_status VARCHAR(20) DEFAULT 'unverified', -- unverified | pending | verified 
    bank_account_ref VARCHAR(255), -- placeholder for bank details
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ledger_entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INTEGER,
    type VARCHAR(20) NOT NULL, -- 'received' | 'released' | 'refund' 
    amount NUMERIC(12, 2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'pending', -- pending | held | released | failure 
    reference_id VARCHAR(100), -- external/mock transfer id 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

ALTER TABLE ledger_entries ADD COLUMN fee DECIMAL(12,2) DEFAULT 0.00;

CREATE TABLE processor_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT,
    amount DECIMAL(12,2) NOT NULL,
    reference_id VARCHAR(100),
    event_type VARCHAR(30), -- 'payment.succeeded', 'payment.failed'
    received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

