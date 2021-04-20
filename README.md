# SQLRequestBuilder

Небольшой класс генерирующий текст запроса, поддерживается диалект MS SQL

Например запрос:

```sql
SELECT *  
FROM DimEmployee  
ORDER BY LastName
```

Можно получить следущий образом (код первой версии), предположим что обработка включена в конфигурацию:

```1C Enterpise
SQLRequestBuilder = DataProcessorManager.SQLRequestBuilder.Create();
SQLRequestText = SQLRequestBuilder.Select("*").From("DimEmployee").OrderBy("LastName").RequestText();
```

Пример посложнее:

```sql
SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
ORDER BY Name ASC
```

1C Enterpise:
```1C Enterpise
SQLRequestBuilder = DataProcessorManager.SQLRequestBuilder.Create();
SQLRequestText = SQLRequestBuilder.Select("Name, ProductNumber")
	.Field("ListPrice","Price");//такая форма записи поля используется для задания псевдонима и если в тексте поля используются запятые
.From("Production.Product").OrderBy("Name ASC").RequestText();
```
