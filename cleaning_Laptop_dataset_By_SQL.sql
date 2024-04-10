# Create a database name laptop_dataset
-- create database laptop_dataset;

# Take overview of uncleaned dataset
use laptop_dataset;
select * from laptops;

# Create Backup dataset before cleaning
-- create table laptops_backup like laptops;
-- insert into laptops_backup (select * from laptops);

# Read uncleaned dataset
select * from laptops;

# Memory occupancy of the table
select DATA_LENGTH/1024 as size_in_KB from information_schema.TABLES
WHERE TABLE_SCHEMA = 'laptop_dataset'
AND TABLE_NAME = "laptops";

select * from laptops;

# Drop unneeccary column 
ALTER TABLE laptops DROP COLUMN `Unnamed: 0`;

# Add additional column named index_value 
ALTER TABLE laptops
ADD COLUMN index_value INT AUTO_INCREMENT PRIMARY KEY;

# Drop the rows having NULL values
DELETE FROM laptops where index_value IN
(SELECT index_value FROM laptops
WHERE Company ='' and TypeName ='' and  Inches =0
AND ScreenResolution ='' AND Cpu ='' AND Ram =''
AND Memory ='' AND Gpu ='' AND OpSys ='' AND
WEIGHT ='' AND Price =0);

# delete the duplicated values
DELETE from laptops where index_value not in
(select min(index_value) from laptops
group by Company,TypeName, Inches,ScreenResolution, Cpu, Ram,
       Memory, Gpu, OpSys, Weight,Price);

# correct the datatype of columns->Inches	
ALTER TABLE laptops MODIFY COLUMN Inches DECIMAL(10,1);

# Working on "RAM" Column

## Removing GB in each value From Ram 
UPDATE laptops
SET Ram = REPLACE(Ram, 'GB', '');

## Change its datatype
ALTER TABLE laptops MODIFY COLUMN Ram INTEGER;

# Working on Weight column

## Remove "kg" from its value
UPDATE laptops
SET Weight=REPLACE(Weight,"kg","");

## Change its DataType
ALTER TABLE laptops MODIFY COLUMN Weight DECIMAL(10,2);

# Working on "Price" Column

## Rounding off the value
UPDATE laptops
set Price=round(Price);

## Change DataTyepe to Integer
ALTER TABLE laptops MODIFY COLUMN Price INTEGER;

# Working on Operating System (OpSys)

## Categorise the OpSys 
UPDATE laptops
set OpSys=CASE
				WHEN OpSys LIKE "%mac%" THEN 'macos'
				WHEN OpSys LIKE '%window%' THEN 'windows'
				WHEN OpSys LIKE 'linux' THEN 'linux'
				WHEN OpSys = 'No OS' THEN 'N/A'
				ELSE 'other'
			END;

SELECT DISTINCT OpSys from laptops; 

# Working on Gpu

## Create Two Columns from "Gpu" 
ALTER TABLE laptops 
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

## fill gpu_brand 
UPDATE laptops SET gpu_brand=SUBSTRING_INDEX(Gpu,' ',1);

## fill gpu_name 
UPDATE laptops SET gpu_name=REPLACE(Gpu,gpu_brand,'');

## Now Drop 'Gpu' Column
ALTER TABLE laptops DROP COLUMN Gpu;

# Working on Cpu

## Create Three Columns from "Cpu" 
ALTER TABLE laptops 
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_brand;

## fill cpu_brand 
UPDATE laptops SET cpu_brand=SUBSTRING_INDEX(Cpu,' ',1);

## fill cpu_name 
UPDATE laptops SET cpu_name=REPLACE(SUBSTRING_INDEX(Cpu,' ',3),cpu_brand,'');

## Fill cpu speed
UPDATE laptops SET cpu_speed=CAST(REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz','') AS DECIMAL(10,1));

## Now drop 'Cpu' column
ALTER TABLE laptops DROP COLUMN Cpu;

# Working on ScreenResolution

## Create two other columns (resolution_width, resolution_height) from it 
ALTER TABLE laptops
ADD COLUMN resolution_width INTEGER AFTER  ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER  resolution_width;

## Extract and UPDATE "resolution_width"
UPDATE laptops
SET resolution_width =SUBSTRING_INDEX(SUBSTRING_INDEX( ScreenResolution,' ',-1),'x',1);

## EXTRACT and UPDATE "resolution_height"
UPDATE laptops
SET resolution_height =  SUBSTRING_INDEX(SUBSTRING_INDEX( ScreenResolution,' ',-1),'x',-1);

## Add and update another column naming "touch_screen" for whether it is touch_screen or not
ALTER TABLE laptops
ADD COLUMN touchscreen INTEGER AFTER resolution_height;

UPDATE laptops
SET touchscreen = ScreenResolution LIKE "%Touch%";

## Now drop the "ScreenResolution" column
ALTER TABLE laptops DROP COLUMN ScreenResolution;

# Work on "Memory"

## Add three other columns (memory_type,primary_storage,secondary_storage)
ALTER TABLE laptops 
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

## Update memory_type
UPDATE laptops
SET memory_type = CASE
					WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
					WHEN Memory LIKE '%SSD%' THEN 'SSD'
					WHEN Memory LIKE '%HDD%' THEN 'HDD'
					WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
					WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
					WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
					ELSE NULL
				END;

## Update 'primary_type' column
UPDATE laptops
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;

# Convert 1TB and 2TB into GB in primary and secondary storage
UPDATE laptops
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;

## Now Drop memory
ALTER TABLE laptops DROP COLUMN Memory;

#Drop "gpu_name" as it seems irrelavant
ALTER TABLE laptops DROP COLUMN gpu_name;

# Finnaly a cleaned data
select * from laptops;

