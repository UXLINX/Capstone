

Libname AAA 'C:\_MyProjects\AAA\SAS';


proc sql;
create table aaa.profile_lkup as
(
select distinct 
        Individual_Key
        ,City
        ,State_Grouped
        ,ZIP

  from aaa.member_profile
)order by Individual_Key
;
quit;

***********************************************************************
*  Filter out Call_Status_Recv_Date is null
*  13,950 records
**********************************************************************;

proc sql;
create table aaa.calls_log as
(
select distinct 
p.*
,Breakdown_City
,Breakdown_State
,Basic_Cost                             as _Basic_Cost
,Calculated_Tow_Miles                   as _Calculated_Tow_Miles
,Call_Canceled
,Call_Killed
,datepart(Call_Status_Recv_Date) as Call_Status_Recv_Date format yymmdd10.


,Cash_Call
,Clearing_Code_Last_Description
,Dispatch_Code1_Description
,Dispatch_Code2Description
,DTL_Prob1_Code_Description

,Fleet_Indicator
,Is_Duplicate
,Is_NSR
,Member_Match_Flag
,Member_Number_and_Associate_ID
,Motorcycle_Indicator
,Plus_Cost                              as _Plus_Cost
,Plus_Indicator_Description
,Premier_Cost                           as _Premier_Cost
,Prob1_Code_Description
,Prob2_Code_Description
,SC_Call_Club_Code_Description

,datepart(SC_Date) as SC_Date format yymmdd10.

,Rec_ID
,SC_STS_RSN_Code_Description 
,UPPER(SC_Vehicle_Manufacturer_Name) as SC_Vehicle_Manufacturer_Name

,SC_Vehicle_Model_Name
,SVC_Facility_Name
,SVC_Facility_Type
,Total_Cost                             as _Total_Cost
,Tow_Destination_Latitude
,Tow_Destination_Longitude
,Tow_Destination_Name
,Was_Duplicated
,Was_Towed_To_AAR_Referral

  from AAA.member_sample x
  join aaa.profile_lkup p
  on x.Individual_Key = p.Individual_Key

 where x.Call_Status_Recv_Date is not null 
) order by 1
;
quit;

/*
proc sql;
select distinct UPPER(SC_Vehicle_Manufacturer_Name) as SC_Vehicle_Manufacturer_Name
from aaa.calls_log
order by 1
;
quit;
*/

/*
%let out=calls_log;
proc export
  data = aaa.&out.
  dbms=excel
  outfile = "C:\_MyProjects\AAA\data\AAA_&out..xlsx" 
  replace;
run;
*/


%let out=calls_log;
proc export
  data = aaa.&out.
  dbms=csv
  outfile = "C:\_MyProjects\AAA\data\AAA_&out..csv" 
  replace;
run;
