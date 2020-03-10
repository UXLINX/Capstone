
Libname AAA 'C:\_MyProjects\AAA\SAS';

*****************************************************************************************
* Import excel file
*****************************************************************************************;

%let rpt = 'C:\_MyProjects\AAA\data\5.member_age';

proc import out=AAA
datafile = "&rpt."
    dbms = csv replace;
getnames = YES;
run;
