SELECT top 20
 * FROM 
  dbo.SalesOrderDetail
 
 SELECT SalesOrderID, 'Total Ordered' = SUM(OrderQuantity), 'Avg Cost' = AVG(UnitPrice)
  INTO #expected
  FROM dbo.SalesOrderDetail
  WHERE 1 = 0
  GROUP BY SalesOrderID

  SELECT top 20
   * FROM  #expected
   
   -- get data from #expected


   DROP TABLE #expected