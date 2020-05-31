SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_FullSource](
	@Name nvarchar(100),
	@Title nvarchar(100),
	@Org nvarchar(100),
	@Phone nvarchar(100),
	@Fax nvarchar(100),
	@Email varchar(60),
	@Building nvarchar(100),
	@Address nvarchar(150),
	@City nvarchar(100),
	@Province varchar(2),
	@PostalCode varchar(8)
)
RETURNS nvarchar(1000) WITH EXECUTE AS CALLER
AS 
BEGIN

DECLARE @addrStr nvarchar(400),
		@conStr	nvarchar(3),
		@colonStr nvarchar(3),
		@returnStr	nvarchar(1000)

SET @conStr = ''
SET @returnStr = ''
SET @colonStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')

IF @Name IS NOT NULL BEGIN
	SET @returnStr = @Name
	SET @conStr = ', '
END
IF @Title IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Title
	SET @conStr = ', '
END
IF @Org IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Org
	SET @conStr = ', '
END
IF @Phone IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + cioc_shared.dbo.fn_SHR_STP_ObjectName('Phone') + @colonStr + @Phone
	SET @conStr = ', '
END
IF @Fax IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + cioc_shared.dbo.fn_SHR_STP_ObjectName('Fax') + @colonStr + @Fax
	SET @conStr = ', '
END
IF @Email IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + cioc_shared.dbo.fn_SHR_STP_ObjectName('Email') + @colonStr + @Email
	SET @conStr = CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
END
SET @addrStr = dbo.fn_GBL_FullAddress (
	NULL,
	NULL,
	NULL,
	NULL,
	@Building,
	NULL,
	@Address,
	NULL,
	NULL,
	NULL,
	NULL,
	@City,
	@Province,
	NULL,
	@PostalCode,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	@@LANGID,
	0
)
IF @addrStr <> '' AND @addrStr IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @addrStr
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_FullSource] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullSource] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullSource] TO [cioc_vol_search_role]
GO
