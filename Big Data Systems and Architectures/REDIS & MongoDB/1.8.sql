create table antetsik.modified_listings (
UserID number,
MonthID number,
ModifiedListing number(1,0)
);
/
create table antetsik.emails_sent (
EmailID varchar2(40),
User_Id number (1,0),
Month_Id number (1,0),
EmailOpened number (1,0)
);
/
--create package specification
create or replace package antetsik.test_pkg as
procedure generate_data;
end test_pkg;
/
--create package body 
create or replace package body antetsik.test_pkg as

procedure generate_data is

loop_counter INTEGER;
BEGIN  
FOR loop_counter IN 1..10000 LOOP 
INSERT INTO emails_sent (User_Id,Month_Id,EmailOpened)
select  round(dbms_random.value(1,12505),0),  round(dbms_random.value(1,3),0) , round(dbms_random.value(0,1),0) from dual; 

INSERT INTO modified_listings (UserID,MonthID,ModifiedListing)
select  round(dbms_random.value(1,9999),0),  round(dbms_random.value(1,3),0) , round(dbms_random.value(0,1),0) from dual; 

END LOOP; 
COMMIT; 
END; 
END;
/
--Execute procedure generate_data
EXECUTE antetsik.test_pkg.generate_data;


--Queries

--1.1 How many users modified their listing on January? 
SELECT COUNT(*) FROM modified_listings WHERE MONTHID = 1 AND MODIFIEDLISTING =1; --1234

--1.2	How many users did NOT modify their listing on January?
SELECT COUNT(*) FROM modified_listings WHERE MONTHID = 1 AND MODIFIEDLISTING =0; --1260

--1.3	How many users received at least one e-mail per month (at least one e-mail in January and at least one e-mail in February and at least one e-mail in March)?
SELECT 
SUM(case when MONTH_ID = 1 THEN 1 ELSE 0 END) AS EMAIL_JAN,
SUM(case when MONTH_ID = 2 THEN 1 ELSE 0 END) AS EMAIL_FEB,
SUM(case when MONTH_ID = 3 THEN 1 ELSE 0 END) AS EMAIL_MAR
FROM emails_sent;

--1.4	How many users received an e-mail on January and March but NOT on February?
SELECT
COUNT(*) AS EMAIL_JAN
FROM emails_sent
WHERE MONTH_ID IN (1,3) 
AND 
USER_ID NOT IN (SELECT USER_ID FROM emails_sent WHERE MONTH_ID = 2);

--1.5	How many users received an e-mail on January that they did not open but they updated their listing anyway?
SELECT
COUNT(*) AS EMAIL_JAN
FROM emails_sent EM,
modified_listings ML
WHERE EM.MONTH_ID = 1
AND EM.EMAILOPENED = 0
AND EM.USER_ID = ML.USERID
AND ML.MODIFIEDLISTING = 0;

--1.6	How many users received an e-mail on January that they did not open but they updated their listing anyway on January OR 
--they received an e-mail on February that they did not open but they updated their listing anyway on February OR they received an e-mail on March that they did not open but they updated their listing anyway on March?
SELECT
COUNT(*)  AS EMAIL_JAN 
FROM emails_sent EM,
modified_listings ML
WHERE EM.USER_ID = ML.USERID
AND EM.EMAILOPENED = 0 
AND ML.MODIFIEDLISTING = 1
AND MONTH_ID IN (1,2,3);

--1.7	Does it make any sense to keep sending e-mails with recommendations to sellers? Does this strategy really work?
-- How would you describe this in terms a business person would understand?
--January
SELECT 
(SUM(case when EMAILOPENED = 1 AND MODIFIEDLISTING = 1 THEN 1 ELSE 0 END) / SUM(case when EMAILOPENED = 1 THEN 1 ELSE 0 END))*100
FROM emails_sent EM,
modified_listings ML
WHERE EM.USER_ID = ML.USERID
AND MONTH_ID = 1;

--February
SELECT 
(SUM(case when EMAILOPENED = 1 AND MODIFIEDLISTING = 1 THEN 1 ELSE 0 END) / SUM(case when EMAILOPENED = 1 THEN 1 ELSE 0 END))*100
FROM emails_sent EM,
modified_listings ML
WHERE EM.USER_ID = ML.USERID
AND MONTH_ID = 2;

--March
SELECT 
(SUM(case when EMAILOPENED = 1 AND MODIFIEDLISTING = 1 THEN 1 ELSE 0 END) / SUM(case when EMAILOPENED = 1 THEN 1 ELSE 0 END))*100
FROM emails_sent EM,
modified_listings ML
WHERE EM.USER_ID = ML.USERID
AND MONTH_ID = 3;
