/*

Cleaning data in SQL queries

*/


SELECT *
  FROM [Porfolio Project 1].[dbo].[NashvilleHousing]

------------------------------------------------------

-- Changing SaleDate

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [Porfolio Project 1].[dbo].[NashvilleHousing]

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------

-- Populate Propert Addresss

SELECT *
FROM [Porfolio Project 1].[dbo].[NashvilleHousing]
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Porfolio Project 1].[dbo].[NashvilleHousing] a
JOIN [Porfolio Project 1].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Porfolio Project 1].[dbo].[NashvilleHousing] a
JOIN [Porfolio Project 1].[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

---------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns(Address, City, State)

SELECT PropertyAddress
FROM [Porfolio Project 1].dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM [Porfolio Project 1].dbo.NashvilleHousing


ALTER TABLE [Porfolio Project 1].dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [Porfolio Project 1].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE [Porfolio Project 1].dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE [Porfolio Project 1].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT
PARSENAME(REPLACE(OWNERADDRESS, ',', '.') ,3)
,PARSENAME(REPLACE(OWNERADDRESS, ',', '.') ,2)
,PARSENAME(REPLACE(OWNERADDRESS, ',', '.') ,1)
FROM [Porfolio Project 1].dbo.NashvilleHousing


ALTER TABLE [Porfolio Project 1].dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [Porfolio Project 1].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OWNERADDRESS, ',', '.') ,3)

ALTER TABLE [Porfolio Project 1].dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [Porfolio Project 1].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OWNERADDRESS, ',', '.') ,2)

ALTER TABLE [Porfolio Project 1].dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE [Porfolio Project 1].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OWNERADDRESS, ',', '.') ,1)


SELECT *
FROM [Porfolio Project 1].dbo.NashvilleHousing

--------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldasVacant)
FROM [Porfolio Project 1].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN	SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [Porfolio Project 1].dbo.NashvilleHousing


UPDATE [Porfolio Project 1].dbo.NashvilleHousing
SET SoldasVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN	SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY PARCELID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [Porfolio Project 1].dbo.NashvilleHousing
)
Select *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

---------------------------------------------------------------------------

-- Deleting Unused Columns

SELECT *
FROM [Porfolio Project 1].dbo.NashvilleHousing

ALTER TABLE [Porfolio Project 1].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



