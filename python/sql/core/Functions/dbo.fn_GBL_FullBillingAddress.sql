SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_FullBillingAddress](
	@NUM varchar(8),
	@Line1 nvarchar(200),
	@Line2 nvarchar(200),
	@Line3 nvarchar(200),
	@Line4 nvarchar(200),
	@City nvarchar(100),
	@Province nvarchar(2),
	@Country nvarchar(60),
	@PostalCode nvarchar(20)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr nvarchar(max),
		@conStr nvarchar(5)

SET @returnStr = ''
SET @conStr = CHAR(13) + CHAR(10)

SET @returnStr = ISNULL(@Line1,'')
IF @Line2 IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Line2
END
IF @Line3 IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Line3
END
IF @Line4 IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Line4
END

IF @City IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @City
	SET @conStr = ', '
END
IF @Province IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Province
END
IF @Country IS NOT NULL BEGIN
	IF @returnStr <> '' SET @conStr =  CHAR(13) + CHAR(10)
	SET @returnStr = @returnStr + @conStr + @Country
END
IF @returnStr <> '' AND (@City IS NOT NULL OR @Province IS NOT NULL OR @Country IS NOT NULL) SET @conStr = '     '
IF @PostalCode IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @PostalCode
END

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr
END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_FullBillingAddress] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullBillingAddress] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullBillingAddress] TO [cioc_vol_search_role]
GO
