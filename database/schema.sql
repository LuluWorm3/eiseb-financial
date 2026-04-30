-- ============================================================
-- Eiseb Country Traders
-- Livestock Financial Management System
-- WPM711S Group 2 — 2026
-- ============================================================

CREATE DATABASE IF NOT EXISTS eiseb_financial;
USE eiseb_financial;

-- Users (Login & Register)
CREATE TABLE users (
    user_id     INT AUTO_INCREMENT PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,      -- store hashed passwords
    role        ENUM('admin','manager','staff') DEFAULT 'staff',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Livestock
CREATE TABLE livestock (
    livestock_id    INT AUTO_INCREMENT PRIMARY KEY,
    tag_number      VARCHAR(50) NOT NULL UNIQUE,
    species         VARCHAR(50) NOT NULL,   -- e.g. Cattle, Goat
    breed           VARCHAR(100),
    gender          ENUM('Male','Female') NOT NULL,
    date_of_birth   DATE,
    current_value   DECIMAL(10,2),          -- estimated market value (N$)
    status          ENUM('Active','Sold','Deceased') DEFAULT 'Active',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Financial Transactions
CREATE TABLE transactions (
    transaction_id  INT AUTO_INCREMENT PRIMARY KEY,
    transaction_type ENUM('Income','Expense') NOT NULL,
    category        VARCHAR(100) NOT NULL,  -- e.g. Livestock Sale, Feed, Vet, Transport
    amount          DECIMAL(10,2) NOT NULL,
    description     TEXT,
    livestock_id    INT,                    -- optional link to a specific animal
    recorded_by     INT NOT NULL,
    transaction_date DATE NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (livestock_id) REFERENCES livestock(livestock_id) ON DELETE SET NULL,
    FOREIGN KEY (recorded_by) REFERENCES users(user_id)
);

-- Expense Categories (lookup)
CREATE TABLE expense_categories (
    category_id     INT AUTO_INCREMENT PRIMARY KEY,
    category_name   VARCHAR(100) NOT NULL UNIQUE   -- Feed, Veterinary, Transport, Wages, etc.
);

-- Livestock Valuations (periodic)
CREATE TABLE valuations (
    valuation_id    INT AUTO_INCREMENT PRIMARY KEY,
    livestock_id    INT NOT NULL,
    valuation_date  DATE NOT NULL,
    estimated_value DECIMAL(10,2) NOT NULL,
    notes           TEXT,
    FOREIGN KEY (livestock_id) REFERENCES livestock(livestock_id) ON DELETE CASCADE
);

-- Contact Enquiries
CREATE TABLE contact_enquiries (
    enquiry_id  INT AUTO_INCREMENT PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL,
    message     TEXT NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Sample seed data
-- ============================================================
INSERT INTO users (full_name, email, password, role) VALUES
('Admin User', 'admin@eiseb.na', 'hashed_password_here', 'admin');

INSERT INTO expense_categories (category_name) VALUES
('Feed'), ('Veterinary'), ('Transport'), ('Wages'), ('Equipment'), ('Other');
