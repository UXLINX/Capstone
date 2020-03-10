


Libname AAA 'C:\_MyProjects\AAA\SAS';

proc sql;
describe table aaa.member_profile_cost;
quit;

/*
proc sql;
select distinct Member_Status
  from aaa.member_profile_cost
;
quit;
*/

proc sql;
create table aaa.bank_mimic as
(
select distinct 
        Occupation_Group as job,
        education,
        age,
        case when Home_Owner eq 'Home Owner' then 'Y'
             else 'N' end as housing,
        Children,
        Member_Tenure_Years as duration,
        case when Member_Status = 'ACTIVE' then 'Y'
             else 'N'
         end as y

  from  aaa.member_profile_cost
);
quit;

%let out=bank_mimic;
proc export
  data = aaa.&out.
  dbms=csv
  outfile = "C:\_MyProjects\AAA\_scikit_chapters_ipynb\ch2\data\AAA_&out..csv"
  replace;
run;

/*
%let out=bank_mimic;
proc export
  data = aaa.&out.
  dbms=csv
  outfile = "C:\_MyProjects\AAA\data\AAA_&out..csv" 
  replace;
run;
*/

