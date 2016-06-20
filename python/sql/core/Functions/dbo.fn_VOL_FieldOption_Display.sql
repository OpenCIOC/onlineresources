SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_FieldOption_Display](
	@MemberID int,
	@ViewType int,
	@FieldID int,
	@FieldName varchar(100),
	@CanShare bit,
	@DisplayFM varchar(max),
	@FormFieldType char(1),
	@EquivalentSource bit,
	@CheckboxOnText nvarchar(20),
	@CheckboxOffText nvarchar(20),
	@UseAS bit
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE @SharingProfileIDList varchar(max),
		@returnStr nvarchar(max)

SET @CanShare = CASE
			WHEN @CanShare=0 THEN 0
			WHEN @MemberID IS NULL THEN 0
			ELSE 1 END

IF @CanShare=1 BEGIN
	SELECT @SharingProfileIDList = CASE
		WHEN @ViewType IS NULL THEN 'NULL'
		ELSE dbo.fn_GBL_SharingProfile_VOL_Fld_l(@MemberID,@ViewType,@FieldID)
	END
END

SET @returnStr = CASE
		WHEN @FormFieldType='c'
			THEN 'CASE WHEN ' + 
				CASE
				WHEN @DisplayFM IS NOT NULL THEN @DisplayFM
				ELSE 'vo' + CASE WHEN @EquivalentSource=1 THEN 'd' ELSE '' END + '.' + @FieldName
			END + '=1 THEN N''' + ISNULL(REPLACE(@CheckboxOnText,'''',''''''),cioc_shared.dbo.fn_SHR_STP_ObjectName('Yes')) + ''' WHEN ' + 
			CASE
				WHEN @DisplayFM IS NOT NULL THEN @DisplayFM
				ELSE 'vo' + CASE WHEN @EquivalentSource=1 THEN 'd' ELSE '' END + '.' + @FieldName
			END + '=0 THEN N''' + ISNULL(REPLACE(@CheckboxOffText,'''',''''''),cioc_shared.dbo.fn_SHR_STP_ObjectName('No')) + ''' END'
		WHEN @DisplayFM IS NOT NULL
			THEN REPLACE(
					REPLACE(@DisplayFM,'[LANGID]',@@LANGID),
					'[MEMBER]',
					CASE WHEN @MemberID IS NULL THEN 'bt.MemberID' ELSE CAST(@MemberID AS varchar) END
				)
		ELSE 'vo' + CASE WHEN @EquivalentSource=1 THEN 'd' ELSE '' END + '.' + @FieldName
	END


IF @CanShare=1 BEGIN
	SET @returnStr='CASE WHEN vo.MemberID<>' + CAST(@MemberID AS varchar)
		+ CASE
				WHEN @SharingProfileIDList IS NULL THEN ' THEN NULL'
				ELSE ' AND NOT EXISTS(SELECT * FROM VOL_OP_SharingProfile shp WHERE vo.VNUM=shp.VNUM AND shp.ProfileID IN (' + @SharingProfileIDList + ')) THEN NULL'
			END + ' ELSE ' + @returnStr + ' END'
END

RETURN @returnStr + CASE WHEN @UseAS=1 THEN ' AS ''' + @FieldName + '''' ELSE '' END

END
GO
