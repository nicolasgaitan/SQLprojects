delete from lcdaging;

load data local infile 'C://Users/nicolas.g/Desktop/SQL/Format/inventory/lcdaging.csv'			
into table lcdaging
CHARACTER SET latin1   
fields terminated by ','
lines terminated by '\r\n'
ignore 1 rows;
 
SET @@SESSION.sql_mode='NO_ZERO_DATE,NO_ZERO_IN_DATE';
UPDATE LCDaging SET `Purch Date` = str_to_date(`Purch Date` , " %m/%d/%Y "); 	-- THIS CHANGES DATE TO SQL DATE.NEEDED OR SQL SEES DATE AS STANDARD TEXT;
Alter table LCDaging MODIFY COLUMN `Purch Date` DATE;

UPDATE lcdaging 				-- FINDS AND SETS THE MEMO
set `group` = 'Memo'
	where `Lot Status` = 'memo';
    
UPDATE lcdaging 				-- FIND AND SETS THE PACK
set `group` = 'Pack'
	where `Lot Status` = 'pack';
    
UPDATE lcdaging 				-- FIND AND SETS FANCY
set `group` = 'Fancy'
	where 
		Color <>  'D' 
	and Color  <> 'E' 
	and Color <> 'F' 
	and Color <> 'G' 
	and Color <> 'H' 
	and Color <> 'I' 
	and Color <> 'J'  
	and Color <> 'K' 
	and Color <> 'M' 
	and Color <> 'W-X' 
	and Color <> 'Y-Z' 
	and `Group` IS NULL ;
    
UPDATE LCDaging				-- ADDS WEIGHT USING THE sizerangetable AND ADDS IT TO SIZE RANGE COLUMN
left join sizerangetable
on LCDaging.weight = sizerangetable.cert
set LCDaging.`size range` = sizerangetable.Size;

UPDATE lcdaging				-- FINDS AND SETS THE KZP
SET `Group` = 'KZP'
Where 
   (color = 'D'
or color = 'E'
or color = 'F')
and (clarity <> 'I1'
and clarity <> 'I2')
and (`size range` = .75
or `size range` = .9
or `size range` = 1
or `size range` = 1.5
or `size range` = 2
or `size range` = 2.5
or `size range` = 3
or `size range` = 4
or `size range` = 5 )
and `Group` is NULL;
					
UPDATE LCDaging				-- EVERYTHING THAT HAS NOT BEEN ASSIGNED A VALUE GETS SET TO NON KZP
set `Group` = 'Non KZP'
	where `Group` is NULL;
    
Update LCDaging				-- SETS THE DATE GROUP BY SUBTRACTING THE FILE DATE AND PURCH TOGETHER
set `Date Group` = CASE
    When datediff('2022-04-30', `Purch date`) Between 0 and 30 THEN '0-30'
	When datediff('2022-04-30', `Purch date`) between 31 and 90 THEN '31-90'
    When datediff('2022-04-30', `Purch date`) between 91 and 180 THEN '91-180'
    When datediff('2022-04-30', `Purch date`) between 181 and 365 THEN '181-365'
    When datediff('2022-04-30', `Purch date`) between 366 and 548 THEN '1-1.5Yr'
    When datediff('2022-04-30', `Purch date`) between 549 and 730 THEN '1.5-2yr'
    When datediff('2022-04-30', `Purch date`) > 730 THEN '2yr+'
    ELSE 'error'
	END;
    
select 					-- THE ENTIRE FILE COMPLETELY FORMATTED
	lotID,
    `Lot Name`,
    `Serie ID`,
    QTY,
    Size,
    Weight,
    Lab,
    Certificate,
    Shape,
    Color,
    Clarity,
    `Lot Status`,
    Location,
    `Cost Total`,
    `Purch Date`,
	`Vendor Name`,
    `Doc Date`,
	`Date Group`,
    `Group`,
    `Size range`
From LCDaging;

Alter table LCDaging MOdify COLUMN `Purch Date` TEXT			-- CHANGES DATE BACK TO TEXT SO NO ISSUES OCCUR WHEN UPLOADING ANOTHER FILE;
								       
								       
								       
								       -- THIS COMPLIES THE LIST OF ALL THE SUMMARIES 
Select ' ' , 'Fancy', '' 
UNION
Select  * from(
SELECT
	`date group`,
	Count(*) as Units,
    round(SUM(`Cost Total`),2) as `Inventory Cost`
FROM LCDaging 
where `Group` = 'Fancy'
Group by `date group`
ORDER BY min(`Purch date`) DESC ) as t                                  -- THIS IS SO THE SUMMARY TABLE HAS THE GROUP DATES IN ORDER AS THERES NO WAY TO ORDER '0-30' FOR EXAMPLE
UNION
Select 'TOTALS' , count(*), round(sum(`Cost Total`),2) From LCDaging where `Group` = 'Fancy' Group by `group`
UNION
Select ' ' , ' ', ''
UNION
Select ' ' , 'Memo', '' 
UNION
Select  * from(
SELECT
	`date group`,
	Count(*) as Units,
    round(SUM(`Cost Total`),2) as `Inventory Cost`
FROM LCDaging 
where `Group` = 'Memo'
Group by `date group`
ORDER BY min(`Purch date`) desc) as t
UNION
Select 'TOTALS' , count(*), round(sum(`Cost Total`),2) From LCDaging where `Group` = 'memo' Group by `group`
UNION
Select '   ' , '    ', '    ' 
UNION
Select ' ' , 'Pack', '' 
UNION
Select  * from(
SELECT
	`date group`,
	Count(*) as Units,
    round(SUM(`Cost Total`),2) as `Inventory Cost`
FROM LCDaging 
where `Group` = 'Pack'
Group by `date group`
ORDER BY min(`Purch date`) desc) as t
UNION
Select 'TOTALS' , count(*), round(sum(`Cost Total`),2) From LCDaging where `Group` = 'Pack' Group by `group`
UNION
Select '   ' , '    ', '     ' 
UNION
Select ' ' , 'KZP size Range', '' 
UNION
Select  * from(
SELECT
	`date group`,
	Count(*) as Units,
    round(SUM(`Cost Total`),2) as `Inventory Cost`
FROM LCDaging 
where `Group` = 'KZP'
Group by `date group`
ORDER BY min(`Purch date`) desc) as t
UNION
Select 'TOTALS' , count(*), round(sum(`Cost Total`),2) From LCDaging where `Group` = 'KZP' Group by `group`
UNION
Select '            ' , ' ', '' 
UNION
Select ' ' , 'No KZP Sizes', '' 
UNION
Select  * from(
SELECT
	`date group`,
	Count(*) as Units,
    round(SUM(`Cost Total`),2) as `Inventory Cost`
FROM LCDaging 
where `Group` = 'Non KZP'
Group by `date group`
ORDER BY min(`Purch date`) desc) as t
UNION
Select 'TOTALS' , count(*), round(sum(`Cost Total`),2) From LCDaging where `Group` = 'Non KZP' Group by `group`
UNION
Select '               ' , ' ', '' 
UNION
Select ' ' , 'GRAND TOTALS', '' 
UNION
Select  * from(
SELECT
	`date group`,
	Count(*) as Units,
    round(SUM(`Cost Total`),2) as `Inventory Cost`
FROM LCDaging 
Group by `date group`
ORDER BY min(`Purch date`) desc) as t
UNION
Select 'TOTALS' , count(*), round(sum(`Cost Total`),2)  From LCDaging
;
select * from LCDaging where `date group` = 'error'
