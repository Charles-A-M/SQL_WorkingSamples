
create table system.cod_ServerErrorsLog( 
	id number, 
	logDate timestamp,
	sysEvent varchar2(200),
	oraUser varchar2(200),
	oraError varchar2(4000),
	msg varchar2(4000) 
);

create sequence system.seq_cod_ServerErrorsLog;

create or replace trigger t_cod_ServerErrors
    after servererror on database
    declare
		sql_text 	ora_name_list_t;
		v_sql		varchar2(4000) := '';
		v_err		varchar2(4000) := '';
    begin
        -- https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:2975793633621#284628100346267414
		-- http://www.nazmulhuda.info/capture-failed-sql-using-servererror-trigger
		
		for depth in 1 .. ora_server_error_depth loop
			v_err := v_err || ora_server_error_msg(depth);
		end loop;
		for i in 1 .. ora_sql_txt(sql_text) loop
			v_sql := v_sql || sql_text(i);
		end loop;
		
		insert into system.cod_ServerErrorsLog (id, logdate, sysevent, oraUser, oraError, msg) values 
			(system.seq_cod_ServerErrorsLog.nextval, SYSTIMESTAMP, ora_sysevent, ora_login_user, v_err, v_sql );
		
	end;
  /
