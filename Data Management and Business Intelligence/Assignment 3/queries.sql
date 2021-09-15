--Query 1
--Show the total “Amount” of “Type = 0” transactions at “ATM Code = 21” of the last 10 minutes. 
--Repeat as new events keep flowing in (use a sliding window).

SELECT SUM(Amount) as TOTAL_AMOUNT, System.Timestamp AS TIME
INTO [output]
FROM [input]
TIMESTAMP BY EventEnqueuedUtcTime
GROUP BY Type, ATMCode, SlidingWindow(minute,10)
HAVING Type=0 AND ATMCode=21

--Query 2
--Show the total “Amount” of “Type = 1” transactions at “ATM Code = 21” of the last hour. 
--Repeat once every hour (use a tumbling window).

SELECT SUM(Amount) as TOTAL_AMOUNT, System.Timestamp AS TIME
INTO [output]
FROM [input]
TIMESTAMP BY EventEnqueuedUtcTime
GROUP BY Type, ATMCode, TumblingWindow(hour,1)
HAVING Type=1 AND ATMCode=21

-- Query 3: 
--Show the total “Amount” of “Type = 1” transactions at “ATM Code = 21” of the last hour.
--Repeat once every 30 minutes (use a hopping window). */

SELECT SUM(Amount) as TOTAL_AMOUNT, System.Timestamp AS TIME
INTO [output]
FROM [input]
TIMESTAMP BY EventEnqueuedUtcTime
WHERE Type=1 AND ATMCode=21
GROUP BY ATMCode, HoppingWindow(minute,60,30)

--Query 4 
--Show the total “Amount” of “Type = 1” transactions per “ATM Code” of the last one hour (use a sliding window).

SELECT SUM(Amount) as TOTAL_AMOUNT, ATMCode, System.Timestamp AS TIME
INTO [output]
FROM [input]
TIMESTAMP BY EventEnqueuedUtcTime
GROUP BY Type, ATMCode, SlidingWindow(minute,60)
HAVING Type=1 


--Query 5
--Show the total “Amount” of “Type = 1” transactions per “Area Code” of the last hour. 
--Repeat once every hour (use a tumbling window).

SELECT SUM([input].[Amount]) AS TOTAL_AMOUNT, [atm].[area_code], System.Timestamp AS TIME
INTO [output]
FROM [input]
TIMESTAMP BY EventEnqueuedUtcTime
INNER JOIN [atm]
ON [input].[ATMCode]=[atm].[atm_code]
WHERE [input].[Type]=1
GROUP BY [atm].[area_code], TumblingWindow(hour,1)

--Query 6 
--Show the total “Amount” per ATM’s “City” and Customer’s “Gender” of the last hour. 
--Repeat once every hour (use a tumbling window).

SELECT SUM([input].[Amount]) AS TOTAL_AMOUNT, [area].[area_city] AS CITY, [customer].[gender] AS GENDER, System.Timestamp AS TIME
INTO [output]
FROM [input]
TIMESTAMP BY EventEnqueuedUtcTime
INNER JOIN [customer]
ON [input].[CardNumber]=[customer].[card_number]
INNER JOIN [atm]
ON [input].[ATMCode]=[atm].[atm_code]
INNER JOIN [area]
ON [atm].[area_code]=[area].[area_code]
GROUP BY [customer].[gender], [area].[area_city], TumblingWindow(hour,1)

--Query 7
--Alert (Do a simple SELECT “1”) if a Customer has performed two transactions of “Type = 1” in a 
--window of an hour (use a sliding window).

SELECT 1 AS ALERT,[customer].[card_number], [customer].[first_name],[customer].[last_name], 
COUNT(*) AS TRANSACTIONS, System.Timestamp AS TIME
INTO [output]
FROM [input]
INNER JOIN [customer]
ON [input].[CardNumber]=[customer].[card_number]
WHERE [input].[Type]=1
GROUP BY  [customer].[card_number], [customer].[first_name], [customer].[last_name], SlidingWindow(hour,1)
HAVING TRANSACTIONS=2

--Query 8 
--Alert (Do a simple SELECT “1”) if the “Area Code” of the ATM of the transaction is not the same 
--as the “Area Code” of the “Card Number” (Customer’s Area Code) - (use a sliding window)

SELECT 1 AS ALERT,[customer].[card_number], [customer].[area_code] AS CUSTOMER_AREA,[atm].[area_code] AS ATM_AREA, 
COUNT(*) AS TRANSACTIONS, System.Timestamp AS TIME
INTO [output]
FROM [input]
INNER JOIN [customer]
ON [input].[CardNumber]=[customer].[card_number]
INNER JOIN [atm]
ON [input].[ATMCode]=[atm].[atm_code]
WHERE [customer].[area_code]!=[atm].[area_code]
GROUP BY  [customer].[card_number], [customer].[area_code], [atm].[area_code], SlidingWindow(hour,1)




