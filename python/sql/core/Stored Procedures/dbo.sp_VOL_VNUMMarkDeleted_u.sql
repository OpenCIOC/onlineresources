SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMMarkDeleted_u]
	@MODIFIED_BY varchar(50),
	@IdList [varchar](max),
	@DeletionDate [datetime],
	@MakeNP [bit],
	@User_ID [int],
	@ViewType [int],
	@UseVNUM bit,
	@VNUM varchar(10) OUTPUT,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@tmpOPDIDs TABLE (
	OPD_ID int NOT NULL PRIMARY KEY
)

DECLARE @NumAffected int
SET @NumAffected = 0

DECLARE	@Error	int
SET @Error = 0

DECLARE	@VolunteerOpportunityObjectName nvarchar(60)

SET @VolunteerOpportunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Opportunity Record')

IF @IdList = '' OR @IdList IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerOpportunityObjectName, NULL)
END ELSE BEGIN
	IF @UseVNUM=1 BEGIN
		INSERT INTO @tmpOPDIDs SELECT DISTINCT vod.OPD_ID
			FROM dbo.fn_GBL_ParseVarCharIDList(@IdList,',') tm
			INNER JOIN VOL_Opportunity_Description vod
				ON tm.ItemID = vod.VNUM COLLATE Latin1_General_100_CI_AI AND vod.LangID=@@LANGID
	END ELSE BEGIN
		INSERT INTO @tmpOPDIDs SELECT DISTINCT vod.OPD_ID
			FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
			INNER JOIN VOL_Opportunity_Description vod
				ON tm.ItemID = vod.OPD_ID
	END

	SELECT @NumAffected = COUNT(*) FROM @tmpOPDIDs
	
	IF @NumAffected=0 BEGIN
		SET @Error = 3 -- No Such Record
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @IdList, @VolunteerOpportunityObjectName)
	END ELSE IF @NumAffected=1 BEGIN
		SELECT @VNUM=vod.VNUM
			FROM VOL_Opportunity_Description vod
			INNER JOIN @tmpOPDIDs tm
				ON vod.OPD_ID=tm.OPD_ID
	END
END

IF @Error=0 BEGIN
	IF EXISTS(SELECT *
			FROM VOL_Opportunity_Description vod 
			INNER JOIN @tmpOPDIDs tm
				ON vod.OPD_ID=tm.OPD_ID
			WHERE dbo.fn_VOL_CanUpdateRecord(vod.VNUM,@User_ID,@ViewType,vod.LangID,GETDATE())=0) BEGIN
		SET @Error = 8 -- Security Failure
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerOpportunityObjectName, NULL)
	END ELSE BEGIN
		DECLARE @MODIFIED_DATE datetime,
				@VNUMList varchar(max)
		
		SET @MODIFIED_DATE = GETDATE()

		SELECT @VNUMList = COALESCE(@VNUMList + ',','') + CAST(VNUM AS varchar)
			FROM VOL_Opportunity vo
			WHERE EXISTS(SELECT *
				FROM VOL_Opportunity_Description vod
				INNER JOIN @tmpOPDIDs tm
					ON vod.OPD_ID=tm.OPD_ID
				WHERE vod.VNUM=vo.VNUM)
	
		UPDATE VOL_Opportunity_Description
			SET
				DELETION_DATE	= @DeletionDate,
				DELETED_BY		= @MODIFIED_BY,
				MODIFIED_DATE	= @MODIFIED_DATE,
				MODIFIED_BY		= @MODIFIED_BY,
				NON_PUBLIC		= CASE WHEN NON_PUBLIC=1 OR @MakeNP=1 THEN 1 ELSE 0 END
		FROM VOL_Opportunity_Description vod INNER JOIN @tmpOPDIDs tm ON vod.OPD_ID=tm.OPD_ID
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerOpportunityObjectName, @ErrMsg
		
		EXEC sp_VOL_Opportunity_History_i_Field @MODIFIED_BY, @MODIFIED_DATE, @VNUMList, 'DELETION_DATE', @User_ID, @ViewType, NULL
		EXEC sp_VOL_Opportunity_History_i_Field @MODIFIED_BY, @MODIFIED_DATE, @VNUMList, 'DELETED_BY', @User_ID, @ViewType, NULL
	END
END

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMMarkDeleted_u] TO [cioc_login_role]
GO
