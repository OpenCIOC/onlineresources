CREATE TABLE [dbo].[TAX_U_oldCode]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[code] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[oldCode] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_oldCode] ADD CONSTRAINT [PK_TAX_U_oldCode] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
