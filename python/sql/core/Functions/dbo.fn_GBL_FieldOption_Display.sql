SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_FieldOption_Display](
	@MemberID int,
	@ViewType int,
	@FieldID int,
	@FieldName varchar(100),
	@RespectPrivacyProfile bit,
	@PrivacyProfileIDList varchar(max),
	@CanShare bit,
	@DisplayFM varchar(max),
	@DisplayFMWeb varchar(max),
	@FieldType varchar(3),
	@FormFieldType char(1),
	@EquivalentSource bit,
	@CheckboxOnText nvarchar(100),
	@CheckboxOffText nvarchar(100),
	@UseAS bit
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

DECLARE @SharingProfileIDList varchar(max),
		@returnStr nvarchar(max)

SET @CanShare = CASE
			WHEN @CanShare=0 THEN 0
			WHEN @MemberID IS NULL THEN 0
			ELSE 1 END

IF @CanShare=1 BEGIN
	SELECT @SharingProfileIDList = CASE
		WHEN @ViewType IS NULL THEN 'NULL'
		ELSE dbo.fn_GBL_SharingProfile_CIC_Fld_l(@MemberID,@ViewType,@FieldID)
	END
END

IF @PrivacyProfileIDList IS NULL BEGIN
	SET @RespectPrivacyProfile = 0
END

SET @returnStr = CASE
		WHEN @FormFieldType='c'
			THEN 'CASE WHEN ' + 
				CASE
				WHEN @DisplayFM IS NOT NULL THEN @DisplayFM
				ELSE CASE
					WHEN @FieldType='CIC' THEN 'cbt'
					WHEN @FieldType='CCR' THEN 'ccbt'
					ELSE 'bt'
				END + CASE WHEN @EquivalentSource=1 THEN 'd' ELSE '' END + '.' + @FieldName
			END + '=1 THEN N''' + ISNULL(REPLACE(@CheckboxOnText,'''',''''''),cioc_shared.dbo.fn_SHR_STP_ObjectName('Yes')) + ''' WHEN ' + 
			CASE
				WHEN @DisplayFM IS NOT NULL THEN @DisplayFM
				ELSE CASE
					WHEN @FieldType='CIC' THEN 'cbt'
					WHEN @FieldType='CCR' THEN 'ccbt'
					ELSE 'bt'
				END + CASE WHEN @EquivalentSource=1 THEN 'd' ELSE '' END + '.' + @FieldName
			END + '=0 THEN N''' + ISNULL(REPLACE(@CheckboxOffText,'''',''''''),cioc_shared.dbo.fn_SHR_STP_ObjectName('No')) + ''' END'
		WHEN @DisplayFM IS NOT NULL
			THEN REPLACE(
					REPLACE(
						REPLACE(@DisplayFM,'[LANGID]',@@LANGID),
						'[MEMBER]',
						CASE WHEN @MemberID IS NULL THEN 'bt.MemberID' ELSE CAST(@MemberID AS varchar) END
					),
					'[VIEW]',
					CASE WHEN @ViewType IS NULL THEN 'NULL' ELSE CAST(@ViewType	AS varchar) END
				)
		ELSE CASE
				WHEN @FieldType='CIC' THEN 'cbt'
				WHEN @FieldType='CCR' THEN 'ccbt'
				ELSE 'bt'
			END + CASE WHEN @EquivalentSource=1 THEN 'd' ELSE '' END + '.' + @FieldName
	END

IF @RespectPrivacyProfile=1 BEGIN
	SET @returnStr='CASE WHEN bt.PRIVACY_PROFILE IN (' + @PrivacyProfileIDList + ') THEN NULL ELSE ' + @returnStr + ' END'
END ELSE IF @RespectPrivacyProfile IS NULL BEGIN
	SET @returnStr='CASE'
		+ ' WHEN bt.MemberID<>' + CAST(@MemberID AS varchar)
			+ ' AND bt.PRIVACY_PROFILE IN (' + @PrivacyProfileIDList + ')'
			+ ' AND EXISTS(SELECT * FROM GBL_BT_SharingProfile shpr INNER JOIN GBL_SharingProfile shp ON shpr.ProfileID=shp.ProfileID AND shp.CanViewPrivate=0 AND shp.ShareMemberID=' + CAST(@MemberID AS varchar) + ' WHERE NUM=bt.NUM)'
		+ ' THEN NULL'
		+ ' ELSE ' + @returnStr + ' END'
END

IF @CanShare=1 BEGIN
	SET @returnStr='CASE WHEN bt.MemberID<>' + CAST(@MemberID AS varchar)
		+ CASE
				WHEN @SharingProfileIDList IS NULL THEN ' THEN NULL'
				ELSE ' AND NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile shp WHERE bt.NUM=shp.NUM AND shp.ProfileID IN (' + @SharingProfileIDList + ')) THEN NULL'
			END + ' ELSE ' + @returnStr + ' END'
END

RETURN @returnStr + CASE WHEN @UseAS=1 THEN ' AS ''' + @FieldName + '''' ELSE '' END

END
GO
