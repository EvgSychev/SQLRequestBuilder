# SQLRequestBuilder

Небольшой класс генерирующий текст запроса, поддерживается диалект MS SQL. Что то похожее на jooq.

Например запрос:

```sql
SELECT *  
FROM DimEmployee  
ORDER BY LastName
```

Можно получить следущий образом (код первой версии), предположим что обработка включена в конфигурацию:

```bsl
SQLRequestBuilder = DataProcessorManager.SQLRequestBuilder.Create();
SQLRequestText = SQLRequestBuilder.Select("*").From("DimEmployee").OrderBy("LastName").RequestText();
```

Пример посложнее:

```sql
SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = 'R' AND DaysToManufacture < 4
ORDER BY Name ASC
```

1C Enterpise:
```bsl
SQLRequestBuilder = DataProcessorManager.SQLRequestBuilder.Create();
SQLRequestText = SQLRequestBuilder.Select("Name, ProductNumber")
	.Field("ListPrice","Price")//такая форма записи поля используется для задания псевдонима и если в тексте поля используются запятые
.From("Production.Product")
.Where("ProductLine = 'R'")
	.Condition("DaysToManufacture < 4")//ещё одно условие
.OrderBy("Name ASC").RequestText();
```
Пример с select into:

```sql
IF OBJECT_ID (N'#Bicycles',N'U') IS NOT NULL
DROP TABLE #Bicycles
SELECT * 
INTO #Bicycles
FROM AdventureWorks2012.Production.Product
WHERE ProductNumber LIKE 'BK%'
```

1C Enterpise:
```bsl
SQLRequestBuilder = DataProcessorManager.SQLRequestBuilder.Create();
SQLRequestText = SQLRequestBuilder
._If("OBJECT_ID (N'#Bicycles',N'U') IS NOT NULL")// слово if зарезервировано
.Drop()
.Table("#Bicycles")
.Select("*")
.Into("#Bicycles")
.From("AdventureWorks2012.Production.Product")
.Where("ProductNumber LIKE 'BK%'")
.RequestText();
```
