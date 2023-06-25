/****** Script for SelectTopNRows command from SSMS  ******/
---Cleaning Nashville Housing Data
  Select *
  From PortfolioProject.dbo.NashvilleHousing

---Standardize date format
  Select SaleDate, CONVERT(Date, SaleDate)
  From PortfolioProject.dbo.NashvilleHousing

  --Query executed but didn't work 
  Update NashvilleHousing
  SET SaleDate = CONVERT(Date, SaleDate)

  --What worked
  ALTER TABLE NashvilleHousing
  Add SaleDateConverted Date;
  
  Update NashvilleHousing
  SET SaleDate = CONVERT(Date, SaleDate)

  --To check if it worked 
  Select SaleDateConverted, CONVERT(Date, SaleDate)
  From PortfolioProject.dbo.NashvilleHousing


---Populate property address area
  --Identify null rows
  Select *
  From PortfolioProject.dbo.NashvilleHousing
  Where PropertyAddress is NULL

  ---
  Select *
  From PortfolioProject.dbo.NashvilleHousing
  Where PropertyAddress is NULL
  Order by ParcelID

  --Replace null property address rows with corresponding parcelid address
  Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  From PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b
  On a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  Where a.PropertyAddress is NULL

  --Update the change to the table
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b
  On a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  Where a.PropertyAddress is NULL

  --Check if it worked
  Select *
  From PortfolioProject.dbo.NashvilleHousing
  Where PropertyAddress is NULL

---Seperate address into individual columns (address, city , state)
 --Split PropertyAddress First
 Select PropertyAddress
  From PortfolioProject.dbo.NashvilleHousing

  Select 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
  From PortfolioProject.dbo.NashvilleHousing

  Select 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
  From PortfolioProject.dbo.NashvilleHousing
 
 --Add changes as a new column
 ALTER TABLE NashvilleHousing
  Add PropertySplitAddress nvarchar(255);
  
  Update NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

   ALTER TABLE NashvilleHousing
  Add PropertySplitCity nvarchar(255);
  
  Update NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

  --Check results
  Select *
  From PortfolioProject.dbo.NashvilleHousing

  --Split OwnerAddress
  Select OwnerAddress
  From PortfolioProject.dbo.NashvilleHousing

  Select
  PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress,',', '.'), 1) 
  From PortfolioProject.dbo.NashvilleHousing

  --Add changes as a new column
  ALTER TABLE NashvilleHousing
  Add OwnerSplitAddress nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

  ALTER TABLE NashvilleHousing
  Add OwnerSplitCity nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

  ALTER TABLE NashvilleHousing
  Add OwnerSplitState nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

  --Check Results
  Select *
  From PortfolioProject.dbo.NashvilleHousing

---Change Y and N in 'Sold as Vacant" to Yes and No
  Select Distinct(SoldAsVacant), Count(SoldAsVacant)
  From PortfolioProject.dbo.NashvilleHousing
  Group by SoldAsVacant
  Order by 2

  Select SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END
  From PortfolioProject.dbo.NashvilleHousing

  --Add changes to table
  Update NashvilleHousing
  SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END

  ---Remove Duplicates and delete them
  WITH RowNumCTE AS(
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
  From PortfolioProject.dbo.NashvilleHousing
  --ORDER BY ParcelID
  )
  --DELETE
  Select *
  From RowNumCTE
  Where row_num > 1
  --Order by PropertyAddress

---Remove unused columns
Select *
From PortfolioProject.dbo.NashvilleHousing

  ALTER TABLE PortfolioProject.dbo.NashvilleHousing
  DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress


