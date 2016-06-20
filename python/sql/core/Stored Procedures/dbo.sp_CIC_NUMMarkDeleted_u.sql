SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMMarkDeleted_u]
	@MODIFIED_BY varchar(50),
	@IdList varchar(max),
	@DeletionDate datetime,
	@MakeNP bit,
	@User_ID int,
	@ViewType int,
	@UseNUM bit,
	@NUM varchar(8) OUTPUT,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 11-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@tmpBTDIDs TABLE (
	BTD_ID int NOT NULL PRIMARY KEY
)

DECLARE @NumAffected int
SET @NumAffected = 0

DECLARE	@Error	int
SET @Error = 0

DECLARE	@OrganizationProgramObjectName nvarchar(100)

SET @OrganizationProgramObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')

IF @IdList = '' OR @IdList IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
END ELSE BEGIN
	IF @UseNUM=1 BEGIN
		INSERT INTO @tmpBTDIDs SELECT DISTINCT btd.BTD_ID
			FROM dbo.fn_GBL_ParseVarCharIDList(@IdList,',') tm
			INNER JOIN GBL_BaseTable_Description btd
				ON tm.ItemID = btd.NUM COLLATE Latin1_General_100_CI_AI AND btd.LangID=@@LANGID
	END ELSE BEGIN
		INSERT INTO @tmpBTDIDs SELECT DISTINCT tm.*
			FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
			INNER JOIN GBL_BaseTable_Description btd
				ON tm.ItemID = btd.BTD_ID
	END
	
	SELECT @NumAffected = COUNT(*) FROM @tmpBTDIDs
	
	IF @NumAffected=0 BEGIN
		SET @Error = 3 -- No Such Record
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @IdList, @OrganizationProgramObjectName)
	END ELSE IF @NumAffected=1 BEGIN
		SELECT @NUM=btd.NUM
			FROM GBL_BaseTable_Description btd
			INNER JOIN @tmpBTDIDs tm
				ON btd.BTD_ID=tm.BTD_ID
	
	END
END

IF @Error=0 BEGIN
	IF EXISTS(SELECT *
			FROM GBL_BaseTable_Description btd
			INNER JOIN @tmpBTDIDs tm
				ON btd.BTD_ID=tm.BTD_ID
			WHERE dbo.fn_CIC_CanUpdateRecord(btd.NUM,@User_ID,@ViewType,btd.LangID,GETDATE())=0) BEGIN
		SET @Error = 8 -- Security Failure
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
	END ELSE BEGIN
		DECLARE @MODIFIED_DATE datetime,
				@NUMList varchar(max)
		
		SET @MODIFIED_DATE = GETDATE()

		SELECT @NUMList = COALESCE(@NUMList+',','') + NUM
			FROM GBL_BaseTable bt
			WHERE EXISTS(
				SELECT *
				FROM GBL_BaseTable_Description btd
				INNER JOIN @tmpBTDIDs tm
					ON btd.BTD_ID=tm.BTD_ID
				WHERE btd.NUM=bt.NUM
			)
	
		UPDATE btd
			SET
				DELETION_DATE	= @DeletionDate,
				DELETED_BY		= @MODIFIED_BY,
				MODIFIED_DATE	= @MODIFIED_DATE,
				MODIFIED_BY		= @MODIFIED_BY,
				NON_PUBLIC		= CASE WHEN NON_PUBLIC=1 OR @MakeNP=1 THEN 1 ELSE 0 END
		FROM GBL_BaseTable_Description btd
		INNER JOIN @tmpBTDIDs tm
			ON btd.BTD_ID=tm.BTD_ID
			
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationProgramObjectName, @ErrMsg
		
		EXEC sp_GBL_BaseTable_History_i_Field @MODIFIED_BY, @MODIFIED_DATE, @NUMList, 'DELETION_DATE', @User_ID, @ViewType, NULL
		EXEC sp_GBL_BaseTable_History_i_Field @MODIFIED_BY, @MODIFIED_DATE, @NUMList, 'DELETED_BY', @User_ID, @ViewType, NULL
	END
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMMarkDeleted_u] TO [cioc_login_role]
GO
