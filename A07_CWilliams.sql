--*************************************************************************--
-- Title: assignment07
-- Author: CWilliams
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2025-05-30,CWilliams,Created File
-- 2025-06-03,CWIlliams, Created KPI View
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'assignment07DB_CWilliams')
	 Begin 
	  Alter Database [assignment07DB_CWilliams] set Single_user With Rollback Immediate;
	  Drop Database assignment07DB_CWilliams;
	 End
	Create Database assignment07DB_CWilliams;
End Try
Begin Catch
	Print Error_Number();
End Catch
Go
Use assignment07DB_CWilliams;

-- Create Tables (Module 01)-- 
Create Table CateGories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
Go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
Go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
Go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
Go

-- Add Constraints (Module 02) -- 
Begin  -- CateGories
	Alter Table CateGories 
	 Add Constraint pkCateGories 
	  Primary Key (CategoryId);

	Alter Table CateGories 
	 Add Constraint ukCateGories 
	  Unique (CategoryName);
End
Go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCateGories 
	  Foreign Key (CategoryId) References CateGories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
Go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
Go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
Go

-- Adding Data (Module 04) -- 
Insert Into CateGories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.CateGories
 Order By CategoryID;
Go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
Go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
Go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to Create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to Create a made up value
From Northwind.dbo.Products
Order By 1, 2
Go


-- Adding Views (Module 06) -- 
Create View vCateGories With SchemaBinding
 as
  Select CategoryID, CategoryName From dbo.CateGories;
Go
Create View vProducts With SchemaBinding
 as
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
Go
Create View vEmployees With SchemaBinding
 as
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
Go
Create View vInventories With SchemaBinding 
 as
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
Go

-- Show the Current data in the CateGories, Products, and Inventories Tables
Select * From vCateGories;
Go
Select * From vProducts;
Go
Select * From vEmployees;
Go
Select * From vInventories;
Go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BasIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to Format the price as US dollars.
-- Order the result by the product name.

--This function is used to Format the UnitPrice into US Dollars.
Select ProductName,
Format(p.UnitPrice, 'C', 'en-us') as UnitPriceinDollars
FROM vproducts as p
Order by ProductName
Go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to Format the price as US dollars.
-- Order the result by the Category and Product.

Select 
c.CategoryName,
p.ProductName,
Format(p.UnitPrice, 'C', 'en-us') as UnitPriceinDollars
FROM vproducts as p
JOIN vcateGories as c
ON p.CategoryID = c.CategoryID
Order by c.CategoryID, p.ProductName
Go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Select
p.ProductName,
Format(i.InventoryDate,'MMMM'+','+' '+'yyyy') as InventoryDate, --Formats the Inventory date to Month,Year.
i.Count
FROM vproducts as p
JOIN vinventories as i
ON p.ProductID = i.ProductID
Order by p.ProductName, i.InventoryDate
Go

-- Question 4 (10% of pts): 
-- Create A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Create --drop
View vProductInventories
as
	Select TOP 1000000   --required to order by in a view.
	p.ProductName,
	Format(i.InventoryDate,'MMMM'+','+' '+'yyyy') as InventoryDate, --Formats the Inventory date to Month,Year.
	i.Count
	FROM vInventories as i
	Join vProducts as p
	ON i.ProductID = p.ProductID
	ORDER BY p.ProductName,i.InventoryDate
	Go
	
-- Check that it works:
Select * from vProductInventories
Go

-- Question 5 (10% of pts): 
-- Create A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY Category
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Create --drop
View vCategoryInventories
as
	Select TOP 1000000   --required to order by in a view.
	c.CategoryName,
	Format(i.InventoryDate,'MMMM'+','+' '+'yyyy') as InventoryDate, --Formats the Inventory date to Month,Year.
	SUM(i.Count) as InventoryCountbyCategory  --Aggregate function to count inventory by Category
	FROM vInventories as i
	Join vProducts as p
	ON i.ProductID = p.ProductID
	Join CateGories as c
	ON p.CategoryID = c.CategoryID
	GROUP BY c.CategoryName,i.InventoryDate
	ORDER BY c.CategoryName,i.InventoryDate
	Go

-- Check that it works:
Select * From vCategoryInventories;
Go

-- Question 6 (10% of pts): 
-- Create ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

Go
Create --drop
View vProductInventoriesWithPreviousMonthCounts
as
	Select
	ProductName, InventoryDate,
	Case
		When Month(InventoryDate) = 1
		THEN ISNULL(Count, 0)
		Else Count
	End as InventoryCount,
	PreviousMonthCount = IsNull( Lag(Sum(Count)) Over (Partition by ProductName Order By Month(InventoryDate)), 0)
	From vProductInventories
	Group By ProductName, InventoryDate,Count
	Go

-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCounts
Go

-- Question 7 (15% of pts): 
-- Create a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.


Create --drop
View vProductInventoriesWithPreviousMonthCountsWithKPIs
as
	Select
	ProductName, 
	InventoryDate,
	InventoryCount,
	PreviousMonthCount,
	Case
		When InventoryCount > PreviousMonthCount Then 1
		When InventoryCount = PreviousMonthCount Then 0
		When InventoryCount < PreviousMonthCount Then -1
	End As InventoryDelta
	From vProductInventoriesWithPreviousMonthCounts
	Go

-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Go

-- Question 8 (25% of pts): 
-- Create a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Verify that the results are ordered by the Product and Date.

--This function is a function I created to calculate the delta from the previous month's inventory count.
--If there is an increase in inventory, then Delta is 1, for a decrease the Delta is -1 and for no change, 0.
Create Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@InventoryDelta int)
 Returns table 
 As
 Return (Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount,
	InventoryDelta = Case
		When InventoryCount > PreviousMonthCount Then 1
		When InventoryCount = PreviousMonthCount Then 0
		When InventoryCount < PreviousMonthCount Then -1
	End
	From dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where InventoryDelta = @InventoryDelta )
Go		
--Check that it works:
Select * From dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);

Go

--Done!
/***************************************************************************************/