SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_OtherAddress_i]
	@NUM varchar(8),
	@LangID smallint,
	@GUID [uniqueidentifier],
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
	@ADDR_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @BAD_GUID bit
SET @BAD_GUID = 0

IF EXISTS(SELECT * FROM CIC_BT_OTHERADDRESS WHERE GUID=@GUID AND (NUM<>@NUM OR LangID=@LangID)) BEGIN
	SET @BAD_GUID = 1
END

IF EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=@NUM AND LangID=@LangID) BEGIN
	SELECT @ADDR_ID = ADDR_ID FROM CIC_BT_OTHERADDRESS WHERE NUM=@NUM AND LangID=@LangID AND GUID=@GUID

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
			POSTAL_CODE = @PostalCode
		WHERE GUID=@GUID
	END ELSE BEGIN
		INSERT INTO CIC_BT_OTHERADDRESS (
			NUM,
			GUID,
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
			POSTAL_CODE
		) VALUES (
			@NUM,
			CASE WHEN @BAD_GUID=1 THEN NEWID() ELSE @GUID END,
			@LangID,
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
			@PostalCode
		)
		SELECT @ADDR_ID = SCOPE_IDENTITY()
	END
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_OtherAddress_i] TO [cioc_login_role]
GO
