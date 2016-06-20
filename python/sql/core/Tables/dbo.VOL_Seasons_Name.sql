CREATE TABLE [dbo].[VOL_Seasons_Name]
(
[SSN_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_VOL_Seasons_Name_d] ON [dbo].[VOL_Seasons_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE ssn
	FROM VOL_Seasons ssn
	INNER JOIN Deleted d
		ON ssn.SSN_ID=d.SSN_ID
	WHERE NOT EXISTS(SELECT * FROM VOL_Seasons_Name ssnn WHERE ssnn.SSN_ID=ssn.SSN_ID)
		AND NOT EXISTS(SELECT * FROM VOL_OP_SSN pr WHERE pr.SSN_ID=ssn.SSN_ID)

INSERT INTO VOL_Seasons_Name (SSN_ID,LangID,[Name])
	SELECT d.SSN_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM VOL_Seasons_Name ssnn WHERE ssnn.SSN_ID=d.SSN_ID)
			AND EXISTS(SELECT * FROM VOL_OP_SSN pr WHERE pr.SSN_ID=d.SSN_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[VOL_Seasons_Name] ADD CONSTRAINT [PK_VOL_Seasons_Name] PRIMARY KEY CLUSTERED  ([SSN_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Seasons_Name_UniqueName] ON [dbo].[VOL_Seasons_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Seasons_Name] ADD CONSTRAINT [FK_VOL_Seasons_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_Seasons_Name] ADD CONSTRAINT [FK_VOL_Seasons_Name_VOL_Seasons] FOREIGN KEY ([SSN_ID]) REFERENCES [dbo].[VOL_Seasons] ([SSN_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Seasons_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Seasons_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Seasons_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_Seasons_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Seasons_Name] TO [cioc_vol_search_role]
GO
