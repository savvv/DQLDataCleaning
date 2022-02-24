
-- Using SQL Queries to clean House data:


-- getting familiar with the data
select *
from SQLPortifolioProject.dbo.HouseData

-- distinct on LandUse
select LandUse
from SQLPortifolioProject.dbo.HouseData
-- find the records number  where Landuse is Resindential condo
select COUNT(LandUse)
from SQLPortifolioProject.dbo.HouseData
where LandUse='RESIDENTIAL CONDO'


-- begin the cleaning:
 -- standadarize the the salesdate format
 select SaleDate, convert(Date, SaleDate)
 from SQLPortifolioProject.dbo.HouseData
 
 ALTER TABLE HouseData
 add SaleDate1 nvarchar(255)

 update HouseData
 set SaleDate1 = convert(Date, SaleDate)

 -- populate null in propertyAdress colum with the real adresses
update a 
set a.PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from SQLPortifolioProject.dbo.HouseData a
join SQLPortifolioProject.dbo.HouseData b
    on  a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- separating address and the city in the propertaddress column
select SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) as address
       ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as city
from SQLPortifolioProject.dbo.HouseData

-- adding the two new columns for propertyaddress(address, city)
alter table SQLPortifolioProject.dbo.HouseData
add propertysplitAdd nvarchar(255)

update  SQLPortifolioProject.dbo.HouseData
set propertysplitAdd = SUBSTRING(PropertyAddress,1, CHARINDEX(',' , PropertyAddress)-1)

alter table SQLPortifolioProject.dbo.HouseData
add propertysplitCity nvarchar(255)

update  SQLPortifolioProject.dbo.HouseData
set propertysplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress)+1,LEN(PropertyAddress))

--splitting property'sowner address into three seperable columns(address, city and state)
select owneraddress
from SQLPortifolioProject.dbo.HouseData
Group by OwnerAddress

alter table SQLPortifolioProject.dbo.HouseData
add ownersplitAdd nvarchar(255)

update SQLPortifolioProject.dbo.HouseData
--set ownersplitAdd = SUBSTRING(OwnerAddress,1, CHARINDEX(',', OwnerAddress)-1)
set ownersplitAdd = parsename(replace(OwnerAddress,',','.'),3)

alter table SQLPortifolioProject.dbo.HouseData
add ownersplitCity nvarchar(255)

update SQLPortifolioProject.dbo.HouseData
--set ownersplitCity =RTRIM(LTRIM(REPLACE(REPLACE(OwnerAddress,SUBSTRING(OwnerAddress , 1, CHARINDEX(',', OwnerAddress) + 1),''),
--REVERSE( LEFT( REVERSE(OwnerAddress), CHARINDEX(' ', REVERSE(OwnerAddress))+1 ) ),'')))
set ownersplitCity = parsename(replace(OwnerAddress,',','.'),2)

alter table SQLPortifolioProject.dbo.HouseData
add ownersplitState nvarchar(255)

update SQLPortifolioProject.dbo.HouseData
--set ownersplitState =   REVERSE( LEFT( REVERSE(OwnerAddress), CHARINDEX(',', REVERSE(OwnerAddress))-1 ) ) 
set ownersplitState = parsename(replace(OwnerAddress,',','.'),1)

--change Y into Yes and N into No

update SQLPortifolioProject.dbo.HouseData
set SoldAsVacant = CASE when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END 

---------------------------------------------------------------------------------------------------------------------------------------------------
-- find and remove duplicate from the houseData dataset

with CTE as(
select * , ROW_NUMBER() over (partition by  ParcelID, PropertyAddress, SalePrice, SaleDate1, LegalReference 
order by UniqueID) row_num 
from SQLPortifolioProject.dbo.HouseData
)
--Delete
select *
from CTE
where row_num>1
--------------------------------------------------------------------------------------------------------------------------------------

-- delete unwanted columns
alter table SQLPortifolioProject.dbo.HouseData
drop column SaleDate,PropertyAddress,OwnerAddress
alter table SQLPortifolioProject.dbo.HouseData
drop column duplicate