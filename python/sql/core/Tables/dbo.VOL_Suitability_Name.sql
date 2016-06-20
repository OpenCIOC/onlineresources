CREATE TABLE [dbo].[VOL_Suitability_Name]
(
[SB_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_VOL_Suitability_Name_d] ON [dbo].[VOL_Suitability_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE sb
	FROM VOL_Suitability sb
	INNER JOIN Deleted d
		ON sb.SB_ID=d.SB_ID
	WHERE NOT EXISTS(SELECT * FROM VOL_Suitability_Name sbn WHERE sbn.SB_ID=sb.SB_ID)
		AND NOT EXISTS(SELECT * FROM VOL_OP_SB pr WHERE pr.SB_ID=sb.SB_ID)

INSERT INTO VOL_Suitability_Name (SB_ID,LangID,[Name])
	SELECT d.SB_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM VOL_Suitability_Name sbn WHERE sbn.SB_ID=d.SB_ID)
			AND EXISTS(SELECT * FROM VOL_OP_SB pr WHERE pr.SB_ID=d.SB_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[VOL_Suitability_Name] ADD CONSTRAINT [PK_VOL_Suitability_Name] PRIMARY KEY CLUSTERED  ([SB_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Suitability_Name_UniqueName] ON [dbo].[VOL_Suitability_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Suitability_Name] ADD CONSTRAINT [FK_VOL_Suitability_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_Suitability_Name] ADD CONSTRAINT [FK_VOL_Suitability_Name_VOL_Suitability] FOREIGN KEY ([SB_ID]) REFERENCES [dbo].[VOL_Suitability] ([SB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Suitability_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Suitability_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Suitability_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_Suitability_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Suitability_Name] TO [cioc_vol_search_role]
GO
