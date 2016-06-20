SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_BillingAddress_i]
	@NUM varchar(8),
	@LangID smallint,
	@GUID [uniqueidentifier],
	@AddrType varchar(20),
	@Code varchar(100),
	@CASConfirmationDate smalldatetime,
	@Priority tinyint,
	@Line1 nvarchar(200),
	@Line2 nvarchar(200),
	@Line3 nvarchar(200),
	@Line4 nvarchar(200),
	@City nvarchar(100),
	@Province varchar(2),
	@Country nvarchar(60),
	@PostalCode varchar(20),
	@BADDR_ID int OUTPUT
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

DECLARE @AddressTypeID int

IF EXISTS(SELECT * FROM GBL_BT_BILLINGADDRESS WHERE GUID=@GUID AND (NUM<>@NUM OR LangID=@LangID)) BEGIN
	SET @BAD_GUID = 1
END

IF EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=@NUM AND LangID=@LangID) BEGIN
	SELECT @BADDR_ID = BADDR_ID FROM GBL_BT_BILLINGADDRESS WHERE NUM=@NUM AND LangID=@LangID AND GUID=@GUID

	SELECT @AddressTypeID = AddressTypeID FROM GBL_BillingAddressType WHERE Code=@AddrType
	IF @AddressTypeID IS NULL BEGIN
		IF @BADDR_ID IS NOT NULL BEGIN
			SET @AddressTypeID = NULL
		END ELSE BEGIN
			SELECT TOP 1 @AddressTypeID = AddressTypeID FROM GBL_BillingAddressType ORDER BY DefaultType DESC
		END
	END

	IF @BADDR_ID IS NOT NULL BEGIN
		UPDATE GBL_BT_BILLINGADDRESS SET
			ADDRTYPE = ISNULL(@AddressTypeID,ADDRTYPE),
			SITE_CODE = @Code,
			CAS_CONFIRMATION_DATE = @CASConfirmationDate,
			PRIORITY = ISNULL(@Priority,PRIORITY),
			LINE_1 = @Line1,
			LINE_2 = @Line2,
			LINE_3 = @Line3,
			LINE_4 = @Line4,
			CITY = @City,
			PROVINCE = @Province,
			COUNTRY = @Country,
			POSTAL_CODE = @PostalCode
		WHERE GUID=@GUID
	END ELSE BEGIN
		INSERT INTO GBL_BT_BILLINGADDRESS (
			NUM,
			GUID,
			LangID,
			ADDRTYPE,
			SITE_CODE,
			CAS_CONFIRMATION_DATE,
			PRIORITY,
			LINE_1,
			LINE_2,
			LINE_3,
			LINE_4,
			CITY,
			PROVINCE,
			COUNTRY,
			POSTAL_CODE
		) VALUES (
			@NUM,
			CASE WHEN @BAD_GUID=1 THEN NEWID() ELSE @GUID END,
			@LangID,
			@AddressTypeID,
			@Code,
			@CASConfirmationDate,
			ISNULL(@Priority,0),
			@Line1,
			@Line2,
			@Line3,
			@Line4,
			@City,
			@Province,
			@Country,
			@PostalCode
		)
		SELECT @BADDR_ID = SCOPE_IDENTITY()
	END
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_BillingAddress_i] TO [cioc_login_role]
GO
