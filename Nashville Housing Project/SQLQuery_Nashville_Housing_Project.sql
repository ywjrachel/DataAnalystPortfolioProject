SELECT *
FROM NashvilleProject.dbo.NashvilleHousing


-- Standardise Date Format
SELECT *
FROM NashvilleProject.dbo.NashvilleHousing

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add New_Sale_Date Date;

UPDATE NashvilleHousing
SET New_Sale_Date = CONVERT(Date,SaleDate)


-- Populate Property Address Data
SELECT *
FROM NashvilleProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleProject.dbo.NashvilleHousing AS a
JOIN NashvilleProject.dbo.NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleProject.dbo.NashvilleHousing AS a
JOIN NashvilleProject.dbo.NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Break down Address into individual columns (Address, City, State)
SELECT PropertyAddress
FROM NashvilleProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM NashvilleProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add Property_Split_Address nvarchar(255);

UPDATE NashvilleHousing
SET Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add Property_Split_City nvarchar(255);

UPDATE NashvilleHousing
SET Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM NashvilleProject.dbo.NashvilleHousing


-- Break down Owners Address into individual columns (Address, City, State)
SELECT OwnerAddress
FROM NashvilleProject.dbo.NashvilleHousing

SELECT
PARSENAME (REPLACE(OwnerAddress, ',', '.'),3) AS Owner_Address_Split_Address
, PARSENAME (REPLACE(OwnerAddress, ',', '.'),2) AS Owner_Address_Split_City
, PARSENAME (REPLACE(OwnerAddress, ',', '.'),1) AS Owner_Address_Split_State
FROM NashvilleProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add Owner_Address_Split_Address nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Address_Split_Address = PARSENAME (REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
Add Owner_Address_Split_City nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Address_Split_City = PARSENAME (REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add Owner_Address_Split_State nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Address_Split_State = PARSENAME (REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM NashvilleProject.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

-- Remove Duplicates
WITH RowNumberCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
				
FROM NashvilleProject.dbo.NashvilleHousing
-- Order By ParcelID
)
DELETE
FROM RowNumberCTE
WHERE row_num >1
-- Order by PropertyAddress

SELECT *
FROM NashvilleProject.dbo.NashvilleHousing


-- Delete unused column
SELECT *
FROM NashvilleProject.dbo.NashvilleHousing

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
DROP COLUMN SaleDate