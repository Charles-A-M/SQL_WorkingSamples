/*
select * from all_tables
where owner in ('ION', 'INFORION', 'InforION')
order by owner, table_name;
*/
-- https://oracle-base.com/articles/9i/export-blob-9i
DECLARE
  l_file      UTL_FILE.FILE_TYPE;
  l_buffer    RAW(32767);
  l_amount    BINARY_INTEGER := 32767;
  l_pos       INTEGER := 1;
  l_blob      BLOB;
  l_blob_len  INTEGER;
BEGIN
  -- Get LOB locator
  SELECT c_xml
  INTO   l_blob
  FROM   ion.cor_inbox_entry
  WHERE  rownum = 1;

  l_blob_len := DBMS_LOB.getlength(l_blob);
  
  -- Open the destination file.
  --l_file := UTL_FILE.fopen('BLOB_DIR','MyImage.gif','w', 32767);
  l_file := UTL_FILE.fopen('COD_DUMP_DIR','Cor_Inbox_Entry.xml','wb', 32767);

  -- Read chunks of the BLOB and write them to the file
  -- until complete.
  WHILE l_pos <= l_blob_len LOOP
    DBMS_LOB.read(l_blob, l_amount, l_pos, l_buffer);
    UTL_FILE.put_raw(l_file, l_buffer, TRUE);
    l_pos := l_pos + l_amount;
  END LOOP;
  
  -- Close the file.
  UTL_FILE.fclose(l_file);
  
EXCEPTION
  WHEN OTHERS THEN
    -- Close the file if something goes wrong.
    IF UTL_FILE.is_open(l_file) THEN
      UTL_FILE.fclose(l_file);
    END IF;
    RAISE;
END;
/