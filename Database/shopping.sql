DROP TABLE IF EXISTS product;

CREATE TABLE product (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sku VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    weight_kg DECIMAL(6,3),
    quantity INT NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE
);

INSERT INTO product (name, sku, description, category, price, weight_kg, quantity, active) VALUES
('Apple', 'FRU-0001', 'Fresh red apples', 'Fruit', 0.50, 0.150, 100, TRUE),
('Banana', 'FRU-0002', 'Ripe bananas', 'Fruit', 0.30, 0.120, 150, TRUE),
('Orange', 'FRU-0003', 'Juicy oranges', 'Fruit', 0.80, 0.200, 200, TRUE),
('Milk', 'DRY-0001', 'Whole milk 1L', 'Dairy', 1.20, 1.000, 50, TRUE),
('Bread', 'BAK-0001', 'Sliced white bread', 'Bakery', 1.00, 0.500, 75, TRUE),
('Eggs', 'DRY-0002', 'Carton of 12 eggs', 'Dairy', 2.50, 0.600, 40, TRUE),
('Cheese', 'DRY-0003', 'Cheddar 200g', 'Dairy', 3.80, 0.200, 30, TRUE),
('Chicken Breast', 'PRO-0001', 'Boneless chicken breast 500g', 'Protein', 5.50, 0.500, 25, TRUE),
('Rice', 'PAN-0001', 'Long grain rice 1kg', 'Pantry', 2.20, 1.000, 60, TRUE),
('Pasta', 'PAN-0002', 'Spaghetti 500g', 'Pantry', 1.40, 0.500, 80, TRUE),
('Cereal', 'PAN-0003', 'Breakfast cereal 375g', 'Pantry', 3.00, 0.375, 35, TRUE),
('Yogurt', 'DRY-0004', 'Greek yogurt 150g', 'Dairy', 0.90, 0.150, 120, TRUE);

SElECT price, COUNT(price) AS product_count
from product
group by price;