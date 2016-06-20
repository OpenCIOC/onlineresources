SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_NUMBillingAddress_u]
	@BADDR_ID int,
	@NUM varchar(8),
	@AddrType int,
	@Code varchar(100),
	@Priority tinyint,
	@Line1 nvarchar(200),
	@Line2 nvarchar(200),
	@Line3 nvarchar(200),
	@Line4 nvarchar(200),
	@City nvarchar(100),
	@Province varchar(2),
	@Country nvarchar(60),
	@PostalCode varchar(20)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

IF NOT EXISTS(SELECT * FROM GBL_BillingAddressType WHERE AddressTypeID=@AddrType) BEGIN
	IF @BADDR_ID IS NOT NULL BEGIN
		SET @AddrType = NULL
	END ELSE BEGIN
		SELECT TOP 1 @AddrType = AddressTypeID FROM GBL_BillingAddressType ORDER BY DefaultType DESC
	END
END

IF EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=@NUM AND LangID=@@LANGID) BEGIN
	IF @BADDR_ID IS NOT NULL BEGIN
		UPDATE GBL_BT_BILLINGADDRESS SET
			ADDRTYPE = ISNULL(@AddrType,ADDRTYPE),
			SITE_CODE = @Code,
			PRIORITY = ISNULL(@Priority,PRIORITY),
			LINE_1 = @Line1,
			LINE_2 = @Line2,
			LINE_3 = @Line3,
			LINE_4 = @Line4,
			CITY = @City,
			PROVINCE = @Province,
			COUNTRY = @Country,
			POSTAL_CODE = @PostalCode
		WHERE BADDR_ID=@BADDR_ID
	END ELSE BEGIN
		INSERT INTO GBL_BT_BILLINGADDRESS (
			NUM,
			LangID,
			ADDRTYPE,
			SITE_CODE,
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
			@@LANGID,
			@AddrType,
			@Code,
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
	END
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_NUMBillingAddress_u] TO [cioc_login_role]
GO
