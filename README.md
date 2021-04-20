# SQLRequestBuilder

Небольшой класс генерирующий текст запроса, поддерживется диалек MS SQL

Например запрос:

SELECT *  
FROM DimEmployee  
ORDER BY LastName

Можно получить следущий образом (код первой версии), предположим что обработка включена в конфигурацию:

SQLRequestBuilder = DataProcessorManager.SQLRequestBuilder.Create();
SQLRequestText = SQLRequestBuilder.Select("\*").From("DimEmployee").OrderBy("LastName").Текст();
