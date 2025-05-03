/*              ~~~~~~~~~~ DATA QUALITY ASSURANCE ~~~~~~~~~~
                                 using
                    DATA STANDARD QUALITY DIMENSION FRAMEWORK      
               ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     
*/


-- Selecting the first 10 records so that I can have a clear picture of how
-- the data looks like.
SELECT *
FROM PropertyData
FETCH FIRST 10 ROWS ONLY;

-- There is also need to check the data structure of this tasssble 
-- and see the data types we are dealing with.
DESCRIBE PropertyData;

-- Populate the Property Address Data (Feature Engineering)
-- I will check how many of the Property Address has missing values,
-- and we get 18 record.
SELECT count (*)
FROM PropertyData
WHERE propertyaddress is NULL;

-- I now need to find a way to populate the missing values 
-- rather than drop the rows.
-- Rows with the same ParcelID have the Property Address
-- and we can use this observation to replace the missing fields
SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
FROM PropertyData a
JOIN PropertyData b 
    ON a.parcelid = b.parcelid
    AND a.uniqueID != b.uniqueID
WHERE a.propertyaddress is null;

-- After visualising that, now we need to replace the null.
-- Using the NVL() function, we can substitute a null values with a 
-- corresponding value.
SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, 
NVL(a.propertyaddress, b.propertyaddress) newPropertyAddress
FROM PropertyData a
JOIN PropertyData b 
    ON a.parcelid = b.parcelid
    AND a.uniqueID != b.uniqueID
WHERE a.propertyaddress is null;

-- Updating the Property Address field with missing values
UPDATE PropertyData a
SET a.propertyaddress = (
    SELECT b.propertyaddress
    FROM PropertyData b
    WHERE a.parcelid = b.parcelid
      AND a.uniqueID != b.uniqueID
      AND b.propertyaddress IS NOT NULL
    FETCH FIRST 1 ROWS ONLY)
WHERE a.propertyaddress IS NULL;

-- I will separate the address in parts. Address, Town etc.
-- I will use ',' as the character to separate the two and TRIM off the spaces off the fields
SELECT 
    TRIM(SUBSTR(propertyaddress, 1, INSTR(propertyaddress, ',') - 1)) AS AddressSplit,
    TRIM(SUBSTR(propertyaddress, INSTR(propertyaddress, ',') + 1)) AS TownSplit
FROM PropertyData;

-- Creating the fields to house the new data.
-- Using ALTER and the UPDATE statement.
ALTER TABLE propertydata
ADD AddressSplit VARCHAR2(35);
UPDATE propertydata
SET AddressSplit = TRIM(SUBSTR(propertyaddress, 1, INSTR(propertyaddress, ',') - 1));

ALTER TABLE propertydata
ADD TownSplit VARCHAR2(35);
UPDATE propertydata
SET TownSplit = TRIM(SUBSTR(propertyaddress, INSTR(propertyaddress, ',') + 1));

-- Now to do the same for the Owner Address using the RegEx fuctions
SELECT 
    REGEXP_SUBSTR(owneraddress, '[^,]+', 1, 1) AS ownerAddressSplit,
    REGEXP_SUBSTR(owneraddress, '[^,]+', 1, 2) AS ownerTownSplit,
    REGEXP_SUBSTR(owneraddress, '[^,]+', 1, 3) AS ownerStateSplit
FROM PropertyData;

--Now creating new columns for the data.
ALTER TABLE propertydata
ADD ownerAddressSplit VARCHAR2(35);
UPDATE propertydata
SET ownerAddressSplit = TRIM(REGEXP_SUBSTR(owneraddress, '[^,]+', 1, 1));

ALTER TABLE propertydata
ADD ownerTownSplit VARCHAR2(35);
UPDATE propertydata
SET ownerTownSplit = TRIM(REGEXP_SUBSTR(owneraddress, '[^,]+', 1, 2));

ALTER TABLE propertydata
ADD ownerStateSplit VARCHAR2(35);
UPDATE propertydata
SET ownerStateSplit = TRIM(REGEXP_SUBSTR(owneraddress, '[^,]+', 1, 3));

-- Checking correctness of the catergorical values.
-- LANDUSE field has unique and distict data, however SOLDASVACANT has
-- inconsistant data that needs correcting
SELECT DISTINCT(landuse)
FROM propertydata;

SELECT DISTINCT(soldasvacant), count(soldasvacant)
FROM propertydata
GROUP BY soldasvacant
ORDER BY 2 DESC;

-- Now to correct the categorical data using the CASE statement
SELECT soldasvacant,
CASE 
    WHEN soldasvacant ='Y' THEN 'Yes'
    WHEN soldasvacant = 'N' THEN 'No'
    ELSE soldasvacant
END AS correctedSoldAsVacant
FROM propertydata;

-- Now to update the corrected values
UPDATE propertydata
SET soldasvacant = (
CASE 
    WHEN soldasvacant ='Y' THEN 'Yes'
    WHEN soldasvacant = 'N' THEN 'No'
    ELSE soldasvacant
END)


-- Dealing with duplicates (Not good practice to delete data in a database)
-- Removed UNIQUEID since the could be unique on duplicates records
SELECT PARCELID, LANDUSE, PROPERTYADDRESS, SALEDATE, SALEPRICE,
LEGALREFERENCE, SOLDASVACANT, OWNERNAME, OWNERADDRESS, ACREAGE, TAXDISTRICT,
LANDVALUE, BUILDINGVALUE, TOTALVALUE, YEARBUILT, BEDROOMS, FULLBATH, HALFBATH,
COUNT(*) AS duplicate_count
FROM propertydata
GROUP BY PARCELID, LANDUSE, PROPERTYADDRESS, SALEDATE, SALEPRICE,
LEGALREFERENCE, SOLDASVACANT, OWNERNAME, OWNERADDRESS, ACREAGE, TAXDISTRICT,
LANDVALUE, BUILDINGVALUE, TOTALVALUE, YEARBUILT, BEDROOMS,FULLBATH, HALFBATH
HAVING COUNT(*) > 1;



--select * From propertydata


















