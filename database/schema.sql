-- ============================================================
-- Eiseb Country Traders
-- Livestock Financial Management System
-- WPM711S Group 2 — 2026
-- ============================================================

-- Drop database if exists (for clean setup)
DROP DATABASE IF EXISTS eiseb_financial;

-- Create database
CREATE DATABASE IF NOT EXISTS eiseb_financial;
USE eiseb_financial;

CREATE TABLE users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100)  NOT NULL,
    username      VARCHAR(50)   NOT NULL UNIQUE,
    email         VARCHAR(100)  NOT NULL UNIQUE,
    password_hash VARCHAR(255)  NOT NULL,
    role          ENUM('admin','manager','staff') DEFAULT 'staff',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE livestock (
    livestock_id  INT AUTO_INCREMENT PRIMARY KEY,
    tag_number    VARCHAR(50)   NOT NULL UNIQUE,
    species       VARCHAR(50)   NOT NULL,
    breed         VARCHAR(100),
    gender        ENUM('Male','Female') NOT NULL,
    date_of_birth DATE,
    current_value DECIMAL(10,2),
    status        ENUM('Active','Sold','Deceased') DEFAULT 'Active',
    registered_by INT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (registered_by) REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE TABLE buyers (
    buyer_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name      VARCHAR(100) NOT NULL,
    company_name   VARCHAR(150),
    contact_number VARCHAR(20),
    email          VARCHAR(100),
    address        TEXT,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sales (
    sale_id        INT AUTO_INCREMENT PRIMARY KEY,
    livestock_id   INT          NOT NULL,
    buyer_id       INT          NOT NULL,
    sale_date      DATE         NOT NULL,
    sale_price     DECIMAL(10,2) NOT NULL,
    sale_type      ENUM('Direct Sale','Auction') DEFAULT 'Direct Sale',
    payment_status ENUM('Paid','Pending','Partial') DEFAULT 'Pending',
    notes          TEXT,
    recorded_by    INT          NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (livestock_id) REFERENCES livestock(livestock_id) ON DELETE RESTRICT,
    FOREIGN KEY (buyer_id)     REFERENCES buyers(buyer_id)        ON DELETE RESTRICT,
    FOREIGN KEY (recorded_by)  REFERENCES users(user_id)          ON DELETE RESTRICT
);

CREATE TABLE expense_categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE expenses (
    expense_id    INT AUTO_INCREMENT PRIMARY KEY,
    category_id   INT          NOT NULL,
    amount        DECIMAL(10,2) NOT NULL,
    expense_date  DATE         NOT NULL,
    description   TEXT,
    livestock_id  INT,
    recorded_by   INT          NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id)  REFERENCES expense_categories(category_id) ON DELETE RESTRICT,
    FOREIGN KEY (livestock_id) REFERENCES livestock(livestock_id)          ON DELETE SET NULL,
    FOREIGN KEY (recorded_by)  REFERENCES users(user_id)                   ON DELETE RESTRICT
);

CREATE TABLE valuations (
    valuation_id     INT AUTO_INCREMENT PRIMARY KEY,
    livestock_id     INT          NOT NULL,
    valuation_date   DATE         NOT NULL,
    estimated_value  DECIMAL(10,2) NOT NULL,
    valuation_method VARCHAR(100),
    notes            TEXT,
    recorded_by      INT          NOT NULL,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (livestock_id) REFERENCES livestock(livestock_id) ON DELETE CASCADE,
    FOREIGN KEY (recorded_by)  REFERENCES users(user_id)          ON DELETE RESTRICT
);

CREATE TABLE contact_enquiries (
    enquiry_id   INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(100) NOT NULL,
    subject      VARCHAR(200),
    message      TEXT         NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_log (
    log_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT,
    action          VARCHAR(20) NOT NULL,
    table_name      VARCHAR(50) NOT NULL,
    record_id       INT NOT NULL,
    old_value       JSON,
    new_value       JSON,
    ip_address      VARCHAR(45),
    changed_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- ============================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================

CREATE INDEX idx_livestock_status ON livestock(status);
CREATE INDEX idx_livestock_tag ON livestock(tag_number);
CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_sales_payment ON sales(payment_status);
CREATE INDEX idx_expenses_date ON expenses(expense_date);
CREATE INDEX idx_valuations_animal ON valuations(livestock_id, valuation_date);
CREATE INDEX idx_audit_changed ON audit_log(changed_at);
CREATE INDEX idx_audit_user ON audit_log(user_id);

-- ============================================================
-- SEED DATA (Sample data)
-- ============================================================

-- Users
INSERT INTO users (full_name, username, email, password_hash, role) VALUES
('Admin User',    'admin',    'admin@eiseb.na',   'hashed_password_here', 'admin'),
('Kampolo Manager',  'kmanager', 'kampolo@eiseb.na',    'hashed_password_here', 'manager'),
('Basson Staff',     'bstaff',   'basson@eiseb.na',     'hashed_password_here', 'staff');

-- Expense categories
INSERT INTO expense_categories (category_name) VALUES
('Feed'),
('Veterinary'),
('Transport'),
('Wages'),
('Equipment'),
('Other');

-- Buyers
INSERT INTO buyers (full_name, company_name, contact_number, email, address) VALUES
('Tiaan Steenkamp', 'Agra Auctions Windhoek',     '+264 61 290 9254', 'chairmainem@agra.com.na',  'Windhoek, Namibia'),
('Corporate Affairs Desk', 'Meat Corporation of Namibia',     '+264 61 321 6400', 'caffairs@meatco.com.na',       'Windhoek, Namibia'),
('Wilem Venter', 'Windhoek Livestock Auctioneers',   '+264 81 127 0870', 'lorna@whkla.com',  'Windhoek, Namibia');

-- Livestock
INSERT INTO livestock (tag_number, species, breed, gender, date_of_birth, current_value, status, registered_by) VALUES
('ECT-001', 'Cattle', 'Brahman',   'Male',   '2021-03-15', 24500.00, 'Active', 1),
('ECT-002', 'Cattle', 'Simmental', 'Female', '2020-07-22', 23000.00, 'Active', 1),
('ECT-003', 'Cattle', 'Nguni',     'Female', '2019-11-05', 8200.00,  'Sold',   2),
('ECT-004', 'Goat',   'Boer',      'Male',   '2022-01-10', 2300.00,  'Active', 2),
('ECT-005', 'Cattle', 'Bonsmara',  'Male',   '2020-05-18', 18000.00, 'Active', 1);
('ECT-006', 'Sheep',  'Karakul',   'Male',   '2022-03-10', 1250.00,  'Active', 1),
('ECT-007', 'Sheep',  'Dorper',    'Female', '2021-11-18', 1850.00,  'Active', 1);

-- Sales
INSERT INTO sales (livestock_id, buyer_id, sale_date, sale_price, sale_type, payment_status, notes, recorded_by) VALUES
(3, 1, '2025-09-14', 10500.00, 'Direct Sale', 'Paid',    'Sold to Agra Auctions Windhoek', 1),
(2, 3, '2025-11-02', 11200.00, 'Auction',     'Pending', 'Sold to Windheok Livestock Auctioneers',      2);

-- Expenses
INSERT INTO expenses (category_id, amount, expense_date, description, livestock_id, recorded_by) VALUES
(1, 4500.00, '2026-01-10', 'Monthly feed supply — bulk hay and pellets',      NULL, 2),
(2, 1200.00, '2026-01-22', 'Veterinary checkup and vaccinations for herd',    1,    2),
(3, 850.00,  '2025-12-10', 'Dipping and deworming for Brahman herd',          1, 2),
(4, 3500.00, '2026-02-01', 'New cattle handling scale for weighing animals',  NULL, 2),
(5, 2300.00, '2026-03-15', 'Replacement water pump for eastern pasture',      NULL, 2);
(6, 650.00,  '2026-03-05', 'Emergency vet callout for sick male Brahman',     1, 1),
(7, 7000.00, '2026-03-31', 'March wages for two farm workers',                NULL, 2),


-- Valuations
INSERT INTO valuations (livestock_id, valuation_date, estimated_value, valuation_method, notes, recorded_by) VALUES
(1, '2025-07-01', 11800.00, 'Market Rate',       'Mid-year market rate review',         1),
(1, '2026-01-01', 12500.00, 'Market Rate',       'January annual valuation',             1),
(6, '2026-01-01',  4500.00, 'Market Rate',       'January annual valuation               2);
(4, '2026-01-01',  3200.00, 'Market Rate',       'January annual valuation',             2),
(5, '2026-01-01', 13000.00, 'Market Rate',       'January annual valuation',             1);

-- Contact enquiries
INSERT INTO contact_enquiries (full_name, email, subject, message) VALUES
('Wilem Venter', 'lorna@whkla.com', 'Livestock pricing query', 'Hello, I would like to know the current prices for Brahman cattle. Please contact me.');


-- View 1: Basic income total
CREATE OR REPLACE VIEW v_total_income AS
SELECT SUM(sale_price) AS total_income_NAD
FROM sales
WHERE payment_status = 'Paid';

-- View 2: Expenses by category
CREATE OR REPLACE VIEW v_expenses_by_category AS
SELECT ec.category_name, SUM(e.amount) AS total_spent_NAD
FROM expenses e
JOIN expense_categories ec ON e.category_id = ec.category_id
GROUP BY ec.category_name
ORDER BY total_spent_NAD DESC;

-- View 3: Active livestock with latest valuation
CREATE OR REPLACE VIEW v_active_livestock_value AS
SELECT
    l.tag_number,
    l.species,
    l.breed,
    l.gender,
    l.status,
    v.estimated_value,
    v.valuation_date
FROM livestock l
LEFT JOIN valuations v ON v.valuation_id = (
    SELECT valuation_id FROM valuations
    WHERE livestock_id = l.livestock_id
    ORDER BY valuation_date DESC
    LIMIT 1
)
WHERE l.status = 'Active';

-- View 4: Monthly Profit & Loss Summary
CREATE OR REPLACE VIEW v_financial_summary AS
SELECT 
    YEAR(s.sale_date) AS year,
    MONTH(s.sale_date) AS month,
    COALESCE(SUM(CASE WHEN s.payment_status = 'Paid' THEN s.sale_price ELSE 0 END), 0) AS total_income,
    COALESCE(SUM(e.amount), 0) AS total_expenses,
    COALESCE(SUM(CASE WHEN s.payment_status = 'Paid' THEN s.sale_price ELSE 0 END), 0) - COALESCE(SUM(e.amount), 0) AS net_profit
FROM sales s
LEFT JOIN expenses e ON YEAR(s.sale_date) = YEAR(e.expense_date) AND MONTH(s.sale_date) = MONTH(e.expense_date)
GROUP BY YEAR(s.sale_date), MONTH(s.sale_date)
UNION
SELECT 
    YEAR(e.expense_date) AS year,
    MONTH(e.expense_date) AS month,
    0 AS total_income,
    SUM(e.amount) AS total_expenses,
    -SUM(e.amount) AS net_profit
FROM expenses e
WHERE NOT EXISTS (
    SELECT 1 FROM sales s 
    WHERE YEAR(s.sale_date) = YEAR(e.expense_date) 
    AND MONTH(s.sale_date) = MONTH(e.expense_date)
)
GROUP BY YEAR(e.expense_date), MONTH(e.expense_date)
ORDER BY year DESC, month DESC;

-- View 5: Real-time Dashboard Metrics
CREATE OR REPLACE VIEW v_dashboard_metrics AS
SELECT 
    -- Livestock metrics
    (SELECT COUNT(*) FROM livestock WHERE status = 'Active') AS active_animals,
    (SELECT COUNT(*) FROM livestock WHERE status = 'Sold') AS sold_animals,
    (SELECT COUNT(*) FROM livestock WHERE status = 'Deceased') AS deceased_animals,
    (SELECT COALESCE(SUM(current_value), 0) FROM livestock WHERE status = 'Active') AS total_herd_value,
    
    -- Financial metrics
    (SELECT COALESCE(SUM(sale_price), 0) FROM sales WHERE payment_status = 'Paid') AS total_revenue,
    (SELECT COALESCE(SUM(amount), 0) FROM expenses) AS total_expenses,
    (SELECT COALESCE(SUM(sale_price), 0) FROM sales WHERE payment_status = 'Paid') - (SELECT COALESCE(SUM(amount), 0) FROM expenses) AS net_profit,
    
    -- Sales metrics
    (SELECT COUNT(*) FROM sales WHERE payment_status = 'Pending') AS pending_payments_count,
    
    -- System metrics
    (SELECT COUNT(*) FROM users) AS total_users;

-- View 6: Top Buyers Report
CREATE OR REPLACE VIEW v_top_buyers AS
SELECT 
    b.buyer_id,
    b.full_name,
    b.company_name,
    COUNT(s.sale_id) AS total_purchases,
    SUM(s.sale_price) AS total_spent,
    AVG(s.sale_price) AS average_purchase_value,
    MAX(s.sale_date) AS last_purchase_date
FROM buyers b
JOIN sales s ON b.buyer_id = s.buyer_id
WHERE s.payment_status = 'Paid'
GROUP BY b.buyer_id, b.full_name, b.company_name
ORDER BY total_spent DESC;

-- View 7: Audit Trail with User Details
CREATE OR REPLACE VIEW v_audit_trail AS
SELECT 
    al.log_id,
    al.action,
    al.table_name,
    al.record_id,
    al.old_value,
    al.new_value,
    al.changed_at,
    al.ip_address,
    u.full_name AS user_name,
    u.username,
    u.role AS user_role
FROM audit_log al
LEFT JOIN users u ON al.user_id = u.user_id
ORDER BY al.changed_at DESC;


DELIMITER $$

-- Procedure: Generate Financial Report for date range
CREATE PROCEDURE sp_financial_report(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    -- Income Summary
    SELECT 
        'Income Summary' AS report_section,
        SUM(s.sale_price) AS total_amount,
        COUNT(s.sale_id) AS transaction_count
    FROM sales s
    WHERE s.sale_date BETWEEN p_start_date AND p_end_date
        AND s.payment_status = 'Paid';
    
    -- Expense Summary
    SELECT 
        'Expense Summary' AS report_section,
        ec.category_name,
        SUM(e.amount) AS total_amount,
        COUNT(e.expense_id) AS transaction_count
    FROM expenses e
    JOIN expense_categories ec ON e.category_id = ec.category_id
    WHERE e.expense_date BETWEEN p_start_date AND p_end_date
    GROUP BY ec.category_name
    ORDER BY total_amount DESC;
    
    -- Net Profit/Loss
    SELECT 
        'Net Profit/Loss' AS report_section,
        COALESCE((SELECT SUM(sale_price) FROM sales WHERE sale_date BETWEEN p_start_date AND p_end_date AND payment_status = 'Paid'), 0) AS total_income,
        COALESCE((SELECT SUM(amount) FROM expenses WHERE expense_date BETWEEN p_start_date AND p_end_date), 0) AS total_expenses,
        COALESCE((SELECT SUM(sale_price) FROM sales WHERE sale_date BETWEEN p_start_date AND p_end_date AND payment_status = 'Paid'), 0) - 
        COALESCE((SELECT SUM(amount) FROM expenses WHERE expense_date BETWEEN p_start_date AND p_end_date), 0) AS net_profit;
END$$

-- Procedure: Get User Activity Summary
CREATE PROCEDURE sp_user_activity(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT 
        u.user_id,
        u.full_name,
        u.username,
        u.role,
        COUNT(al.log_id) AS total_actions,
        SUM(CASE WHEN al.action = 'INSERT' THEN 1 ELSE 0 END) AS inserts,
        SUM(CASE WHEN al.action = 'UPDATE' THEN 1 ELSE 0 END) AS updates,
        SUM(CASE WHEN al.action = 'DELETE' THEN 1 ELSE 0 END) AS deletes
    FROM users u
    LEFT JOIN audit_log al ON u.user_id = al.user_id 
        AND DATE(al.changed_at) BETWEEN p_start_date AND p_end_date
    GROUP BY u.user_id, u.full_name, u.username, u.role
    ORDER BY total_actions DESC;
END$$

DELIMITER ;


DELIMITER $$

-- Set current user (application should set these before operations)
-- SET @current_user_id = 1;
-- SET @ip_address = '127.0.0.1';

-- Trigger for livestock table
CREATE TRIGGER audit_livestock_insert
AFTER INSERT ON livestock
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, record_id, new_value, ip_address)
    VALUES (
        @current_user_id,
        'INSERT',
        'livestock',
        NEW.livestock_id,
        JSON_OBJECT(
            'tag_number', NEW.tag_number,
            'species', NEW.species,
            'breed', NEW.breed,
            'gender', NEW.gender,
            'current_value', NEW.current_value,
            'status', NEW.status
        ),
        @ip_address
    );
END$$

CREATE TRIGGER audit_livestock_update
AFTER UPDATE ON livestock
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, record_id, old_value, new_value, ip_address)
    VALUES (
        @current_user_id,
        'UPDATE',
        'livestock',
        NEW.livestock_id,
        JSON_OBJECT(
            'tag_number', OLD.tag_number,
            'species', OLD.species,
            'current_value', OLD.current_value,
            'status', OLD.status
        ),
        JSON_OBJECT(
            'tag_number', NEW.tag_number,
            'species', NEW.species,
            'current_value', NEW.current_value,
            'status', NEW.status
        ),
        @ip_address
    );
END$$

-- Trigger for sales table
CREATE TRIGGER audit_sales_insert
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, record_id, new_value, ip_address)
    VALUES (
        @current_user_id,
        'INSERT',
        'sales',
        NEW.sale_id,
        JSON_OBJECT(
            'livestock_id', NEW.livestock_id,
            'buyer_id', NEW.buyer_id,
            'sale_price', NEW.sale_price,
            'payment_status', NEW.payment_status
        ),
        @ip_address
    );
END$$

-- Trigger for expenses table
CREATE TRIGGER audit_expenses_insert
AFTER INSERT ON expenses
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, record_id, new_value, ip_address)
    VALUES (
        @current_user_id,
        'INSERT',
        'expenses',
        NEW.expense_id,
        JSON_OBJECT(
            'category_id', NEW.category_id,
            'amount', NEW.amount,
            'expense_date', NEW.expense_date
        ),
        @ip_address
    );
END$$

DELIMITER ;


-- Check all tables created
-- SHOW TABLES;

-- Check dashboard metrics
-- SELECT * FROM v_dashboard_metrics;

-- Check financial summary
-- SELECT * FROM v_financial_summary;

-- Check active livestock values
-- SELECT * FROM v_active_livestock_value;

-- Check top buyers
-- SELECT * FROM v_top_buyers;

-- Check audit trail
-- SELECT * FROM v_audit_trail;

-- Run financial report
-- CALL sp_financial_report('2025-01-01', '2026-12-31');
