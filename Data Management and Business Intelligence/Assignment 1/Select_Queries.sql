# A. SHOW THE RESERVATION NUMNER AND THE LOCATION OF ALL RENTALS ON 5/20/2015
#A.1
use crc_fleet; 

SELECT Reservation_ID, Location_ID
FROM reservations as R, locations as L
WHERE R.Pickup_Location_ID = L.Location_ID
AND R.Pickup_Date = '2015-05-20';

#A.2
SELECT Reservation_ID, Pickup_Location_ID , Return_Location_ID 
FROM reservations as R, locations as L
WHERE R.Pickup_Location_ID = L.Location_ID
AND (R.Pickup_Date = '2015-05-20' OR R.Return_Date = '2015-05-20');

# B. SHOW THE FIRST AND THE LAST NAME AND THE MOBILE PHONE NUMBER OF THESE CUSTOMERS THAT HAVE RENTED A CAR IN THE CATEGORY THAT HAS LABEL = 'LUXURY'

SELECT First_Name, Last_Name, Mobile_Phone
FROM customer as Cust, reservations as Resv, car as C, category as Categ
WHERE Cust.Customer_ID = Resv.Customer_ID
AND Resv.Car_ID = C.VIN
AND C.Category_ID = Categ.Category_ID
AND Categ.Label = 'Luxury';

# C. SHOW THE TOTAL AMOUNT OF RENTALS PER LOCATION ID (PICK UP)

SELECT sum(Amount) as Total_Amount, Pickup_Location_ID 
FROM reservations
GROUP BY Pickup_Location_ID;


# D. SHOW THE TOTAL AMOUNT OF RENTALS PER CAR'S CATEGORY ID AND MONTH

SELECT sum(Amount) as Amount, Categ.Category_ID, 
month(R.Pickup_Date) as Month, year(R.Pickup_Date) as Year
FROM reservations as R, category as Categ, car as C
WHERE R.Car_ID = C.VIN
AND C.Category_ID = Categ.Category_ID
GROUP BY Categ.Category_ID, Month, Year
ORDER BY Categ.Category_ID,Year ASC, Month ASC;

# E. FOR EACH RENTAL’S STATE (PICK UP) SHOW THE TOP RENTING CATEGORY

SELECT TOP_CAT.State, TOP_CAT.Label, TOP_CAT.TOP_RENT
FROM
(
	SELECT R.Label, R.State, R.Category_ID, R.TOP_RENT,
	DENSE_RANK() OVER (PARTITION BY R.State ORDER BY R.TOP_RENT DESC) as DR
	FROM
	(
SELECT Cat.Label ,L.State, C.Category_ID, count(C.Category_ID) as TOP_RENT
		FROM locations as L, reservations as R, car as C, category as Cat
		WHERE L.Location_ID = R.Pickup_Location_ID
		AND C.VIN = R.Car_ID
                             AND C.Category_ID = Cat.Category_ID
		GROUP BY L.State, C.Category_ID
		ORDER BY count(C.Category_ID) DESC
	)as R
)TOP_CAT
WHERE TOP_CAT.DR = 1;

# F. SHOW HOW MANY RENTALS THERE WERE IN MAY 2015 IN ‘NY’, ‘NJ’ AND ‘CA’ (IN THREE COLUMNS)

SELECT DISTINCT
count(CASE WHEN L.State = "NY" THEN R.Reservation_ID END) "NY",
count(CASE WHEN L.State = "NJ" THEN R.Reservation_ID END) "NJ",
count(CASE WHEN L.State = "CA" THEN R.Reservation_ID END) "CA"
FROM reservations as R, locations as L
WHERE R.Pickup_Location_ID = L.Location_ID
AND R.Pickup_Date like '2015-05%';

# G. FOR EACH MONTH OF 2015, COUNT HOW MANY RENTALS HAD AMOUNT GREATER THAN THIS  MONTH'S AVERAGE RENTAL AMOUNT

