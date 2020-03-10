

Libname AAA 'C:\_MyProjects\AAA\SAS';


proc sql;
create table aaa.agg_member_profile as
(
select 
Member_Status
,Member_Tenure_Years
,Age
,Education
,sum( Individual_Cnt ) as Individual_Cnt

from aaa.member_profile
group by 1, 2, 3, 4

);
quit;


%let out=agg_member_profile;
proc export
  data = aaa.&out.
  dbms=csv
  outfile = "C:\_MyProjects\AAA\data\AAA_&out..csv" 
  replace;
run;


