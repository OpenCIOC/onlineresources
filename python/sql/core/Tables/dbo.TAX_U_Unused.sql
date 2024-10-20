CREATE TABLE [dbo].[TAX_U_Unused]
(
[UT_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [datetime] NOT NULL CONSTRAINT [DF_TAX_Unused_DateCreated] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [datetime] NOT NULL CONSTRAINT [DF_TAX_Unused_DateModified] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Term_en] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Term_fr] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Authorized] [bit] NULL CONSTRAINT [DF_TAX_U_Unused_Authorized] DEFAULT ((0)),
[Active] [bit] NULL CONSTRAINT [DF_TAX_U_Unused_Active] DEFAULT ((1)),
[Source] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_Unused] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_Unused_HasName] CHECK (([Term_en] IS NOT NULL OR [Term_fr] IS NOT NULL))
GO
ALTER TABLE [dbo].[TAX_U_Unused] ADD CONSTRAINT [PK_TAX_U_Unused] PRIMARY KEY CLUSTERED ([UT_ID]) ON [PRIMARY]
GO
