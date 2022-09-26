delete from DSI;
delete from JAG_full;
Delete from JAG_signet;
DELETE FROM PARCEL;

load data local infile 'C://Users/nicolas.g/Desktop/SQL/Format/inventory/Lcdaging.csv'			
into table DSI
CHARACTER SET latin1   
fields terminated by ','
lines terminated by '\r\n'
ignore 1 rows;
load data local infile 'C://Users/nicolas.g/Desktop/SQL/Format/inventory/parcel.csv'			
into table Parcel
CHARACTER SET latin1   
fields terminated by ','
lines terminated by '\r\n'
ignore 1 rows;


UPDATE DSI				-- ADDS WEIGHT USING THE sizerangetable AND ADDS IT TO SIZE RANGE COLUMN
left join sizerangetable
on DSI.weight = sizerangetable.cert
set DSI.`size range` = sizerangetable.Size
WHERE DSI.SHAPE NOT LIKE '%BR%'
AND WEIGHT NOT BETWEEN .7 AND .71
AND WEIGHT NOT BETWEEN .8 AND .89 
AND WEIGHT NOT BETWEEN .95 AND .99;

UPDATE DSI				-- ADDS WEIGHT USING THE sizerangetable AND ADDS IT TO SIZE RANGE COLUMN
left join sizerangetable
on DSI.weight = sizerangetable.cert
set DSI.`size range` = '.7 -.71'
WHERE DSI.SHAPE= 'BR'
AND DSI.WEIGHT BETWEEN .7 AND .71;

UPDATE DSI				-- ADDS WEIGHT USING THE sizerangetable AND ADDS IT TO SIZE RANGE COLUMN
left join sizerangetable
on DSI.weight = sizerangetable.cert
set DSI.`size range` = '.8-.89'
WHERE DSI.SHAPE= 'BR'
AND DSI.WEIGHT BETWEEN .8 AND .89;

UPDATE DSI				-- ADDS WEIGHT USING THE sizerangetable AND ADDS IT TO SIZE RANGE COLUMN
left join sizerangetable
on DSI.weight = sizerangetable.cert
set DSI.`size range` = '.95 - .99'
WHERE DSI.SHAPE= 'BR'
AND DSI.WEIGHT BETWEEN .95 AND .99;

UPDATE DSI				-- ADDS WEIGHT USING THE sizerangetable AND ADDS IT TO SIZE RANGE COLUMN
left join sizerangetable
on DSI.weight = sizerangetable.cert
set DSI.`size range` = sizerangetable.Size
WHERE DSI.`SIZE RANGE` IS NULL;


Select * from DSI 			-- NOT IN DEMAND TABLE
	where 
		Color <>  'D' 
	and Color  <> 'E' 
	and Color <> 'F' 
	and Color <> 'G' 
	and Color <> 'H' 
	and Color <> 'I' ;
        
insert into JAG_FULL  (Select * from DSI 
	where 
		(Color =  'D' 
	or Color  = 'E' 
	or Color = 'F' 
	or Color = 'G' 
	or Color = 'H' 
	or Color = 'I') 
    and clarity <> 'I1'
    and clarity <> 'I2'
    and shape <> 'AS'
    and shape <> 'TR'
    and location not like '%LTD%'
    and location not like '%inc%'
	and location not like '%harout%' 
    and location not like '%Ram%' 
    and location not like '%signet%' 
    and location not like '%terra%' 
    and location not like '%WF%' );
    
    
insert into JAG_Signet (Select * from jag_full
where 
	(color = 'D' 
    or color = 'E'
    or color = 'F')
    and location <> 'JA'
    and shape <> 'TR')    ;
    

Delete from parcel where shape = 'AR' or shape = 'TR' or shape like '%bag%';  -- VALUES NOT NEEDED FOR THE REPORT

Update parcel
set `Weight bucket` = concat('.',mid(`Lot Name`,14,2))
where `Lot Name` like '%RTN-DUB%';

Update parcel
set `Weight bucket` = concat('.',mid(`Lot Name`,10,2))
where 
	(`Lot Name` like '%RTN%' and `lot Name` not Like '%DUB%') 
    or (`Lot Name` not like '%RTN%' and `lot Name` Like '%DUB%');
    
Update parcel
set `weight bucket` = '100.23'
where shape like '%bag%';

Update Parcel
set `Weight bucket` = concat('.',mid(`Lot Name`,6,2))
where `Weight bucket` is NULL;

UPDATE parcel
set type = right(`Lot name`,2);

Update parcel
set `Weight Bucket` = '.63'
where `Weight Bucket` = '.6' and (type ='T1' or type = 'T2');

Update parcel
set `Weight Bucket` = '.75'
where `Weight Bucket` = '.7' and (type ='T1' or type = 'T2');
										--SUMMARY OF THE INVENTORY GROUPED BY SHAPE AND SIZE
										-- USE COALESCE BECAUSE NULL MEANS 0 
									
select A.shape, A.size, coalesce(D.ParcelsQ,0) as `Parcels Inventory`, coalesce(B.quantity1,0) as `Jag Full`, coalesce(C.quantity2,0) as `Jag Signet` from overview A
left join (select shape, `size range`,count(*) as Quantity1 from jag_full group by shape, `Size range`) B
on A.shape = B.shape and A.size = B.`size range` 
left join (select shape, `size range`,count(*) as Quantity2 from jag_signet group by shape, `Size range`) C
on A.shape = C.shape and A.size = C.`size range`
Left Join (select shape,`weight bucket`,sum(qty) as ParcelsQ from parcel where `weight bucket` >= .2  and (location = 'NY DEPT.' or location like '%Lumex%') and (type ='T1' or type = 'T2') group by shape,`weight bucket`) D
on A.shape = D.shape and A.size = D.`weight bucket` 
group by A.shape,A.size;

SELECT * FROM JAG_FULL;
SELECT * FROM JAG_SIGNET

