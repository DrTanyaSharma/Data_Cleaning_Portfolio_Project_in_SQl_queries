--Cleaning data in SQl queries

Select *
From SQLPortfolioProject..NashvilleHousing

--Standardise Date format

Select SaleDate, CONVERT(Date,saledate) as SaleDateConverted
From SQLPortfolioProject..NashvilleHousing

Update SQLPortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE SQLPortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update SQLPortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



-- Populate property address data

select PropertyAddress
From SQLPortfolioProject.dbo.NashvilleHousing


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQLPortfolioProject.dbo.NashvilleHousing a
Join SQLPortfolioProject.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQLPortfolioProject.dbo.NashvilleHousing a
Join SQLPortfolioProject.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out address into individual columns (Address, City, State)

select PropertyAddress
From SQLPortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))  as Address

From SQLPortfolioProject.dbo.NashvilleHousing

ALTER TABLE SQLPortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update SQLPortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE SQLPortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update SQLPortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



Select*
From SQLPortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From SQLPortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From SQLPortfolioProject.dbo.NashvilleHousing

ALTER TABLE SQLPortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update SQLPortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE SQLPortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update SQLPortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE SQLPortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update SQLPortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select*
From SQLPortfolioProject.dbo.NashvilleHousing



-- Change Y and N to 'YES' and 'NO' in 'Sold As Vacant' Field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From SQLPortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' then 'Yes'
       WHEN SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From SQLPortfolioProject.dbo.NashvilleHousing


Update SQLPortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
       WHEN SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End





-- Remove Duplicates

WITH RowNumCTE AS(
Select*,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				      UniqueID
					  ) row_num

From SQLPortfolioProject..NashvilleHousing
)
Select*
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--Delete Unsused Columns

select*
From SQLPortfolioProject..NashvilleHousing

ALTER TABLE SQLPortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, Taxdistrict, PropertyAddress

ALTER TABLE SQLPortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
