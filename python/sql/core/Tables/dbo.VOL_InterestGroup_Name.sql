CREATE TABLE [dbo].[VOL_InterestGroup_Name]
(
[IG_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_VOL_InterestGroup_Name_d] ON [dbo].[VOL_InterestGroup_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE ig
	FROM VOL_InterestGroup ig
	INNER JOIN Deleted d
		ON ig.IG_ID=d.IG_ID
	WHERE NOT EXISTS(SELECT * FROM VOL_InterestGroup_Name ign WHERE ign.IG_ID=ig.IG_ID)

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[VOL_InterestGroup_Name] ADD CONSTRAINT [PK_VOL_InterestGroup_Name] PRIMARY KEY CLUSTERED  ([IG_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_InterestGroup_Name_UniqueName] ON [dbo].[VOL_InterestGroup_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_InterestGroup_Name] ADD CONSTRAINT [FK_VOL_InterestGroup_Name_VOL_InterestGroup] FOREIGN KEY ([IG_ID]) REFERENCES [dbo].[VOL_InterestGroup] ([IG_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_InterestGroup_Name] ADD CONSTRAINT [FK_VOL_InterestGroup_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[VOL_InterestGroup_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_InterestGroup_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_InterestGroup_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_InterestGroup_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_InterestGroup_Name] TO [cioc_vol_search_role]
GO
