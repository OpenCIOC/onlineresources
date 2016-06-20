SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[sp_GBL_View_DomainMap_u]
	@MemberID int,
	@MODIFIED_BY varchar(50),
	@CIC bit,
	@VOL bit,
	@data xml,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: CL
	Checked on: 21-Aug-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@DomainMapObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @DomainMapObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Domain Name Mapping')

DECLARE @DomainTable TABLE (
	DMAP_ID int NOT NULL,
	DefaultCulture char(5),
	DefaultLangID smallint,
	CICViewType int,
	VOLViewType int,
	SecondaryName bit,
	GoogleMapsAPIKeyCIC varchar(100),
	GoogleMapsClientIDCIC nvarchar(100),
	GoogleMapsChannelCIC nvarchar(100),
	GoogleMapsAPIKeyVOL varchar(100),
	GoogleMapsClientIDVOL nvarchar(100),
	GoogleMapsChannelVOL nvarchar(100),
	FullSSLCompatible bit
)

INSERT INTO @DomainTable
	( DMAP_ID, DefaultCulture, DefaultLangID, CICViewType, VOLViewType, SecondaryName,
	GoogleMapsAPIKeyCIC, GoogleMapsClientIDCIC, GoogleMapsChannelCIC,
	GoogleMapsAPIKeyVOL, GoogleMapsClientIDVOL, GoogleMapsChannelVOL,
	FullSSLCompatible)
	
SELECT 
	N.value('DMAP_ID[1]', 'int') AS DMAP_ID,
	N.value('DefaultCulture[1]', 'char(5)') AS DefaultCulture,
	(SELECT TOP 1 LangID FROM STP_Language WHERE Culture = N.value('DefaultCulture[1]', 'char(5)') AND Active=1) AS DefaultLangID,
	N.value('CICViewType[1]', 'int') AS CICViewType,
	N.value('VOLViewType[1]', 'int') AS VOLViewType,
	N.value('SecondaryName[1]', 'bit') AS SecondaryName,
	N.value('GoogleMapsAPIKeyCIC[1]', 'varchar(100)') AS GoogleMapsAPIKeyCIC,
	N.value('GoogleMapsClientIDCIC[1]', 'nvarchar(100)') AS GoogleMapsClientIDCIC,
	N.value('GoogleMapsChannelCIC[1]', 'nvarchar(100)') AS GoogleMapsChannelCIC,
	N.value('GoogleMapsAPIKeyVOL[1]', 'varchar(100)') AS GoogleMapsAPIKeyVOL,
	N.value('GoogleMapsClientIDVOL[1]', 'nvarchar(100)') AS GoogleMapsClientIDVOL,
	N.value('GoogleMapsChannelVOL[1]', 'nvarchar(100)') AS GoogleMapsChannelVOL,
	N.value('FullSSLCompatible[1]', 'bit') AS FullSSLCompatible
FROM @data.nodes('//Domain') AS T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DomainMapObjectName, @ErrMsg


DECLARE @BadCulturesDesc nvarchar(MAX), @BadViewTypeCIC varchar(MAX), @BadViewTypeVOL varchar(MAX)
SELECT DISTINCT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(DefaultCulture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DomainTable nt
WHERE DefaultLangID IS NULL

IF @CIC=1 BEGIN
SELECT DISTINCT @BadViewTypeCIC = COALESCE(@BadViewTypeCIC + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + CICViewType 
FROM @DomainTable INNER JOIN CIC_View ON ViewType=CICViewType AND MemberID=@MemberID WHERE CICViewType IS NOT NULL AND ViewType IS NULL
END

IF @VOL=1 BEGIN
SELECT DISTINCT @BadViewTypeVOL = COALESCE(@BadViewTypeVOL + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + VOLViewType 
FROM @DomainTable INNER JOIN VOL_View ON ViewType=VOLViewType AND MemberID=@MemberID WHERE VOLViewType IS NOT NULL AND ViewType IS NULL
END

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
END ELSE IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, cioc_shared.dbo.fn_SHR_STP_ObjectName('Language'))
END ELSE IF @BadViewTypeCIC IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadViewTypeCIC, cioc_shared.dbo.fn_SHR_STP_ObjectName('View'))
END ELSE IF @BadViewTypeVOL IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadViewTypeVOL, cioc_shared.dbo.fn_SHR_STP_ObjectName('View'))
END ELSE BEGIN

UPDATE dst SET 
	MODIFIED_DATE = GETDATE(),
	MODIFIED_BY = @MODIFIED_BY,
	DefaultLangID = src.DefaultLangID,
	CICViewType = CASE WHEN @CIC=1 THEN src.CICViewType ELSE dst.CICViewType END,
	VOLViewType = CASE WHEN @VOL=1 THEN src.VOLViewType ELSE dst.VOLViewType END,
	SecondaryName = src.SecondaryName,
	GoogleMapsAPIKeyCIC = CASE WHEN @CIC=1 THEN src.GoogleMapsAPIKeyCIC ELSE dst.GoogleMapsAPIKeyCIC END,
	GoogleMapsClientIDCIC = CASE WHEN @CIC=1 THEN src.GoogleMapsClientIDCIC ELSE dst.GoogleMapsClientIDCIC END,
	GoogleMapsChannelCIC = CASE WHEN @CIC=1 THEN src.GoogleMapsChannelCIC ELSE dst.GoogleMapsChannelCIC END,
	GoogleMapsAPIKeyVOL = CASE WHEN @VOL=1 THEN src.GoogleMapsAPIKeyVOL ELSE dst.GoogleMapsAPIKeyVOL END,
	GoogleMapsClientIDVOL = CASE WHEN @VOL=1 THEN src.GoogleMapsClientIDVOL ELSE dst.GoogleMapsClientIDVOL END,
	GoogleMapsChannelVOL = CASE WHEN @VOL=1 THEN src.GoogleMapsChannelVOL ELSE dst.GoogleMapsChannelVOL END,
	FullSSLCompatible = src.FullSSLCompatible
FROM GBL_View_DomainMap dst
INNER JOIN @DomainTable src
	ON dst.DMAP_ID=src.DMAP_ID
WHERE dst.MemberID=@MemberID
	
END

SET NOCOUNT OFF










GO


GRANT EXECUTE ON  [dbo].[sp_GBL_View_DomainMap_u] TO [cioc_login_role]
GO
