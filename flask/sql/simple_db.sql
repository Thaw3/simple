--THIS IS SQL FILE--
-- create table autonomous mobile robots price calulation examples.--
CREATE TABLE autonomous_mobile_robots (
    id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    battery_life INT NOT NULL,
    payload_capacity INT NOT NULL
);
INSERT INTO autonomous_mobile_robots (model_name, price, battery_life, payload_capacity) VALUES
('AMR Model A', 15000.00, 120, 500),
('AMR Model B', 20000.00, 180, 800),
('AMR Model C', 25000.00, 240, 1000),
('AMR Model D', 30000.00, 300, 1500);