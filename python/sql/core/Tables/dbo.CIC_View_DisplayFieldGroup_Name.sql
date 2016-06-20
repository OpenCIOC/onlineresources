CREATE TABLE [dbo].[CIC_View_DisplayFieldGroup_Name]
(
[DisplayFieldGroupID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_View_DisplayFieldGroup_Name_d] ON [dbo].[CIC_View_DisplayFieldGroup_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE fg
	FROM CIC_View_DisplayFieldGroup fg
	INNER JOIN Deleted d
		ON fg.DisplayFieldGroupID=d.DisplayFieldGroupID
	WHERE NOT EXISTS(SELECT * FROM CIC_View_DisplayFieldGroup_Name fgn WHERE fgn.DisplayFieldGroupID=fg.DisplayFieldGroupID)

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_View_DisplayFieldGroup_Name] ADD CONSTRAINT [PK_CIC_View_DisplayFieldGroup_Name] PRIMARY KEY CLUSTERED  ([DisplayFieldGroupID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_DisplayFieldGroup_Name] ADD CONSTRAINT [FK_CIC_View_DisplayFieldGroup_Name_CIC_View_DisplayFieldGroup] FOREIGN KEY ([DisplayFieldGroupID]) REFERENCES [dbo].[CIC_View_DisplayFieldGroup] ([DisplayFieldGroupID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_DisplayFieldGroup_Name] ADD CONSTRAINT [FK_CIC_View_DisplayFieldGroup_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_View_DisplayFieldGroup_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_View_DisplayFieldGroup_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_View_DisplayFieldGroup_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_View_DisplayFieldGroup_Name] TO [cioc_login_role]
GO
