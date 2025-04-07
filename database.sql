-- Step 1: Create the database
CREATE DATABASE ptfms;

-- Step 2: Use the created database
USE ptfms;

-- Step 3: Create the Users Table (Store hashed password instead of plain text)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,  -- Store hashed password
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 4: Create the Roles Table (This table will allow for flexible role management)
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE  -- e.g., 'Admin', 'Operator', 'Manager'
);

-- Step 5: Create the User_Roles Table (Assign roles to users)
CREATE TABLE user_roles (
    user_role_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
);

-- Step 6: Create the Vehicles Table
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    registration_number VARCHAR(255) NOT NULL UNIQUE,
    model VARCHAR(255) NOT NULL,
    vehicle_type ENUM('Diesel Bus', 'Electric Light Rail', 'Diesel-Electric Train') NOT NULL,
    fuel_type ENUM('Diesel', 'CNG', 'Electric', 'Hybrid') NOT NULL,
    consumption_rate DECIMAL(7,3) NOT NULL,
    capacity INT NOT NULL,
    status ENUM('Operational', 'Out of Service', 'Under Maintenance') DEFAULT 'Operational'
);

-- Step 7: Create the Routes Table
CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    route_name VARCHAR(255) NOT NULL,
    start_location VARCHAR(255) NOT NULL,
    end_location VARCHAR(255) NOT NULL
);

-- Step 8: Create the Assignments Table (Assign vehicles to routes)
CREATE TABLE assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    route_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE
);

-- Step 9: Create the Vehicle Status Table (Tracking vehicle status)
CREATE TABLE vehicle_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    status ENUM('Operational', 'On Break', 'Out of Service', 'Under Maintenance', 'Emergency') NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE
);

-- Step 10: Create the GPS Tracking Table (Track vehicle location)
CREATE TABLE gps_tracking (
    gps_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    route_id INT NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE
);

-- Step 11: Create the Maintenance Table (Maintenance records for vehicles)
CREATE TABLE maintenance (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    maintenance_date DATE NOT NULL,
    cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    details TEXT NOT NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE
);

-- Step 12: Create the Reports Table (Reports for performance, cost, etc.)
CREATE TABLE reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    report_title VARCHAR(255) NOT NULL,
    report_data JSON NOT NULL,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 13: Create Indexes for frequently queried columns
CREATE INDEX idx_vehicle_id ON vehicle_status(vehicle_id);
CREATE INDEX idx_route_id ON gps_tracking(route_id);
CREATE INDEX idx_operator_id ON assignments(route_id);

-- Step 14: Role-based Access Control (Granting permissions based on roles)
SELECT user, host FROM mysql.user;
-- Create Manager User (Full Access)
CREATE USER 'manager'@'localhost' IDENTIFIED BY 'manager';

-- Create Operator User (Limited Access)
CREATE USER 'operator'@'localhost' IDENTIFIED BY 'operator';

-- Admin role (Full access)
GRANT ALL PRIVILEGES ON ptfms.* TO 'manager'@'localhost';

-- Operator role (Limited access to vehicle status only)
GRANT SELECT, UPDATE ON ptfms.vehicle_status TO 'operator'@'localhost';
SHOW GRANTS FOR 'manager'@'localhost';
SHOW GRANTS FOR 'operator'@'localhost';

SHOW GRANTS FOR 'operator'@'localhost';


-- Step 15: Flush privileges to apply changes
FLUSH PRIVILEGES;

drop database ptfms;

