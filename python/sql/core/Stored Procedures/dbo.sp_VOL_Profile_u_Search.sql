SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_u_Search]
	@ProfileID [uniqueidentifier],
	@NotifyNew bit,
	@NotifyUpdated bit,
	@BirthDate smalldatetime,
	@SCH_M_Morning bit,
	@SCH_M_Afternoon bit,
	@SCH_M_Evening bit,
	@SCH_TU_Morning bit,
	@SCH_TU_Afternoon bit,
	@SCH_TU_Evening bit,
	@SCH_W_Morning bit,
	@SCH_W_Afternoon bit,
	@SCH_W_Evening bit,
	@SCH_TH_Morning bit,
	@SCH_TH_Afternoon bit,
	@SCH_TH_Evening bit,
	@SCH_F_Morning bit,
	@SCH_F_Afternoon bit,
	@SCH_F_Evening bit,
	@SCH_ST_Morning bit,
	@SCH_ST_Afternoon bit,
	@SCH_ST_Evening bit,
	@SCH_SN_Morning bit,
	@SCH_SN_Afternoon bit,
	@SCH_SN_Evening bit,
	@AI_IDList varchar(max),
	@CM_IDList varchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@VolunteerProfileObjectName nvarchar(100)

SET @VolunteerProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Profile')

IF @BirthDate > GETDATE() SET @BirthDate = NULL

-- Profile ID given ?
IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @VolunteerProfileObjectName)
END ELSE BEGIN
	UPDATE VOL_Profile
	SET	MODIFIED_DATE		= GETDATE(),
		NotifyNew			= ISNULL(@NotifyNew, NotifyNew),
		NotifyUpdated		= ISNULL(@NotifyUpdated, NotifyUpdated),
		BirthDate			= @BirthDate,
		SCH_M_Morning		= ISNULL(@SCH_M_Morning, SCH_M_Morning),
		SCH_M_Afternoon		= ISNULL(@SCH_M_Afternoon, SCH_M_Afternoon),
		SCH_M_Evening		= ISNULL(@SCH_M_Evening, SCH_M_Evening),
		SCH_TU_Morning		= ISNULL(@SCH_TU_Morning, SCH_TU_Morning),
		SCH_TU_Afternoon	= ISNULL(@SCH_TU_Afternoon, SCH_TU_Afternoon),
		SCH_TU_Evening		= ISNULL(@SCH_TU_Evening, SCH_TU_Evening),
		SCH_W_Morning		= ISNULL(@SCH_W_Morning, SCH_W_Morning),
		SCH_W_Afternoon		= ISNULL(@SCH_W_Afternoon, SCH_W_Afternoon),
		SCH_W_Evening		= ISNULL(@SCH_W_Evening, SCH_W_Evening),
		SCH_TH_Morning		= ISNULL(@SCH_TH_Morning, SCH_TH_Morning),
		SCH_TH_Afternoon	= ISNULL(@SCH_TH_Afternoon, SCH_TH_Afternoon),
		SCH_TH_Evening		= ISNULL(@SCH_TH_Evening, SCH_TH_Evening),
		SCH_F_Morning		= ISNULL(@SCH_F_Morning, SCH_F_Morning),
		SCH_F_Afternoon		= ISNULL(@SCH_F_Afternoon, SCH_F_Afternoon),
		SCH_F_Evening		= ISNULL(@SCH_F_Evening, SCH_F_Evening),
		SCH_ST_Morning		= ISNULL(@SCH_ST_Morning, SCH_ST_Morning),
		SCH_ST_Afternoon	= ISNULL(@SCH_ST_Afternoon, SCH_ST_Afternoon),
		SCH_ST_Evening		= ISNULL(@SCH_ST_Evening, SCH_ST_Evening),
		SCH_SN_Morning		= ISNULL(@SCH_SN_Morning, SCH_SN_Morning),
		SCH_SN_Afternoon	= ISNULL(@SCH_SN_Afternoon, SCH_SN_Afternoon),
		SCH_SN_Evening		= ISNULL(@SCH_SN_Evening, SCH_SN_Evening)
	WHERE ProfileID=@ProfileID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerProfileObjectName, @ErrMsg

	DECLARE @tmpInterestList TABLE(AI_ID int)

	INSERT INTO @tmpInterestList SELECT DISTINCT tm.*
		FROM dbo.fn_GBL_ParseIntIDList(@AI_IDList,',') tm
		INNER JOIN VOL_Interest i ON tm.ItemID = i.AI_ID

	DELETE pai
		FROM VOL_Profile_AI pai
		LEFT JOIN @tmpInterestList tm
			ON pai.AI_ID = tm.AI_ID
	WHERE tm.AI_ID IS NULL 
		AND ProfileID=@ProfileID
		
	INSERT INTO VOL_Profile_AI (ProfileID, AI_ID) SELECT ProfileID=@ProfileID, tm.AI_ID
		FROM @tmpInterestList tm
	WHERE NOT EXISTS(SELECT * FROM VOL_Profile_AI pai WHERE ProfileID=@ProfileID AND pai.AI_ID=tm.AI_ID)
	
	DECLARE @tmpCommunityList TABLE(CM_ID int)

	INSERT INTO @tmpCommunityList SELECT DISTINCT tm.*
		FROM dbo.fn_GBL_ParseIntIDList(@CM_IDList,',') tm
		INNER JOIN GBL_Community cm ON tm.ItemID = cm.CM_ID

	DELETE pc
		FROM VOL_Profile_CM pc
		LEFT JOIN @tmpCommunityList tm
			ON pc.CM_ID = tm.CM_ID
	WHERE tm.CM_ID IS NULL 
		AND ProfileID=@ProfileID
		
	INSERT INTO VOL_Profile_CM (ProfileID, CM_ID) SELECT ProfileID=@ProfileID, tm.CM_ID
		FROM @tmpCommunityList tm
	WHERE NOT EXISTS(SELECT * FROM VOL_Profile_CM pc WHERE ProfileID=@ProfileID AND pc.CM_ID=tm.CM_ID)

END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Search] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Search] TO [cioc_vol_search_role]
GO
