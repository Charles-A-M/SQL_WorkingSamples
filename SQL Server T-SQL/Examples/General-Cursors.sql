 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	General Use code
 
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 THROW 51000, 'Why are you here?', 1;  
 -- 	Cursors
		Declare @TableName 	varchar(500);
		Declare @ColumnID  	int;
		Declare @ColumnName	nvarchar(500);
		declare @ColumnType nvarchar(500);
		
		Declare c_TableColumns Cursor For
		select top 20	
			t.Name TableName, c.column_id, c.name ColumnName, ty.name TypeName
		from sys.tables				t
		inner join sys.all_columns	c	on c.object_id = t.object_id
		inner join sys.types		ty	on ty.user_type_id = c.user_type_id
		where is_ms_shipped = 0
		order by t.Name, c.column_id;
	
		Open c_TableColumns;
		Fetch Next From c_TableColumns Into @TableName, @ColumnID, @ColumnName, @ColumnType;
		While @@FETCH_STATUS = 0
		begin
			print @TableName + '.' + @ColumnName + ' ' + @ColumnType + '   --   ' + cast(@ColumnID as nvarchar);
			Fetch Next From c_TableColumns Into @TableName, @ColumnID, @ColumnName, @ColumnType;
		end;
		Close c_TableColumns;
		Deallocate c_TableColumns;