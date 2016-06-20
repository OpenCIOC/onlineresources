SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_FullSource](
	@Pub nvarchar(100),
	@PubDate smalldatetime,
	@Name nvarchar(100),
	@Title nvarchar(100),
	@Org nvarchar(100),
	@Phone nvarchar(100),
	@Fax nvarchar(100),
	@Email nvarchar(60)
)
RETURNS nvarchar(1000) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 05-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @conStr	nvarchar(3),
		@colonStr nvarchar(3),
		@returnStr	nvarchar(1000)
			
SET @conStr = ''
SET @returnStr = ''
SET @colonStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')

IF @Pub IS NOT NULL BEGIN
	SET @returnStr = @Pub
	IF @PubDate IS NOT NULL BEGIN
		SET @returnStr = @returnStr + ' (' + cioc_shared.dbo.fn_SHR_GBL_DateString(@PubDate) + ')'
	END
	SET @conStr = CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
END
IF @Name IS NOT NULL BEGIN
	SET @returnStr = @Name
	SET @conStr = ', '
END
IF @Title IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Title
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
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_FullSource] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_FullSource] TO [cioc_vol_search_role]
GO
