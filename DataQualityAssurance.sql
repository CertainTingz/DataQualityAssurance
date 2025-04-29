/*              ~~~~~~~~~~ DATA QUALITY ASSURANCE ~~~~~~~~~~
                                 using
                    DATA STANDARD QUALITY DIMENSION FRAMEWORK      
               ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     
*/


-- Selecting the first 10 records so that I can have a clear picture of how
-- the data looks like.
SELECT *
FROM PropertyDB
FETCH FIRST 10 ROWS ONLY;

-- There is also need to check the data structure of this tasssble 
-- and see the data types we are dealing with.
DESCRIBE PropertyDB;

-- Populate the Property Address Data (Feature Engineering)
-- I will check how many of the Property Address has missing values,
-- and we get 18 record.
SELECT count (*)
FROM PropertyDB
WHERE propertyaddress is NULL;

-- I now need to find a way to populate the missing values 
-- rather than drop the rows.
-- Rows with the same ParcelID have the Property Address
-- and we can use this observation to replace the missing fields
SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
FROM PropertyDB a
JOIN PropertyDB b 
ON a.parcelid = b.parcelid
AND a.unid != b.unid
WHERE a.propertyaddress is null;

-- After visualising that, now we need to replace the null.
-- Using the NVL() function, we can substitute a null values with a 
-- corresponding value.
SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, 
NVL(a.propertyaddress, b.propertyaddress) newPropertyAddress
FROM PropertyDB a
JOIN PropertyDB b 
ON a.parcelid = b.parcelid
AND a.unid != b.unid
WHERE a.propertyaddress is null;

-- Updating the Property Address field with missing values
UPDATE PropertyDB a
SET a.propertyaddress = (
    SELECT b.propertyaddress
    FROM PropertyDB b
    WHERE a.parcelid = b.parcelid
      AND a.unid != b.unid
      AND b.propertyaddress IS NOT NULL
    FETCH FIRST 1 ROWS ONLY
)WHERE a.propertyaddress IS NULL;

-- I will separate the address in parts. Address, Town, City etc
SELECT *
FROM PropertyDB
--WHERE propertyaddress is NULL;













