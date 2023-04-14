select * 
from PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format (Change Sale Date)
select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

--Another way to update table by using alter
--Alter table NashvilleHousing
--Add SaleDateConverted Date;

--update NashvilleHousing
--set SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Address Data
select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b --Self join where personal ID is same but row is different to fill null rows
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b --Self join where personal ID is same but row is different to fill null rows
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null -- Running this to update our table and there are no null addresses now


--SplittingAddress into separate columns
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar (255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar (255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select * 
from PortfolioProject.dbo.NashvilleHousing



select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

--Splitting into separate columns using Parsename 
--Since parsename is useful only where periods are delimiters, we can replace periods with commas before splitting with parsename

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) --In 3,2,1 because Parsename splits in reverse
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) -- 1,2,3 would put TN first
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar (255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar (255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar (255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select * 
from PortfolioProject.dbo.NashvilleHousing



-- Changing Y and N to Yes and No in 'Sold As Vacant' Field
select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End


--Removing Duplicates

With RowNumCTE as (
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By 
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--Order By ParcelID
)
Delete
From RowNumCTE
where row_num > 1
--Order By PropertyAddress


-- Deleting Unused Columns 
Select * 
From PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

