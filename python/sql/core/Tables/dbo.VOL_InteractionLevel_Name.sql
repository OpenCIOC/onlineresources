CREATE TABLE [dbo].[VOL_InteractionLevel_Name]
(
[IL_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_VOL_InteractionLevel_Name_d] ON [dbo].[VOL_InteractionLevel_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE il
	FROM VOL_InteractionLevel il
	INNER JOIN Deleted d
		ON il.IL_ID=d.IL_ID
	WHERE NOT EXISTS(SELECT * FROM VOL_InteractionLevel_Name iln WHERE iln.IL_ID=il.IL_ID)
		AND NOT EXISTS(SELECT * FROM VOL_OP_IL pr WHERE pr.IL_ID=il.IL_ID)

INSERT INTO VOL_InteractionLevel_Name (IL_ID,LangID,[Name])
	SELECT d.IL_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM VOL_InteractionLevel_Name iln WHERE iln.IL_ID=d.IL_ID)
			AND EXISTS(SELECT * FROM VOL_OP_IL pr WHERE pr.IL_ID=d.IL_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[VOL_InteractionLevel_Name] ADD CONSTRAINT [PK_VOL_InteractionLevel_Name] PRIMARY KEY CLUSTERED  ([IL_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_InteractionLevel_Name_UniqueName] ON [dbo].[VOL_InteractionLevel_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_InteractionLevel_Name] ADD CONSTRAINT [FK_VOL_InteractionLevel_Name_VOL_InteractionLevel] FOREIGN KEY ([IL_ID]) REFERENCES [dbo].[VOL_InteractionLevel] ([IL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_InteractionLevel_Name] ADD CONSTRAINT [FK_VOL_InteractionLevel_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[VOL_InteractionLevel_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_InteractionLevel_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_InteractionLevel_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_InteractionLevel_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_InteractionLevel_Name] TO [cioc_vol_search_role]
GO
