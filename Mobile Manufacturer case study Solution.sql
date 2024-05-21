--SQL Advance Case Study

--Q1--BEGIN 
SELECT DISTINCT  L.State FROM DIM_LOCATION AS L
INNER JOIN FACT_TRANSACTIONS AS F
ON L.IDLocation= F.IDLocation
WHERE YEAR([DATE]) >=2005



--Q1--END

--Q2--BEGIN
SELECT TOP 1 STATE, SUM(QUANTITY) AS TOTAL_QUANTITY  
FROM DIM_LOCATION AS L
INNER JOIN FACT_TRANSACTIONS AS F
ON  L.IDLOCATION  = F.IDLocation 

INNER JOIN DIM_MODEL AS M
ON M.IDModel = F.IDModel

INNER JOIN DIM_MANUFACTURER AS R
ON R.IDManufacturer = M.IDManufacturer
WHERE Country = 'US' AND MANUFACTURER_NAME = 'SAMSUNG'
GROUP BY L.STATE
ORDER BY TOTAL_Quantity DESC





--Q2--END

--Q3--BEGIN      

	 SELECT L.ZIPCODE,L.STATE, MO.IDMODEL, COUNT(IDCUSTOMER) AS TOT_TRANSCATIONS 
				FROM FACT_TRANSACTIONS  AS T
			 		INNER JOIN DIM_MODEL AS MO
						ON T.IDModel = MO.IDModel 
						
				INNER JOIN  DIM_LOCATION AS L 
			 ON L.IDLocation = T.IDLocation
			GROUP BY L.State, L.ZipCode,MO.IDModel;

--Q3--END

--Q4--BEGIN
			SELECT TOP 1 MODEL_NAME, MANUFACTURER_NAME,UNIT_PRICE 
					FROM DIM_MODEL AS M
						INNER JOIN DIM_MANUFACTURER AS S
						 ON M.IDManufacturer = S.IDManufacturer
						  ORDER BY Unit_price





--Q4--END

--Q5--BEGIN   


SELECT TOP 5 MODEL_NAME, AVG_P
FROM (
    SELECT IDMODEL, AVG(TOTALPRICE) AS AVG_P
    FROM FACT_TRANSACTIONS
    WHERE IDModel IN (
        SELECT MM.IDMODEL
        FROM DIM_MODEL AS MM
        INNER JOIN DIM_MANUFACTURER AS M ON MM.IDMANUFACTURER = M.IDMANUFACTURER
        WHERE MANUFACTURER_NAME IN (
            SELECT MANUFACTURER_NAME
            FROM (
                SELECT TOP (1) WITH TIES MANUFACTURER_NAME,
                    SUM(QUANTITY) AS SALES
                FROM FACT_TRANSACTIONS T
                INNER JOIN DIM_MODEL AS MM ON T.IDMODEL = MM.IDModel
                INNER JOIN DIM_MANUFACTURER AS MO ON MM.IDManufacturer = MO.IDManufacturer
                GROUP BY Manufacturer_Name
                ORDER BY SALES DESC
            ) AS X
            GROUP BY MANUFACTURER_NAME
        )
    )
    GROUP BY IDMODEL
) AS A
INNER JOIN DIM_MODEL AS B ON A.IDMODEL = B.IDMODEL
ORDER BY AVG_P DESC;


--Q5--END

--Q6--BEGIN

		SELECT customer_NAME ,AVG(TOTALPRICE) AS TOT_PRICE
				FROM DIM_CUSTOMER AS C
						INNER JOIN FACT_TRANSACTIONS AS T
							ON C.IDCUSTOMER = T.IDCUSTOMER
								WHERE YEAR(DATE) = 2009
							GROUP BY C.CUSTOMER_NAME,C.IDCUSTOMER
					HAVING AVG(TotalPrice) > 500
					ORDER BY TOT_PRICE DESC


--Q6--END
	
--Q7--BEGIN  


	SELECT IDMODEL FROM (
				SELECT TOP 5 IDMODEL, SUM(QUANTITY) AS QUANT
				FROM FACT_TRANSACTIONS AS F
				WHERE YEAR(DATE) = 2008
				GROUP BY IDMODEL
				ORDER BY QUANT DESC
				) AS X
	
	INTERSECT		
			SELECT IDMODEL FROM (
			SELECT TOP 5 IDMODEL, SUM(QUANTITY) AS QUANT
			FROM FACT_TRANSACTIONS AS F
			WHERE YEAR(DATE) = 2009
			GROUP BY IDMODEL
			ORDER BY QUANT DESC
			) AS Y
	
	INTERSECT 
			SELECT IDMODEL FROM (
			SELECT TOP 5 IDMODEL, SUM(QUANTITY) AS QUANT
			FROM FACT_TRANSACTIONS AS F
			WHERE YEAR(DATE) = 2010
			GROUP BY IDMODEL
			ORDER BY QUANT DESC
			) AS Z
			ORDER BY IDModel;


