CREATE TABLE [dbo].[STP_Icon]
(
[Type] [varchar] (25) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_STP_Icon_Type] DEFAULT ('glyphicon'),
[IconName] [varchar] (40) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STP_Icon] ADD CONSTRAINT [PK_STP_Icon] PRIMARY KEY CLUSTERED  ([Type], [IconName]) ON [PRIMARY]
GO
