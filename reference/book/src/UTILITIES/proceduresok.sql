CREATE or REPLACE PACKAGE scanbook_installation 
IS
   FUNCTION give_Install RETURN VARCHAR2;

END scanbook_installation;
/
show errors


CREATE or REPLACE PACKAGE BODY scanbook_installation
IS

FUNCTION give_Install
/*
|| Returns 'OK' if no new programs' installation is running.
|| This function will be replaced automaticly, just before 
|| a new installation will start, to return some other value. 
|| Will be replace again to return 'OK' after the installation ended.
*/
   RETURN VARCHAR2
IS
BEGIN

   RETURN 'OK';

END;

END scanbook_installation;
/
show errors
alter package general_procedures compile ; 







