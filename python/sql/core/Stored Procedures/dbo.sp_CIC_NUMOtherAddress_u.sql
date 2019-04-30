SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMOtherAddress_u]
	@ADDR_ID int,
	@NUM varchar(8),
	@Title nvarchar(100),
	@Code varchar(100),
	@CareOf nvarchar(100),
	@BoxType nvarchar(20),
	@POBox nvarchar(20),
	@Building nvarchar(100),
	@StreetNumber nvarchar(30),
	@Street nvarchar(200),
	@StreetType nvarchar(20),
	@AfterName bit,
	@StreetDir nvarchar(20),
	@Suffix nvarchar(150),
	@City nvarchar(100),
	@Province varchar(2),
	@Country nvarchar(60),
	@PostalCode varchar(20),
	@Latitude DECIMAL(11,7),
	@Longitude DECIMAL(11,7),
	@MapLink INT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
	Notes: Should this incorporate some error checks?
*/

IF NOT EXISTS(SELECT * FROM GBL_MappingSystem WHERE MAP_ID=@MapLink) BEGIN
	SET @MapLink = NULL
END

IF EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=@NUM AND LangID=@@LANGID) BEGIN
	IF @ADDR_ID IS NOT NULL BEGIN
		UPDATE CIC_BT_OTHERADDRESS SET
			TITLE = @Title,
			SITE_CODE = @Code,
			CARE_OF = @CareOf,
			BOX_TYPE = @BoxType,
			PO_BOX = @POBox,
			BUILDING = @Building,
			STREET_NUMBER = @StreetNumber,
			STREET = @Street,
			STREET_TYPE = @StreetType,
			STREET_TYPE_AFTER = @AfterName,
			STREET_DIR = @StreetDir,
			SUFFIX = @Suffix,
			CITY = @City,
			PROVINCE = @Province,
			COUNTRY = @Country,
			POSTAL_CODE = @PostalCode,
			LATITUDE = @Latitude,
			LONGITUDE = @Longitude,
			MAP_LINK = @MapLink
		WHERE ADDR_ID=@ADDR_ID
	END ELSE BEGIN
		INSERT INTO CIC_BT_OTHERADDRESS (
			NUM,
			LangID,
			TITLE,
			SITE_CODE,
			CARE_OF,
			BOX_TYPE,
			PO_BOX,
			BUILDING,
			STREET_NUMBER,
			STREET,
			STREET_TYPE,
			STREET_TYPE_AFTER,
			STREET_DIR,
			SUFFIX,
			CITY,
			PROVINCE,
			COUNTRY,
			POSTAL_CODE,
			LATITUDE,
			LONGITUDE,
			MAP_LINK
		) VALUES (
			@NUM,
			@@LANGID,
			@Title,
			@Code,
			@CareOf,
			@BoxType,
			@POBox,
			@Building,
			@StreetNumber,
			@Street,
			@StreetType,
			@AfterName,
			@StreetDir,
			@Suffix,
			@City,
			@Province,
			@Country,
			@PostalCode,
			@Latitude,
			@Longitude,
			@MapLink
		)
	END
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMOtherAddress_u] TO [cioc_login_role]
GO
