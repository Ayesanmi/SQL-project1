SELECT*
FROM portfolio_project.nashville_housing_data_for_data_cleaning;

-- Standardize Date Format
-- (Looking at the date from the excel file, it wasnt in the 
-- standard form so we have to convert it to the standard date format).
-- SELECT SaleDate, convert(SaleDate, '%y-%m-%d') as new_date
-- FROM portfolio_project.nashville_housing_data_for_data_cleaning;


-----------------------------------------------------------------------------------------------------------------------------------------------------
-- populate property address
SELECT*
FROM portfolio_project.nashville_housing_data_for_data_cleaning
WHERE propertyaddress ='';                  -- when there are blank cells use ='' to represent the blank cells but when the cells are filled with null we use the statement where column is null.

-- to be able to populate we have to use join clause
-- if(char_length(column)>0 is used as an alternative for ifnull since we are dealing with blank cells rather than null.
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, if(char_length(a.propertyaddress)>0,  A.propertyaddress,B.propertyaddress) as newtable
FROM portfolio_project.nashville_housing_data_for_data_cleaning A
join portfolio_project.nashville_housing_data_for_data_cleaning B
ON A.ParcelID = B.ParcelID
AND A.uniqueid <> B.uniqueid
WHERE A.PropertyAddress ='';

Update portfolio_project.nashville_housing_data_for_data_cleaning  A 
JOIN portfolio_project.nashville_housing_data_for_data_cleaning B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID  <> B.UniqueID 
SET a.PropertyAddress = if(char_length(a.propertyaddress)>0, A.propertyaddress,B.propertyaddress)
WHERE A.PropertyAddress ='';

----------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
-- when we check out the property address we can see that it has a delimiter( ,) which separates the address of the property and the city in which its located.alter

SELECT `PropertyAddress`
FROM portfolio_project.nashville_housing_data_for_data_cleaning;

-- substring function extract a substring from a string starting at any position
-- property address is the string
-- 1 is the start position
-- position function is basically searching for a specific value or returns the position of the first occurrence of the substring
-- -1 is the lenght of the value
-- char_length returns the length of a string or number of character in a string

SELECT SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1  ) as Address
, SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 1 , CHAR_LENGTH(PropertyAddress)) as Address    -- we are not gonna start from the first position we starting from the comma reason we used +1
FROM portfolio_project.nashville_housing_data_for_data_cleaning;

-- we cant separate two values from a column without creating two more columns
ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning
ADD Property_Address VARCHAR(255);

UPDATE portfolio_project.nashville_housing_data_for_data_cleaning
SET Property_Address = SUBSTRING(PropertyAddress, 1, POSITION(','IN PropertyAddress) -1 );

ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning
ADD Property_City VARCHAR(255);

UPDATE portfolio_project.nashville_housing_data_for_data_cleaning
SET Property_City = SUBSTRING(PropertyAddress, POSITION(','IN PropertyAddress) + 1 , CHAR_LENGTH(PropertyAddress));

SELECT*
FROM portfolio_project.nashville_housing_data_for_data_cleaning;

-- another alternative to the substring,position and char_length which is simpler and faster is the Substring_index function

SELECT OwnerAddress
FROM portfolio_project.nashville_housing_data_for_data_cleaning;

SELECT SUBSTRING(ownerAddress,  1, POSITION(',' IN ownerAddress)-1  ) as owner_Address
-- , SUBSTRING( owneraddress, POSITION(',' IN ownerAddress)  , CHAR_LENGTH(ownerAddress)) as owner_city 
, SUBSTRING(ownerAddress, -2, POSITION(',' IN ownerAddress) + 1) as state
FROM portfolio_project.nashville_housing_data_for_data_cleaning;

ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning
ADD owner_Address VARCHAR(255);

UPDATE portfolio_project.nashville_housing_data_for_data_cleaning
SET owner_Address = SUBSTRING(owneraddress, 1, POSITION(','IN ownerAddress) -1 );

-- ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning
-- ADD City VARCHAR(255);

-- UPDATE portfolio_project.nashville_housing_data_for_data_cleaning
-- SET city= SUBSTRING( owneraddress, POSITION(',' IN ownerAddress)  , CHAR_LENGTH(ownerAddress));

ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning
ADD owner_state VARCHAR(255);

UPDATE portfolio_project.nashville_housing_data_for_data_cleaning
SET owner_state = SUBSTRING(owneraddress, -2, POSITION(','IN ownerAddress) +1 );

SELECT*
FROM portfolio_project.nashville_housing_data_for_data_cleaning;

-------------------------------------------------------------------------------------------------
-- changing the N,Y to NO and YES because we if we use the distinct and count function to call the soldasvacant column we would notice that some values are recorded as N and Y instead of YES and NO
SELECT DISTINCT `soldasvacant`, COUNT(SoldAsVacant)
FROM portfolio_project.nashville_housing_data_for_data_cleaning
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT `SoldAsVacant`
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM portfolio_project.nashville_housing_data_for_data_cleaning;

UPDATE portfolio_project.nashville_housing_data_for_data_cleaning
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
    -----------------------------------------------------------------------------------------------------------------------------------   
       
   -- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 Property_Address,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From portfolio_project.nashville_housing_data_for_data_cleaning
-- order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by Property_Address;



Select *
From portfolio_project.nashville_housing_data_for_data_cleaning; 

       
--------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns



SELECT *
FROM portfolio_project.nashville_housing_data_for_data_cleaning;

ALTER TABLE portfolio_project.nashville_housing_data_for_data_cleaning
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress, 
DROP COLUMN Taxdistrict,
DROP COLUMN Propertysplitaddress,
DROP COLUMN Propertysplitcity;

----------------------------------------------------------------------------------------------------------------------------------------------------
