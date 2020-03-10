

Libname AAA 'C:\_MyProjects\AAA\SAS';


********************************************************************
* members with the most rececent join AAA date
********************************************************************;

proc sql;
create table aaa.most_recent_AAA as
(
select a.*
from aaa.member_sample a
join 
( select individual_key
, max( Join_AAA_Date ) as max_dt
  from aaa.member_sample
  group by 1
) b
on a.individual_key = b.individual_key
and a.Join_AAA_Date = b.max_dt
);
quit;

********************************************************************
* number of individual memebers
* 11,902
********************************************************************;

proc sql;
select count(distinct individual_key) as members, count(*) as cnt
from aaa.most_recent_AAA
;
quit;

********************************************************************
* there are multiple Member_Phone_Type in some of memebers
* if it has more than one type, default it as wire 
********************************************************************;

proc sql;
create table dummy_phone_type as
(
select Individual_Key, sum(Phone_Type_Cnt) as Phone_Type_Cnt
from 
(
select distinct 
Individual_Key, 
Member_Phone_Type, 
1 as Phone_Type_Cnt
from aaa.most_recent_AAA 
) x
group by 1
);
quit;


proc sql;
create table dummy_Member_Status as
(
select Individual_Key, sum(Member_Status_Cnt) as Member_Status_Cnt
from 
(
select distinct 
Individual_Key, 
Member_Status, 
1 as Member_Status_Cnt
from aaa.most_recent_AAA 
) x
group by 1
);
quit;

********************************************************************
* default multiple member types to Primary
********************************************************************;

proc sql;
create table dummy_Member_Type as
(
select Individual_Key, sum(Member_Type_Cnt) as Member_Type_Cnt
from 
(
select distinct 
Individual_Key, 
Member_Type, 
1 as Member_Type_Cnt
from aaa.most_recent_AAA 
) x
group by 1
);
quit;

********************************************************************
* default multiple Renew_Method to 'AUTO RENEW'
********************************************************************;

proc sql;
create table dummy_Renew_Method as
(
select Individual_Key, sum(Renew_Method_Cnt) as Renew_Method_Cnt
from 
(
select distinct 
Individual_Key, 
Renew_Method, 
1 as Renew_Method_Cnt
from aaa.most_recent_AAA 
) x
group by 1
);
quit;

proc sql;
create table AAA.ESR_LKUP as
(
select  Individual_Key

        , sum(ERS_ENT_Count_Year_1) as ERS_ENT_Count_Year_1
        , sum(ERS_ENT_Count_Year_2) as ERS_ENT_Count_Year_2
        , sum(ERS_ENT_Count_Year_3) as ERS_ENT_Count_Year_3
        , sum(ERS_Member_Cost_Year_1) as ERS_Member_Cost_Year_1
        , sum(ERS_Member_Cost_Year_2) as ERS_Member_Cost_Year_2
        , sum(ERS_Member_Cost_Year_3) as ERS_Member_Cost_Year_3

  from AAA.member_sample
 group by 1
)
;
quit;


******************************************************************;
* reset age = -1 to null
******************************************************************;

proc sql;
create table aaa.member_profile as
(
select distinct
a.Household_Key
,a.Individual_Key
,1 as Individual_Cnt
,City
,State___Grouped as State_Grouped
,ZIP5
,ZIP9

,FSV_CMSI_Flag
,FSV_Credit_Card_Flag
,FSV_Deposit_Program_Flag
,FSV_Home_Equity_Flag
,FSV_ID_Theft_Flag
,FSV_Mortgage_Flag
,INS_Client_Flag
,TRV_Globalware_Flag
,Total_Products

,Number_of_Children
,Responded_to_Catalog
,Race
,Length_Of_Residence
,Mail_Responder
,Home_Owner
,Income

,Date_Of_Birth format yymmdd10.

,case when Age eq -1 then .
      else Age
 end as Age

,Children
,Education
,Dwelling_Type
,Credit_Ranges
,Language
,Gender

,Branch_Name
,County

,datepart(Join_AAA_Date) as Join_AAA_Date format yymmdd10.

, case when b.Phone_Type_Cnt > 1 then 'Wire'
       else a.Member_Phone_Type
end as Member_Phone_Type

, case when m.Member_Status_Cnt > 1 then 'UNKONOW'
       else a.Member_Status
end as Member_Status

,Member_Tenure_Years

, case when t.Member_Type_Cnt > 1 then 'Primary'
       else a.Member_Type
end as Member_Type

,datepart(Reinstate_Date) as Reinstate_Date format yymmdd10.

, case when r.Renew_Method_Cnt > 1 then 'AUTO RENEW'
       else a.Renew_Method
end as Renew_Method


,ZIP

,Mosaic_Household
,Mosaic_Global_Household

,kcl_B_IND_MosaicsGrouping

,New_Mover_Flag
,Occupation_Code
,Occupation_Group
,Right_Dwelling_Type
,Move_Distance
,Occupant_Type

,e.ERS_ENT_Count_Year_1
,e.ERS_ENT_Count_Year_2
,e.ERS_ENT_Count_Year_3
,e.ERS_Member_Cost_Year_1
,e.ERS_Member_Cost_Year_2
,e.ERS_Member_Cost_Year_3


from aaa.most_recent_AAA a
join dummy_phone_type b
  on a.Individual_Key = b.Individual_Key

join dummy_Member_Status m
  on a.Individual_Key = m.Individual_Key

join dummy_Member_Type t
  on a.Individual_Key = t.Individual_Key

join dummy_Renew_Method r
  on a.Individual_Key = r.Individual_Key

join AAA.ESR_LKUP e
  on a.Individual_Key = e.Individual_Key

where Household_Key is not null
);
quit;
proc sort data=aaa.member_profile;
by Household_Key Individual_Key;
run;


proc sql;
describe table aaa.member_profile;
quit;

******************************************************************;
* memeber count = 11,902
******************************************************************;

proc sql;
select count(*) as cnt_11902, count(distinct Individual_Key) as Individual_cnt
from aaa.member_profile
;
quit;

/*
%let out=member_profile;
proc export
  data = aaa.&out.
  dbms=csv
  outfile = "C:\_MyProjects\AAA\data\AAA_&out..csv" 
  replace;
run;
*/

