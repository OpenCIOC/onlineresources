SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [dbo].[fn_CIC_ExportProfile_SSL_Source](
	@SubmitChangesToAccessURL nvarchar(200)
)
RETURNS nvarchar(5) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 12-Nov-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnVal nvarchar(5),
		@ViewType int,
		@DomainName nvarchar(200)

	
DECLARE	@ItemID varchar(10),
		@Pos int
		
SET @returnVal = ''

IF @SubmitChangesToAccessURL IS NOT NULL BEGIN
	SET @Pos = CHARINDEX(' ',@SubmitChangesToAccessURL,1)
	
	SET @SubmitChangesToAccessURL = RIGHT(@SubmitChangesToAccessURL, LEN(@SubmitChangesToAccessURL)-@Pos)
	SET @Pos = CHARINDEX(' ',@SubmitChangesToAccessURL,1)
	
	SET @ViewType = CAST(LTRIM(RTRIM(LEFT(@SubmitChangesToAccessURL,@Pos-1))) AS int)
	
	SET @DomainName = LTRIM(RTRIM(RIGHT(@SubmitChangesToAccessURL, LEN(@SubmitChangesToAccessURL)-@Pos)))
	
	SET @returnVal = CASE WHEN ISNULL((SELECT FullSSLCompatible FROM GBL_View_DomainMap WHERE DomainName=@DomainName), 0) = 1 
						AND ISNULL((SELECT FullSSLCompatible_Cache FROM GBL_Template t INNER JOIN CIC_View v ON v.Template = t.Template_ID WHERE v.ViewType=@ViewType), 0) = 1 
					THEN N'https' 
					ELSE N'http' 
					END
END

RETURN @returnVal

END









GO
GRANT EXECUTE ON  [dbo].[fn_CIC_ExportProfile_SSL_Source] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_ExportProfile_SSL_Source] TO [cioc_login_role]
GO
