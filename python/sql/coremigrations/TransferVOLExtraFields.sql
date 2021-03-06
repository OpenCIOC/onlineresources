UPDATE VOL_FieldOption SET ExtraFieldType='t' WHERE FIELDName IN ('EXTRA', 'EXTRA_B')
UPDATE VOL_FieldOption SET FieldName='EXTRA_A' WHERE FieldName='EXTRA'

EXEC sp_STP_RegenerateUserFields 2, 'EXTRA_A'
EXEC sp_STP_RegenerateUserFields 2, 'EXTRA_B'

INSERT INTO VOL_OP_EXTRA_TEXT 
		(FieldName, VNUM, LangID, Value)
SELECT 'EXTRA_A', VNUM, LangID, EXTRA AS Value
FROM VOL_Opportunity_Description WHERE EXTRA IS NOT NULL
UNION SELECT 'EXTRA_B', VNUM, LangID, EXTRA_B AS Value
FROM VOL_Opportunity_Description WHERE EXTRA_B IS NOT NULL

INSERT INTO VOL_Feedback_Extra
		(FB_ID, FieldName, Value)

SELECT FB_ID, 'EXTRA_A', EXTRA FROM VOL_Feedback WHERE EXTRA IS NOT NULL
UNION 
SELECT FB_ID, 'EXTRA_B', EXTRA_B FROM VOL_Feedback WHERE EXTRA_B IS NOT NULL

IF NOT EXISTS(SELECT * FROM VOL_OP_EXTRA_TEXT WHERE FieldName='EXTRA_A') BEGIN
	DELETE FROM VOL_FieldOption WHERE FieldName = 'EXTRA_A'
END
IF NOT EXISTS(SELECT * FROM VOL_OP_EXTRA_TEXT WHERE FieldName='EXTRA_B') BEGIN
	DELETE FROM VOL_FieldOption WHERE FieldName = 'EXTRA_B'
END
