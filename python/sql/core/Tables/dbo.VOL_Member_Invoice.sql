CREATE TABLE [dbo].[VOL_Member_Invoice]
(
[VMINV_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[VMEM_ID] [int] NOT NULL,
[InvoiceDate] [smalldatetime] NOT NULL,
[PaymentDueDate] [smalldatetime] NOT NULL,
[InvoiceAmount] [decimal] (9, 2) NOT NULL,
[InvoiceNumber] [varchar] (10) COLLATE Latin1_General_CI_AS NULL,
[InvoiceVoid] [bit] NOT NULL CONSTRAINT [DF_VOL_Member_Invoice_InvoiceVoid] DEFAULT ((0)),
[Notes] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Member_Invoice] WITH NOCHECK ADD CONSTRAINT [CK_VOL_Member_Invoice_InvoiceAmount] CHECK (([InvoiceAmount]>(0)))
GO
ALTER TABLE [dbo].[VOL_Member_Invoice] ADD CONSTRAINT [PK_VOL_Member_Invoice] PRIMARY KEY CLUSTERED  ([VMINV_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Member_Invoice] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Member_Invoice_VOL_Member_Invoice] FOREIGN KEY ([VMEM_ID]) REFERENCES [dbo].[VOL_Member] ([VMEM_ID])
GO
GRANT SELECT ON  [dbo].[VOL_Member_Invoice] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Member_Invoice] TO [cioc_vol_search_role]
GO