--Q7--END	
--Q8--BEGIN
		SELECT Manufacturer_Name FROM(
					SELECT Manufacturer_Name, SUM(TotalPrice) AS TOT_SALE
							FROM FACT_TRANSACTIONS AS T
								INNER JOIN DIM_MODEL AS M
								ON M.IDMODEL = T.IDMODEL
									INNER JOIN DIM_MANUFACTURER AS MF
									ON MF.IDManufacturer = M.IDManufacturer
										WHERE YEAR(DATE) = 2009
										GROUP BY Manufacturer_Name,YEAR(DATE)
											ORDER BY TOT_SALE
											OFFSET 1 ROW
											FETCH NEXT 1 ROW ONLY
											) AS X
		
		UNION
				SELECT TOP 2 Manufacturer_Name FROM(
						SELECT Manufacturer_Name, SUM(TotalPrice) AS MANF
								FROM FACT_TRANSACTIONS AS T
									INNER JOIN DIM_MODEL AS M
										ON M.IDMODEL = T.IDMODEL
										INNER JOIN DIM_MANUFACTURER AS MF
											ON MF.IDManufacturer = M.IDManufacturer
											WHERE YEAR(DATE) = 2010
											GROUP BY Manufacturer_Name
											ORDER BY SUM(TotalPrice) DESC
											OFFSET 1 ROW
											FETCH NEXT 1 ROW ONLY
											) AS X
		


--Q8--END
--Q9--BEGIN
	
		SELECT MANUFACTURER_NAME FROM( 
			SELECT MANUFACTURER_NAME, SUM(TOTALPRICE) AS TOTAL_AMOUNT
					FROM DIM_MANUFACTURER AS M
					LEFT JOIN DIM_MODEL AS  MM
					   ON M.IDManufacturer= MM.IDManufacturer
					   LEFT JOIN FACT_TRANSACTIONS AS T
					      ON T.IDModel = MM.IDModel
							WHERE YEAR(T.Date) = 2010
								GROUP BY M.Manufacturer_Name,
					YEAR(T.DATE)
					) AS X 
							EXCEPT 
			        SELECT MANUFACTURER_NAME FROM( 
					SELECT MANUFACTURER_NAME, SUM(TOTALPRICE) AS TOTAL_AMOUNT
							FROM DIM_MANUFACTURER AS M
							LEFT JOIN DIM_MODEL AS  MM
									ON M.IDManufacturer= MM.IDManufacturer
									LEFT JOIN FACT_TRANSACTIONS AS T
										ON T.IDModel = MM.IDModel
										WHERE YEAR(T.Date) = 2009
										GROUP BY M.Manufacturer_Name,
										YEAR(T.DATE) 
										) AS X
			








--Q9--END

--Q10--BEGIN


	
			SELECT T1.IDCustomer,T1.Customer_Name , T1.[Year],T1.Avg_Spend,
						T1.Avg_Qty,case when T2.[Year] is not null then
						((T2.Avg_Spend-T2.Avg_Spend)/T2.Avg_Spend )* 100 
						
						else NULL
								end as 'YOY in Average Spend' from
				(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_Spend ,AVG(F.Quantity) as Avg_Qty ,
					YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
							left join FACT_TRANSACTIONS as F 
							on F.IDCustomer=C.IDCustomer 
							where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
							left join FACT_TRANSACTIONS as F 
							on F.IDCustomer=C.IDCustomer 
							group by C.IDCustomer 
							order by Sum(F.TotalPrice) desc)
							group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as T1
					left join 
					
								(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_Spend ,AVG(F.Quantity) as Avg_Qty ,
									YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
										left join FACT_TRANSACTIONS as F
										on F.IDCustomer=C.IDCustomer 
												where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
													left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
													   group by C.IDCustomer 
													   order by Sum(F.TotalPrice) desc)
													   group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as T2 
													   on T1.IDCustomer=T2.IDCustomer and T2.[Year]=T1.[Year]-1;


--Q10--END
	
