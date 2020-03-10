

Libname AAA 'C:\_MyProjects\AAA\SAS';

/*
proc sql;
describe table aaa.calls_log;
quit;

proc sql;
describe table aaa.member_profile;
quit;
*/

* Plus_Indicator_Description;

proc sql;
describe table aaa.member_profile_cost;
quit;

proc sql;
create table members_values_stage as
(
 select  Household_Key

        ,count(distinct household_key)    as _household_count
        ,count(distinct Individual_Key)   as _memeber_count
        ,sum(_Service_Cnt)       as _service_cnt        format 4.
        ,sum(_Total_Cost)        as _total_cost         format 16.2
        ,sum(Total_Products)     as _total_products

        ,sum(ERS_ENT_Count_Year_1) as _ERS_ENT_Count_Year_1 format 4.
        ,sum(ERS_ENT_Count_Year_2) as _ERS_ENT_Count_Year_2 format 4.
        ,sum(ERS_ENT_Count_Year_3) as _ERS_ENT_Count_Year_3 format 4.
        ,sum(ERS_Member_Cost_Year_1) as _ERS_Member_Cost_Year_1 format 16.2
        ,sum(ERS_Member_Cost_Year_2) as _ERS_Member_Cost_Year_2 format 16.2
        ,sum(ERS_Member_Cost_Year_3) as _ERS_Member_Cost_Year_3 format 16.2

  from aaa.member_profile_cost
  where Member_Status = 'ACTIVE'
 group by Household_Key
);
quit;

proc sql;
create table ERS_lkup as
(
select   Household_Key 
        ,sum( _Service_Cnt, _ERS_ENT_Count_Year_1, _ERS_ENT_Count_Year_2, _ERS_ENT_Count_Year_3) as _ERS_Service_Cnt
        ,sum( _Total_Cost, _ERS_Member_Cost_Year_1, _ERS_Member_Cost_Year_2, _ERS_Member_Cost_Year_3) as _ERS_Service_Cost
from members_values_stage
group by Household_Key
);
quit;

proc sql;
create table members_values as
(
select  a.*
       ,b._ERS_Service_Cnt
       ,b._ERS_Service_Cost
       , case when b._ERS_Service_Cnt = 0 and b._ERS_Service_Cost = 0 then 'N'
              else 'Y'
          end as _Has_ERS_Service

from members_values_stage a
join ERS_lkup b
  on a.Household_Key = b.Household_Key
);
quit;



proc sql;
create table members_values as
(
select  distinct
        a.*
        , case when coalesce(a._ERS_Service_Cnt,0) = 0 and
                    coalesce(a._ERS_Service_Cost,0.00) = 0.00 then 
                    'N'
               else 'Y'
           end as _Has_ERS_Service

  from members_values_stage a
) order by Household_Key
;
quit;

*********************************************************************************
* Pick a individual key from the household to avoid duplicate recourds
*********************************************************************************;
proc sql;
create table all_household as
(
 select  distinct a.Household_Key
  from aaa.member_profile_cost a
  where Member_Status = 'ACTIVE'
    and Member_Type = 'Primary'
);
quit;

proc sql;
create table is_household as
(
select distinct a.household_key
from members_values a
where household_key not in ( select household_key from all_household )
) order by household_key
;
quit;

proc sql;
create table household_ref as
(
select a.Household_Key, min(a.Individual_Key) as Individual_Key
  from aaa.member_profile_cost a
  join is_household b
    on a.Household_Key = b.Household_Key
 where a.Member_Status = 'ACTIVE'
 group by 1
);
quit;

proc sql;
create table Primary_Members as
(
 select distinct 
         a.Household_Key
        ,a.Individual_Key
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
        ,a.Number_of_Children
        ,a.Responded_to_Catalog
        ,a.Race
        ,a.Length_Of_Residence
        ,a.Mail_Responder
        ,a.Home_Owner
        ,a.Income
        ,a.Date_Of_Birth
/*        ,case when a.Age eq -1 then 73 else a.Age end as Age*/
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

  from aaa.member_profile_cost a
  where a.Member_Status = 'ACTIVE'
    and ( a.Member_Type = 'Primary' or a.Individual_Key in (select distinct Individual_Key from household_ref ))
    and a.Household_Key not in ( 8623740, 18125627, 37679208, 99800577 )
);
quit;

proc sql;
create table mlevel_stage as
(
select  distinct 
        x.Household_Key, 
        x.Individual_Key, 
        x.Plus_Indicator_Description,
        x.SC_Date
from aaa.member_sample x
join Primary_Members y
  on x.Household_Key = y.Household_Key
 and x.Individual_Key = y.Individual_Key

where x.Member_Status = 'ACTIVE'
  and x.Call_Canceled = 'N'
  and x.Plus_Indicator_Description is not null
) order by 1;
quit;

proc sql;
select count( distinct Household_Key ) as cnt
from Primary_Members
;
quit;

proc sql;
create table mlevel_lkup as
(
select  x.Household_Key, 
        max(x.Plus_Indicator_Description) as Membership_Level
   from mlevel_stage x
   join ( select Individual_Key, max( SC_Date ) as max_dt format date9.
            from mlevel_stage
           group by 1
        ) y
     on x.Individual_Key = y.Individual_Key
    and x.SC_Date = y.max_dt
    group by 1
) order by Household_Key;
quit;


proc sql;
create table aaa.household_profile_cost as
(
select a.*
        ,case when c.Membership_Level is null then 'Basic'
              when Membership_Level = 'Plus Membership' then 'Plus'
              when Membership_Level = 'Plus Membership with Motorcycle Coverage' then 'PlusBike'
              when Membership_Level = 'Premier Membership' then 'Premier'
              else 'Basic'
          end as Membership_Level

        ,case when c.Household_Key is null then 'N'
              else 'Y'
          end as Roadside_Service

        ,b._household_count
        ,b._memeber_count
        ,b._service_cnt
        ,b._total_cost
        ,b._total_products

        ,b._ERS_ENT_Count_Year_1
        ,b._ERS_ENT_Count_Year_2
        ,b._ERS_ENT_Count_Year_3
        ,b._ERS_Member_Cost_Year_1
        ,b._ERS_Member_Cost_Year_2
        ,b._ERS_Member_Cost_Year_3
        ,b._ERS_Service_Cnt
        ,b._ERS_Service_Cost
        ,b._Has_ERS_Service

from Primary_Members a
join members_values b
  on a.Household_Key = b.Household_Key
left outer join mlevel_lkup c
  on a.Household_Key = c.Household_Key
) order by Household_Key
;
quit;


******************************************************************;
* active memeber count   = 5309
* household count        = 3215
******************************************************************;

proc sql;
select  count(distinct Household_Key) as _household_cnt format 22.2, 
        sum( _household_count)        as _household_count format 22.2,
        sum(_memeber_count)           as _memeber_cnt   format 22.2
from aaa.household_profile_cost
;
quit;


%let out=household_profile_cost;
proc export
  data = aaa.&out.
  dbms=csv
  outfile = "C:\_MyProjects\AAA\data\AAA_&out..csv" 
  replace;
run;



