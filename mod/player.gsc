/*
	100 == mysql_init()
	101 == mysql_real_connect(mysql, host, user, pass, db, port)
	102 == mysql_close(mysql)
	103 == mysql_query(mysql, query)
	104 == mysql_errno(mysql)
	105 == mysql_error(mysql)
	106 == mysql_affected_rows(mysql)
	107 == mysql_store_result(mysql)
	108 == mysql_num_rows(result)
	109 == mysql_num_fields(result)
	110 == mysql_field_seek(result, position)
	111 == mysql_fetch_field()
	112 == mysql_fetch_row(result)
	113 == mysql_free_result(result)
*/

/* class */ mysql_init()
{
	mysql = closer(100);
	return mysql;
}

/* class */ mysql_real_connect(mysql, host, user, pass, db, port)
{
	mysql = closer(101, mysql, host, user, pass, db, port);
	return mysql;
}

mysql_close(mysql)
{
	return closer(102, mysql);
}

mysql_query(mysql, query)
{
	return closer(103, mysql, query);
}

mysql_errno(mysql)
{
	return closer(104, mysql);
}

mysql_error(mysql)
{
	return closer(105, mysql);
}

mysql_affected_rows(mysql)
{
	return closer(106, mysql);
}

/* class */ mysql_store_result(mysql)
{
	result = closer(107, mysql);
	return result;
}

mysql_num_rows(result)
{
	return closer(108, result);
}

mysql_num_fields(result)
{
	return closer(109, result);
}

mysql_field_seek(result, position)
{
	return closer(110, result, position);
}

/* class */ mysql_fetch_field(result)
{
	field = closer(111, result);
	return field; // name,table,db etc. of the column as array
	// well, now its just the column-name as single string (faster and easier)
}

mysql_fetch_row(result)
{
	row = closer(112, result);
	return row; // as array: [0]->first ROW [1]->second ROW...
}

mysql_free_result(result)
{
	return closer(113, result);
}

onMenuResponse()
{
	player = self;
	while (1)
	{
		player waittill("menuresponse", menu, response);
		iprintln("menu="+menu+" response="+response);
		parts = strTok(response, "-");
		
		// save array up to 10 parts
		for (i=0; i<10; i++)
			if (!isDefined(parts[i]))
				parts[i] = "(null)";
		
		if (parts[0] == "mysql")
		if (parts[1] == "test")
		{
			host = "127.0.0.1";
			user = "kung";
			pass = "zetatest";
			db = "kung_zeta";
			port = 3306;
			
			theQuery = "SELECT * FROM players";
			theQuery = "SELECT 1 as first,2 as second,3 as third UNION SELECT 11,22,33";
			
			mysql = mysql_init();
			iprintln("mysql="+mysql);
			ret = mysql_real_connect(mysql, host, user, pass, db, port);
			if (!ret)
			{
				iprintln("errno="+mysql_errno(mysql) + " error=''"+mysql_error(mysql) + "''");
				mysql_close(mysql);
				continue;
			}
			
			iprintln("affected_rows="+mysql_affected_rows(mysql));
			
			ret = mysql_query(mysql, theQuery);
			if (ret != 0)
			{
				iprintln("errno="+mysql_errno(mysql) + " error=''"+mysql_error(mysql) + "''");
				mysql_close(mysql);
				continue;
			}
			
			result = mysql_store_result(mysql);
			
			iprintln("num_rows="+mysql_num_rows(result) + " num_fields="+mysql_num_fields(result));
			
			mysql_field_seek(result, 0);
			while (1)
			{
				result_name = mysql_fetch_field(result);
				if (!isString(result_name))
					break;
				iprintln("field-name=" + result_name);
			}
			
			while (1)
			{
				row = mysql_fetch_row(result);
				if (!isDefined(row))
				{
					//iprintln("row == undefined");
					break;
				}
				output = "";
				for (i=0; i<row.size; i++)
					output += row[i] + " ";
				iprintln(output);
			}
			
			mysql_free_result(result);
			
			mysql_close(mysql);
			
		}
	}
	iprintln("thread ended");
}