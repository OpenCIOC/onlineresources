SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Template_Default_Check]
	@Template_ID [int] OUTPUT,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 16-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@DesignTemplateObjectName nvarchar(100),
		@LayoutObjectName nvarchar(100),
		@AgencyObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @DesignTemplateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Design Template')
SET @DesignTemplateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Template Layout')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')

DECLARE @MODIFIED_BY varchar(50)
		
SET @MODIFIED_BY = 'CIOC HelpDesk'

SELECT @Template_ID = Template_ID FROM GBL_Template WHERE SystemTemplate=1

IF @Template_ID IS NULL BEGIN

	EXEC sp_STP_Language_Check

	IF EXISTS(SELECT * FROM GBL_Template_Description WHERE Name='CIOC - ' + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Default',LangID)) BEGIN
		SET @Error = 6 -- Value In Use
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, 'CIOC - ' + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Default',@@LANGID), @NameObjectName)
	END

	DECLARE @HeaderLayout int, @FooterLayout int, @CICSearchLayout int, @VOLSearchLayout int

	SELECT TOP 1 @HeaderLayout=tl.LayoutID 
	FROM GBL_Template_Layout tl 
		INNER JOIN GBL_Template_Layout_Description tld
			ON tld.LayoutID=tl.LayoutID
	WHERE tl.SystemLayout=1 AND tl.LayoutType='header' AND tld.LayoutName LIKE 'Old%'

	SELECT TOP 1 @FooterLayout=tl.LayoutID 
	FROM GBL_Template_Layout tl 
		INNER JOIN GBL_Template_Layout_Description tld
			ON tld.LayoutID=tl.LayoutID
	WHERE tl.SystemLayout=1 AND tl.LayoutType='footer' AND tld.LayoutName LIKE 'Old%'

	SELECT TOP 1 @CICSearchLayout=tl.LayoutID 
	FROM GBL_Template_Layout tl 
	WHERE tl.SystemLayout=1 AND tl.LayoutType='cicsearch' AND tl.DefaultSearchLayout=1

	SELECT TOP 1 @VOLSearchLayout=tl.LayoutID 
	FROM GBL_Template_Layout tl 
	WHERE tl.SystemLayout=1 AND tl.LayoutType='volsearch' AND tl.DefaultSearchLayout=1

	IF @Error = 0 BEGIN
		INSERT INTO GBL_Template (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			SystemTemplate,
			HeaderLayout,
			FooterLayout,
			SearchLayoutCIC,
			SearchLayoutVOL,
			TemplateCSSVersionDate
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			1,
			@HeaderLayout,
			@FooterLayout,
			@CICSearchLayout,
			@VOLSearchLayout,
			GETDATE()
		)
		SELECT @Template_ID = SCOPE_IDENTITY()
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DesignTemplateObjectName, @ErrMsg

		IF @Error=0 AND @Template_ID IS NOT NULL BEGIN
			INSERT INTO GBL_Template_Description (
				Template_ID, LangID, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY, Name
			)
			SELECT @Template_ID, LangID, GETDATE(), @MODIFIED_BY, GETDATE(), @MODIFIED_BY, 'CIOC - ' + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Default',LangID)
			FROM STP_Language WHERE Active=1
		END
	END
END

RETURN @Error

SET NOCOUNT OFF














GO
