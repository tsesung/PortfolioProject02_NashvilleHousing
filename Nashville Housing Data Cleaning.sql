/*Data Cleaning Portfolio Project*/

select * from NashvilleHousing nh 

/*Standardize Date Format*/
select SaleDate, CONVERT(Date,SaleDate) fixedSaleDate
from NashvilleHousing nh 

update NashvilleHousing 
set SaleDate = CONVERT(Date,SaleDate)
where 1=1


/*Populate Property Address Data*/
select * from NashvilleHousing nh 
where PropertyAddress is NULL or PropertyAddress = ''
--order by ParcelID

--Cleanup '' rows
update NashvilleHousing set PropertyAddress =  NULL
where PropertyAddress is NULL or PropertyAddress = ''

select nh.ParcelID, nh.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress, ISNULL(nh.PropertyAddress,nh2.PropertyAddress)
from NashvilleHousing nh 
join NashvilleHousing nh2 on nh.ParcelID = nh2.ParcelID and nh.[UniqueID ] <> nh2.[UniqueID ] 
where nh.PropertyAddress is NULL

update nh
set PropertyAddress = ISNULL(nh.PropertyAddress,nh2.PropertyAddress)
from NashvilleHousing nh 
join NashvilleHousing nh2 on nh.ParcelID = nh2.ParcelID and nh.[UniqueID ] <> nh2.[UniqueID ] 
where nh.PropertyAddress is NULL


/*Breaking out Address into Individual Columns (Address, City, State)*/
select PropertyAddress from NashvilleHousing nh 

--PropertyAddress
select nh.PropertyAddress
, SUBSTRING(nh.PropertyAddress, 1, CHARINDEX(',',nh.PropertyAddress)-1) as Address
, SUBSTRING(nh.PropertyAddress, CHARINDEX(',',nh.PropertyAddress)+1, LEN(nh.PropertyAddress)) as City
from NashvilleHousing nh 

ALTER TABLE NashvilleHousing Add PropertySplitAddress varchar(255)

update NashvilleHousing set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing Add PropertySplitCity varchar(255)

update NashvilleHousing set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select PropertyAddress, PropertySplitAddress, PropertySplitCity from NashvilleHousing nh 

--OwnerAddress
select OwnerAddress from NashvilleHousing nh 

select OwnerAddress
, PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
, PARSENAME(REPLACE(OwnerAddress,',','.'),2) 
, PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
from NashvilleHousing nh 

ALTER TABLE NashvilleHousing Add OwnerSplitAddress varchar(255)
ALTER TABLE NashvilleHousing Add OwnerSplitCity varchar(255)
ALTER TABLE NashvilleHousing Add OwnerSplitState varchar(255)

update NashvilleHousing set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
update NashvilleHousing set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
update NashvilleHousing set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState from NashvilleHousing nh 


/*Change Y and N to Yes and No in "Sold as Vacant" column */ 
select SoldAsVacant, COUNT(SoldAsVacant)  
from NashvilleHousing nh 
group by SoldAsVacant 

select SoldAsVacant
, CASE 
	when SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant 
END
from NashvilleHousing nh 

Update NashvilleHousing 
set SoldAsVacant = (
CASE 
	when SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant 
END
)


/*Remove Duplicates*/
select * from NashvilleHousing nh 

WITH RowNumCTE as (
select * 
, ROW_NUMBER() over (PARTITION BY ParcelID, SaleDate, SalePrice, LegalReference ORDER BY [UniqueID ]) RowNum
from NashvilleHousing nh 
--order by ParcelID DESC 
)
--select * from RowNumCTE rnc
delete from RowNumCTE 
where RowNum > 1


/*Delete Unused Columns*/
select * from NashvilleHousing nh 

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress







