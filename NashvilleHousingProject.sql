Select *
From PortfolioProjects.dbo.Nashvillehousing



--Standardizing Sale Date

Select SaleDate, CONVERT(date,SaleDate)
From PortfolioProjects.dbo.Nashvillehousing


Update PortfolioProjects.dbo.Nashvillehousing
SET SaleDate = CONVERT(date,SaleDate)


ALTER TABLE PortfolioProjects.dbo.Nashvillehousing
ADD SaleDateConverted Date ;


Update PortfolioProjects.dbo.Nashvillehousing
SET SaleDateConverted = CONVERT(date,SaleDate)


Select SaleDateConverted, CONVERT(date,SaleDate)
From PortfolioProjects.dbo.Nashvillehousing



--Going to Populate Address Data

Select *
From PortfolioProjects.dbo.Nashvillehousing
--Where PropertyAddress is null
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects.dbo.Nashvillehousing a 
join PortfolioProjects.dbo.Nashvillehousing b 
	on a.parcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 


UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects.dbo.Nashvillehousing a 
join PortfolioProjects.dbo.Nashvillehousing b 
	on a.parcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 



---Breaking out Address into Individual Colunms (Address, City, State)

Select PropertyAddress
From PortfolioProjects.dbo.Nashvillehousing
--Where PropertyAddress is null
--Order By ParcelID


Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProjects.dbo.Nashvillehousing


ALTER TABLE PortfolioProjects.dbo.Nashvillehousing
ADD PropertySplitAddress NVARCHAR(255);


Update PortfolioProjects.dbo.Nashvillehousing
SET PropertySplitAddress  = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 


ALTER TABLE PortfolioProjects.dbo.Nashvillehousing
ADD PropertySplitCity NVARCHAR(255) ;


Update PortfolioProjects.dbo.Nashvillehousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select *
From PortfolioProjects.dbo.Nashvillehousing



---Owner Address (PARSENAME)

Select OwnerAddress
From PortfolioProjects.dbo.Nashvillehousing


Select 
PARSENAME(Replace(OwnerAddress,',', '.') ,3) 
,PARSENAME(Replace(OwnerAddress,',', '.') ,2) 
,PARSENAME(Replace(OwnerAddress,',', '.') ,1) 
From PortfolioProjects.dbo.Nashvillehousing


ALTER TABLE PortfolioProjects.dbo.Nashvillehousing
ADD OwnerSplitAddress NVARCHAR(255);


Update PortfolioProjects.dbo.Nashvillehousing
SET OwnerSplitAddress   = PARSENAME(Replace(OwnerAddress,',', '.') ,3) 


ALTER TABLE PortfolioProjects.dbo.Nashvillehousing
ADD OwnerSplitCity NVARCHAR(255) ;


Update PortfolioProjects.dbo.Nashvillehousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.') ,2) 


ALTER TABLE PortfolioProjects.dbo.Nashvillehousing
ADD OwnerSplitState NVARCHAR(255) ;


Update PortfolioProjects.dbo.Nashvillehousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.') ,1) 


Select *
From PortfolioProjects.dbo.Nashvillehousing



--Changing Y and N to "Yes" and "No" in the "SoldAsVacant" Column

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjects.dbo.Nashvillehousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From PortfolioProjects.dbo.Nashvillehousing


UPDATE PortfolioProjects.dbo.Nashvillehousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END



 --Removing Duplicates using CTE 


 With RowNumCTE AS(
 Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num

 From PortfolioProjects.dbo.Nashvillehousing
 --Order by ParcelID
 )
 DELETE
 From RowNumCTE
 Where row_num > 1 
 --Order by PropertyAddress


 
--Deleting Unused Columns 

Select *
From PortfolioProjects.dbo.Nashvillehousing

ALTER TABLE PortfolioProjects.dbo.Nashvillehousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjects.dbo.Nashvillehousing
Drop Column SaleDate

