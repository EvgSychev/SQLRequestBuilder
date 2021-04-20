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