SELECT month(R_OUT.Pickup_Date) as MONTHS, COUNT(*) as ABOVE_AVG
FROM reservations as R_OUT
WHERE R_OUT.Amount > 
(
	SELECT A.AVERAGE_AMOUNT FROM
             (
		SELECT MONTH(R_IN.Pickup_Date) AS INNER_MONTHS, AVG(R_IN.AMOUNT)                     AS AVERAGE_AMOUNT
		FROM reservations as R_IN
		WHERE YEAR(R_IN.Pickup_Date)=2015
		GROUP BY MONTH(R_IN.Pickup_Date)
	)A
              WHERE INNER_MONTHS = MONTH(R_OUT.Pickup_Date)
)
AND YEAR(R_OUT.Pickup_Date)=2015
GROUP BY MONTH(R_OUT.Pickup_Date)
ORDER BY MONTH(R_OUT.Pickup_Date) ASC;

# H. FOR EACH MONTH OF 2015, SHOW THE PERCENTAGE CHANGE OF THE TOTAL AMOUNT OF RENTALS OVER THE TOTAL AMOUNT OF RENTALS OF THE SAME MONTH OF 2014

SELECT MONTH_2015, 
concat(round(100*(CURRENT.TOTAL_AMOUNT_2015 - PREVIOUS.TOTAL_AMOUNT_2014) / PREVIOUS.TOTAL_AMOUNT_2014),'%') AS PERCENTAGE_DIFFERENCE
FROM
(
	#FIND THE TOTAL AMOUNT OF EACH MONTH OF 2015
	SELECT MONTH(CURR_RSV.Pickup_Date) AS MONTH_2015 ,  
              SUM(CURR_RSV.AMOUNT) AS TOTAL_AMOUNT_2015
	FROM reservations as CURR_RSV
	WHERE YEAR(CURR_RSV.Pickup_Date)=2015
	GROUP BY MONTH(CURR_RSV.Pickup_Date)
               ORDER BY MONTH(CURR_RSV.Pickup_Date) ASC
)CURRENT
LEFT JOIN
( 
	#FIND THE TOTAL AMOUNT OF EACH MONTH OF 2014
	SELECT MONTH(PRE_RSV.Pickup_Date) AS MONTH_2014 , 
               SUM(PRE_RSV.AMOUNT) AS TOTAL_AMOUNT_2014
	FROM reservations as PRE_RSV
	WHERE YEAR(PRE_RSV.Pickup_Date)=2014
	GROUP BY MONTH(PRE_RSV.Pickup_Date)
              ORDER BY MONTH(PRE_RSV.Pickup_Date) ASC
)PREVIOUS
ON PREVIOUS.MONTH_2014 = CURRENT.MONTH_2015;

# I. FOR EACH MONTH OF 2015, SHOW IN THREE COLUMNS: THE TOTAL RENTALS’ AMOUNT OF THE PREVIOUS MONTHS, THE TOTAL RENTALS’ AMOUNT OF THIS MONTH AND THE TOTAL RENTALS’ AMOUNT OF THE FOLLOWING MONTHS

SELECT R_PRE.PREVIOUS_AMOUNT, CURRENT_AMOUNT, (TOTAL_AMOUNT - R_PRE.PREVIOUS_AMOUNT - CURRENT_AMOUNT) AS NEXT_AMOUNT 
FROM
(
	SELECT PREVIOUS.MONTH_2015, abs(sum(PREVIOUS.CURRENT_AMOUNT) OVER (ORDER BY MONTH_2015) - CURRENT_AMOUNT)  AS PREVIOUS_AMOUNT, CURRENT_AMOUNT
	FROM reservations as R_PRE,
	(
		SELECT MONTH(R_CURR.Pickup_Date) AS MONTH_2015, SUM(R_CURR.AMOUNT) AS CURRENT_AMOUNT
		FROM reservations as R_CURR
		WHERE YEAR(R_CURR.Pickup_Date)=2015
		GROUP BY MONTH(R_CURR.Pickup_Date)
	)PREVIOUS
	WHERE YEAR(R_PRE.Pickup_Date)=2015
	GROUP BY MONTH_2015
)R_PRE
INNER JOIN
(
	SELECT SUM(R.Amount) AS TOTAL_AMOUNT
	FROM reservations as R
	WHERE YEAR(R.Pickup_Date)=2015
)NEXT
GROUP BY MONTH_2015;








