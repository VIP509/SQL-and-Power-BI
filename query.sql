--SQL Query

--* Question 2. Calculate the number of health facilities per commune.
SELECT [adm2_en] ,count(c.factype) AS Number_of_facilities
FROM [Haiti_Health_Data_Analysis].[dbo].[Commune] as k INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[spa] as c ON k.[adm2code]=c.adm2code 
GROUP BY k.[adm2_en]

--* Question 3. Calculate the number of health facilities by commune and by type of health facility.
SELECT [adm2_en] as Departemeent, [facdesc] as Description1 , count(*) as Number_facilities
FROM [Haiti_Health_Data_Analysis].[dbo].[Commune] INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[spa] ON commune.adm2code=spa.adm2code INNER JOIN [Haiti_Health_Data_Analysis].[dbo].factype ON spa.factype=factype.factype
GROUP BY commune.adm2_en , factype.facdesc
ORDER BY commune.adm2_en ASC

--* Question 4. Calculate the number of health facilities by municipality and by department.
SELECT k.[adm2_en] as Commune , v.[adm1_en] as Departement, COUNT(*) as number_of_health_fac_by_municipality
FROM [Haiti_Health_Data_Analysis].[dbo].[Commune] as k INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[spa] as b ON k.adm2code=b.adm2code INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Departement] as v  ON v.adm1code=k.adm1code
GROUP BY [k].[adm2_en] ,[v].adm1_en

--* Question 5: Calculate the number of sites by type (mga) and by department.
SELECT [c].[mga], [p].[adm1_en] as Departement, COUNT(*) as Number_of_sites FROM [Haiti_Health_Data_Analysis].[dbo].[spa] as c
INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Departement]  AS p ON c.[adm1code] = p.[adm1code]
GROUP BY p.[adm1_en],[c].[mga]

--* Question 6: Calculate the number of sites with an ambulance by commune and by department (ambulance = 1.0).
SELECT  [p].[adm1_en] as Departement ,[t].[adm2_en] as Commune, COUNT(*) as Number_of_sites FROM [Haiti_Health_Data_Analysis].[dbo].[spa] as c
INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Departement]  AS p ON c.[adm1code] = p.[adm1code]
INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Commune]  AS t ON t.[adm2code] = c.[adm2code]
WHERE [c].[ambulance] = 1
GROUP BY p.[adm1_en],[t].[adm2_en]
ORDER BY [p].[adm1_en]

--* Question 7. Calculate the number of hospitals per 10k inhabitants by department.
SELECT [adm1_en] as Departement , ROUND((COUNT(p.factype)*10000/([IHSI_UNFPA_2019])),2) as Number_of_hospitals_10k_habitants  FROM [Haiti_Health_Data_Analysis].[dbo].[Departement] AS c
INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[spa]  AS p ON c.[adm1code] = p.[adm1code]
INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Factype]  AS t ON [p].[factype] = [t].[factype]
WHERE [t].facdesc_1 = 'HOPITAL'
GROUP BY [adm1_en],[IHSI_UNFPA_2019]

--* Question 8. Calculate the number of sites per 10k inhabitants per department.
SELECT [adm1_en] as Departement , ROUND((COUNT(p.factype)*10000/([IHSI_UNFPA_2019])),2) as Number_of_sites_10k_habitants  FROM [Haiti_Health_Data_Analysis].[dbo].[Departement] AS c
INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[spa]  AS p ON c.[adm1code] = p.[adm1code]
GROUP BY [adm1_en],[IHSI_UNFPA_2019]

--* Question 9: Calculate the number of beb per 1,000 inhabitants per department.
SELECT [adm1_en] as Departement , ROUND((SUM([p].[num_beds]*1000/[IHSI_UNFPA_2019])),2) as Number_of_bed_1k_habitants  FROM [Haiti_Health_Data_Analysis].[dbo].[Departement] AS c
INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[spa]  AS p ON c.[adm1code] = p.[adm1code]
GROUP BY [adm1_en],[IHSI_UNFPA_2019]

--* Question 10. How many communes have fewer dispensaries than hospitals?
CREATE VIEW Dispensaire AS
SELECT x.[adm2_en] as Commune,z.[facdesc_1] AS Health_Facility, COUNT(k.[factype]) AS Num_Of_Dis
FROM [Haiti_Health_Data_Analysis].[dbo].[spa] as k INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Commune] as x on x.[adm2code]=k.[adm2code] INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[factype] as z on z.factype=k.factype
WHERE (z.facdesc_1)='DISPENSAIRE'
GROUP BY x.adm2_en, z.facdesc_1

CREATE VIEW Hopital AS
SELECT x.adm2_en as Commune, t.facdesc_1 AS Health_Facility, COUNT(t.factype) AS Num_Of_Hop
FROM [Haiti_Health_Data_Analysis].[dbo].[spa] as k INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Commune] as x on x.adm2code=k.adm2code INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[factype] as t  on k.factype=t.factype
WHERE (t.facdesc_1)='HOPITAL'
GROUP BY x.adm2_en, t.facdesc_1

SELECT * FROM hopital LEFT JOIN dispensaire on hopital.Commune=dispensaire.Commune
WHERE hopital.Num_Of_Hop > dispensaire.Num_Of_Dis
UNION 
SELECT * FROM hopital RIGHT JOIN dispensaire on hopital.Commune=dispensaire.Commune
WHERE hopital.Num_Of_Hop > dispensaire.Num_Of_Dis

--* Question 11 How many  Letality rate per month
SELECT Datename(m,[document_date]) As Month , Cast(Sum([taux_de_letalite])/Count([taux_de_letalite]) as nvarchar(10)) +' %'  As Letality_Rate From [Haiti_Health_Data_Analysis].[dbo].[Covid_cases]
Group by Datename(m,[document_date])
ORDER By Month

--* Question 12 How many Death rate per month
SELECT Datename(m,[document_date]) As Month , Cast(Sum([taux_de_letalite])/Count([taux_de_letalite]) as nvarchar(10)) +' %'  As Death_Rate From [Haiti_Health_Data_Analysis].[dbo].[Covid_cases]
Group by Datename(m,[document_date])
ORDER By Month

--* Question 13 How many Prevalence per month
SELECT Datename(m,[document_date]) As Month , Cast(Sum([c].[cas_confirmes])/Sum([p].[IHSI_UNFPA_2019]) as nvarchar(100)) +' %'  As Prevalence_per_m From [Haiti_Health_Data_Analysis].[dbo].[Covid_cases] AS c 
INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Departement] As p ON [c].[adm1code] = [p].adm1code
Group by Datename(m,[document_date])
ORDER By Month

--* Question 14 How many Prevalence by department
SELECT	Datename(WK,cast([document_date] as date)) As Month,Cast([m].[adm2_en] as text), Cast([c].[cas_confirmes]/[p].[IHSI_UNFPA_2019] as nvarchar(100)) +' %'  As Prevalence_per_m From [Haiti_Health_Data_Analysis].[dbo].[Covid_cases] AS c 
INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Departement] As p ON [c].[adm1code] = [p].adm1code 
INNeR JOIN [Haiti_Health_Data_Analysis].[dbo].[Commune]  AS m ON [m].[adm1code] = [p].adm1code
Group by m.[adm2_en],[p].[IHSI_UNFPA_2019],[c].[cas_confirmes],Datename(Wk,cast([document_date] as date))
ORDER By Prevalence_per_m DESC


--* Question 15 What is the variation of the prevalence per week
