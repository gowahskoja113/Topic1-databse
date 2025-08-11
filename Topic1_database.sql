IF DB_ID('sms') IS NULL CREATE DATABASE sms;
GO 
USE sms;
GO

IF OBJECT_ID('dbo.Customer') IS NOT NULL DROP TABLE dbo.Customer;
IF OBJECT_ID('dbo.Employee') IS NOT NULL DROP TABLE dbo.Employee;
IF OBJECT_ID('dbo.Product')  IS NOT NULL DROP TABLE dbo.Product;
IF OBJECT_ID('dbo.Orders')   IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.LineItem') IS NOT NULL DROP TABLE dbo.LineItem;

CREATE TABLE dbo.Customer (
  customer_id   INT IDENTITY(1,1) PRIMARY KEY,
  customer_name NVARCHAR(255) NOT NULL
);

CREATE TABLE dbo.Employee (
  employee_id   INT IDENTITY(1,1) PRIMARY KEY,
  employee_name NVARCHAR(255) NOT NULL,
  salary        DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.Product (
  product_id   INT IDENTITY(1,1) PRIMARY KEY,
  product_name NVARCHAR(255) NOT NULL,
  list_price   DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.Orders (
  order_id    INT IDENTITY(1,1) PRIMARY KEY,
  order_date  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
  customer_id INT NOT NULL,
  employee_id INT NOT NULL,
  total       DECIMAL(10,2) NULL
);

CREATE TABLE dbo.LineItem (
  order_id   INT NOT NULL,
  product_id INT NOT NULL,
  quantity   INT NOT NULL,
  price      DECIMAL(10,2) NOT NULL
);

INSERT INTO dbo.Customer(customer_name) 
VALUES (N'Son'),(N'Tuan'),(N'Nguyễn Văn A'),(N'Trần Thị B'),(N'Lê Hoàng C');

INSERT INTO dbo.Employee(employee_name,salary) 
VALUES (N'Hung',5000),(N'Quynh',6000),(N'Phạm Văn Dũng', 7000),(N'Ngô Thị Hoa', 5500);

INSERT INTO dbo.Product(product_name,list_price) 
VALUES (N'Laptop',1200),(N'Smart Phone',800), (N'Máy tính bảng', 900),(N'Tai nghe', 150),(N'Đồng hồ thông minh', 300);

INSERT INTO dbo.Orders(order_date, customer_id, employee_id, total)
VALUES (SYSDATETIME(), 1, 1, 0), (SYSDATETIME(), 2, 2, 0), (SYSDATETIME(), 3, 1, 0);

INSERT INTO dbo.LineItem(order_id, product_id, quantity, price)
VALUES (1, 1, 1, 1200), (2, 2, 2, 1600), (2, 3, 1, 900), (3, 4, 3, 450);  

--Q1
SELECT DISTINCT c.customer_id, c.customer_name
FROM dbo.Customer c
JOIN dbo.Orders o ON o.customer_id = c.customer_id;

--Q2
DECLARE @customer_id INT = 1;
SELECT o.order_id, o.order_date, o.customer_id, o.employee_id, o.total
FROM dbo.Orders o 
WHERE o.customer_id = @customer_id;

--Q3 
DECLARE @order_id INT = 1;
SELECT l.order_id, l.product_id, l.quantity, l.price
FROM dbo.LineItem l
WHERE l.order_id = @order_id;

--Q4 tinh order total 
CREATE OR ALTER FUNCTION dbo.GetOrderTotal (@order_id INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
  DECLARE @total DECIMAL(10,2);
  SELECT @total = SUM(quantity * price)
  FROM dbo.LineItem
  WHERE order_id = @order_id;
  RETURN ISNULL(@total, 0);
END;
GO

SELECT dbo.GetOrderTotal(1) AS total_order_1;

--Q5 addcustomer
CREATE OR ALTER PROCEDURE dbo.AddCustomer
	@name NVARCHAR(255)
AS
BEGIN
	INSERT INTO dbo.Customer(customer_name) 
	VALUES (@name);
END;
GO

EXEC dbo.AddCustomer N'Hoang Anh';

--Q6 delete
CREATE OR ALTER PROCEDURE dbo.DeleteCustomer
	@id INT
AS
BEGIN
	DELETE l
	FROM dbo.LineItem l
	WHERE l.order_id IN (
		SELECT o.order_id
		FROM dbo.Orders o
		WHERE o.customer_id = @id
	);
	DELETE FROM dbo.Orders 
	WHERE customer_id = @id;

	DELETE FROM dbo.Customer 
	WHERE customer_id = @id;
END;
GO

EXEC dbo.DeleteCustomer 5;

--Q7 update 
CREATE OR ALTER PROCEDURE dbo.UpdateCustomer
	@id INT, @name NVARCHAR(255)
AS
BEGIN
	UPDATE dbo.Customer 
	SET customer_name = @name 
	WHERE customer_id = @id;
END
GO

EXEC dbo.UpdateCustomer 3 , N'Anh Tu';

--Q8 tao moi order
CREATE OR ALTER PROCEDURE dbo.CreateOrder 
	@customer_id INT, @employee_id INT
AS
BEGIN
	INSERT INTO dbo.Orders(order_date, customer_id, employee_id, total)
	VALUE (SYSDATETIME(), @customer_id, @employee_id, 0);
END; 
GO

--Q9 tao moi line item 
CREATE OR ALTER PROCEDURE dbo.CreateLineItem
	@order_id INT, @product_id INT, @quantity INT, @price DECIMAL(10,2)
AS
BEGIN
	INSERT INTO dbo.LineItem(order_id, product_id, quantity, price)
	VALUE (@order_id, @product_id, @quantity, @price);
END; 
GO

--10 update an order total
Create OR Alter procedure dbo.UpdateOrderTotal
	@order_id INT
AS
BEGIN
	UPDATE dbo.Orders
	SET total = dbo.GetOrderTotal(@order_id)
	WHERE order_id = @order_id;
END;
GO