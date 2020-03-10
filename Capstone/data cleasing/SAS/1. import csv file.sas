
Libname AAA 'C:\_MyProjects\AAA\SAS';

*****************************************************************************************
* Import excel file
*****************************************************************************************;


PROC IMPORT OUT=AAA.member_sample
        DATAFILE="C:\_MyProjects\AAA\data\5.member_age.xlsx"
	DBMS=EXCEL REPLACE;
	SHEET="5.member_age";
	GETNAMES=YES;
run;

proc sql;
describe table AAA.member_sample;
quit;
