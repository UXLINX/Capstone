

Libname AAA 'C:\_MyProjects\AAA\SAS';

proc sql;
describe table aaa.calls_log;
quit;

proc sql;
describe table aaa.member_profile;
quit;

********************************************************************
* total cost associated with the indivisual members
********************************************************************;
/*
proc sql;
create table test as
(
select *
  from aaa.calls_log
 where Individual_Key = 202825559
   and call_canceled = 'N'

)  order by Call_Status_Recv_Date
;
quit;
*/

proc sql;
create table total_cost_lkup as
(
select Individual_Key 
       ,sum(_Total_Cost)                as _Total_Cost
       ,count( distinct REC_ID)         as _Service_Cnt
  from aaa.calls_log
 where call_canceled = 'N'
 group by 1
);
quit;
proc sort data=total_cost_lkup;
by Individual_Key;
run;

proc sql;
create table aaa.member_profile_cost as
(
select a.*, 

       b._Service_Cnt,
       coalesce(b._Total_Cost,0.00) as _Total_Cost

  from aaa.member_profile a
  left outer join total_cost_lkup b
  on a.Individual_Key = b.Individual_Key
);
quit;

proc sql;
create table aaa.household_profile_cost as
(
 select  a.Household_Key
        ,a.Individual_Key
        ,a.Individual_Cnt
        ,a.City
        ,a.State_Grouped
        ,a.ZIP5
        ,a.ZIP9
        ,a.FSV_CMSI_Flag
        ,a.FSV_Credit_Card_Flag
        ,a.FSV_Deposit_Program_Flag
        ,a.FSV_Home_Equity_Flag
        ,a.FSV_ID_Theft_Flag
        ,a.FSV_Mortgage_Flag
        ,a.INS_Client_Flag
        ,a.TRV_Globalware_Flag
        ,a.Total_Products
        ,a.Number_of_Children
        ,a.Responded_to_Catalog
        ,a.Race
        ,a.Length_Of_Residence
        ,a.Mail_Responder
        ,a.Home_Owner
        ,a.Income
        ,a.Date_Of_Birth
        ,a.Age
        ,a.Children
        ,a.Education
        ,a.Dwelling_Type
        ,a.Credit_Ranges
        ,a.Language
        ,a.Gender
        ,a.Branch_Name
        ,a.County
        ,a.Join_AAA_Date
        ,a.Member_Phone_Type
        ,a.Member_Status
        ,a.Member_Tenure_Years
        ,a.Member_Type
        ,a.Reinstate_Date
        ,a.Renew_Method
        ,a.ZIP
        ,a.Mosaic_Household
        ,a.Mosaic_Global_Household
        ,a.kcl_B_IND_MosaicsGrouping
        ,a.New_Mover_Flag
        ,a.Occupation_Code
        ,a.Occupation_Group
        ,a.Right_Dwelling_Type
        ,a.Move_Distance
        ,a.Occupant_Type
        ,a.ERS_ENT_Count_Year_1
        ,a.ERS_ENT_Count_Year_2
        ,a.ERS_ENT_Count_Year_3
        ,a.ERS_Member_Cost_Year_1
        ,a.ERS_Member_Cost_Year_2
        ,a.ERS_Member_Cost_Year_3

        ,b._Service_Cnt,
        ,coalesce(b._Total_Cost,0.00) as _Total_Cost

  from aaa.member_profile a
  left outer join total_cost_lkup b
  on a.Individual_Key = b.Individual_Key
);
quit;

proc sql;
describe table aaa.member_profile_cost;
quit;


******************************************************************;
* memeber count = 11,902
******************************************************************;

proc sql;
select count(*) as cnt_11902, count(distinct Individual_Key) as Individual_cnt
from aaa.member_profile_cost
;
quit;


/*
%let out=member_profile_cost;
proc export
  data = aaa.&out.
  dbms=csv
  outfile = "C:\_MyProjects\AAA\data\AAA_&out..xlsx" 
  replace;
run;
*/


%let out=member_profile_cost;
proc export
  data = aaa.&out.
  dbms=csv
  outfile = "C:\_MyProjects\AAA\data\AAA_&out..csv" 
  replace;
run;

