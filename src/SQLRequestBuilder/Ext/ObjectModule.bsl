﻿// ++ Сычев Е.Е. 1.12.2020
Перем ДеревоAST Экспорт;// дерево значений
Перем ТекущийУзел;// текущий узел дерева AST
Перем ПозицияСледующаяСтрока;// константа, определяет расположение текстов строк контейнера

#Область Служебные

Процедура Инициализация() Экспорт
	
	ПозицияСледующаяСтрока = "СледующаяСтрока";
	
	ДеревоAST = Новый ДеревоЗначений;
		
	ДеревоAST.Колонки.Добавить("Токен", Новый ОписаниеТипов("Строка"));
	ДеревоAST.Колонки.Добавить("Текст", Новый ОписаниеТипов("Строка"));
	ДеревоAST.Колонки.Добавить("Значение", Новый ОписаниеТипов("Строка"));
	ДеревоAST.Колонки.Добавить("Позиция", Новый ОписаниеТипов("Строка"));
	ДеревоAST.Колонки.Добавить("Отступ", Новый ОписаниеТипов("Число"));
	ДеревоAST.Колонки.Добавить("Разделитель", Новый ОписаниеТипов("Строка"));
	ДеревоAST.Колонки.Добавить("Виртуальная", Новый ОписаниеТипов("Булево"));

	ТекущийУзел = ДеревоAST;	
	
КонецПроцедуры // Инициализация()

Функция Тест(ТекстКоманд, вхДерево) Экспорт
	
	Инициализация();
	
	Выполнить(ТекстКоманд);
	
	вхДерево.Строки.Очистить();
	
	Для каждого КолонкаДерева Из ДеревоAST.Колонки Цикл
		Если вхДерево.Колонки.Найти(КолонкаДерева.Имя) = Неопределено Тогда
			вхДерево.Колонки.Добавить(КолонкаДерева.Имя, КолонкаДерева.ТипЗначения);
		КонецЕсли;	
	КонецЦикла; 
	
	СкопироватьСтрокиДерева(ДеревоAST.Строки, вхДерево.Строки);
		
	Возврат RequestText();
	
КонецФункции // Тест()

Процедура СкопироватьСтрокиДерева(Источник, Приемник)
	
	Для каждого СтрокаДерева Из Источник Цикл
		
		НС = Приемник.Добавить();
		
		ЗаполнитьЗначенияСвойств(НС, СтрокаДерева);
		
		Если СтрокаДерева.Строки.Количество() > 0 Тогда
			СкопироватьСтрокиДерева(СтрокаДерева.Строки, НС.Строки);
		КонецЕсли; 
		
	КонецЦикла; 
	
КонецПроцедуры // СкопироватьСтрокиДерева()

Функция УзелНужногоТипа(Узел, Знач Токены)
	
	РезультатФункции = Ложь;
	
	Если ЗначениеЗаполнено(Токены) Тогда
		МассивТокенов = СтрРазделить(Токены, ",");
		РезультатФункции = ТипЗнч(Узел) = Тип("СтрокаДереваЗначений") 
			И МассивТокенов.Найти(Узел.Токен) <> Неопределено;
	КонецЕсли; 
	
	Возврат РезультатФункции;
		
КонецФункции // РодительНужногоТипа()

Функция ТипУзлаДерево(Узел)
	Если Узел = Неопределено Тогда
		Узел = ДеревоAST;
	КонецЕсли; 
	Возврат ТипЗнч(Узел) = Тип("ДеревоЗначений");	
КонецФункции // ТекущийУзелДерево()

Функция ПолучитьНужныйУзел(Знач вхТокены = "")
	
	РезультатФункции = ТекущийУзел;
	
	Токены = вхТокены;
	Если НЕ ЗначениеЗаполнено(Токены) Тогда
		Токены = "TRY,TRAN,BEGIN,CATCH,IF,WHILE";
	КонецЕсли;
	
	Пока НЕ ТипУзлаДерево(РезультатФункции) Цикл
		Если УзелНужногоТипа(РезультатФункции, Токены) И НЕ БлокЗакрыт(РезультатФункции) Тогда
			Прервать;
		КонецЕсли;	
	    РезультатФункции = РезультатФункции.Родитель;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(вхТокены) И ТипУзлаДерево(РезультатФункции) Тогда
		ВызватьИсключение СтрШаблон("Не найден нужный узел типа: %1", вхТокены);
	КонецЕсли;
	
	Возврат РезультатФункции;
	
КонецФункции // ПолучитьНужныйУзел()

Функция БлокЗакрыт(Узел)
	Если Узел.Токен = "TRY" Тогда
		РезультатФункции = Узел.Строки.Найти("ENDTRY", "Токен", Ложь) <> Неопределено;
	ИначеЕсли Узел.Токен = "IF" ИЛИ Узел.Токен = "WHILE" Тогда
		РезультатФункции = Узел.Строки.Количество() > 0;
	ИначеЕсли Узел.Токен = "BEGIN" Тогда
		РезультатФункции = Узел.Строки.Найти("END", "Токен", Ложь) <> Неопределено;
	ИначеЕсли Узел.Токен = "TRAN" Тогда
		РезультатФункции = Узел.Строки.Найти("ENDTRAN", "Токен", Ложь) <> Неопределено;
	ИначеЕсли Узел.Токен = "CATCH" Тогда
		РезультатФункции = Узел.Строки.Найти("ENDCATCH", "Токен", Ложь) <> Неопределено;
	Иначе
		РезультатФункции = Ложь;
	КонецЕсли; 
	Возврат РезультатФункции;
КонецФункции // БлокЗакрыт()

Процедура ДобавитьУзел(УзелРодитель, Токен, Текст)
	
	ТекущийУзел = УзелРодитель.Строки.Добавить();
	ТекущийУзел.Текст = Текст;
	ТекущийУзел.Токен = Токен;
	
КонецПроцедуры// ДобавитьУзел()

Функция ДобавитьСтроку(УзелРодитель, Токен, Текст="")
	
	ТекущаяСтрока = УзелРодитель.Строки.Добавить();
	ТекущаяСтрока.Текст = Текст;
	ТекущаяСтрока.Токен = Токен;
	
	Возврат ТекущаяСтрока;
	
КонецФункции // ДобавитьСтроку()

Процедура ВиртуальныйКонтейнер(УзелРодитель, Токен, Разделитель = "", ПозицияВКонтейнере = Неопределено)
	
	ДобавитьУзел(УзелРодитель, Токен, "");
	ТекущийУзел.Виртуальная = Истина;
	ТекущийУзел.Разделитель = Разделитель;
	
	Если ПозицияВКонтейнере <> Неопределено Тогда
		Родитель = ТекущийУзел.Родитель;
		ТекущаяПозицияВКонтейнере = Родитель.Строки.Индекс(ТекущийУзел);
		Родитель.Строки.Сдвинуть(ТекущаяПозицияВКонтейнере, ПозицияВКонтейнере - ТекущаяПозицияВКонтейнере);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработатьПараметрСписок(ПараметрСписок, ТипПараметра)
	
	ТекстВыполнения = СтрШаблон("
	|Если ЗначениеЗаполнено(ПараметрСписок) Тогда
	|	МассивПараметров = СтрРазделить(ПараметрСписок,"","");
	|	Для Каждого Параметр Из МассивПараметров  Цикл
	|		%1(Параметр);
	|	КонецЦикла;
	|КонецЕсли;", ТипПараметра);
	
	Выполнить(ТекстВыполнения);
	
КонецПроцедуры

Процедура РасположитьСтрокуВКонтейнере(СтрокаДерева, УзелДерева, Позиция = 1)
	ИндексСтроки = УзелДерева.Строки.Индекс(СтрокаДерева);
	УзелДерева.Строки.Сдвинуть(СтрокаДерева, -ИндексСтроки + Позиция - 1);	
КонецПроцедуры

#КонецОбласти //Служебные

#Область ГенерацияТекста

Функция RequestText() Экспорт
		
	МассивСтрок = ОбработатьСтрокиДерева(ДеревоAST.Строки);
	
	Возврат СтрСоединить(МассивСтрок, Символы.ПС);
	
КонецФункции

Функция ОбработатьСтрокиДерева(СтрокиДерева, Знач Отступ = 0, Знач РасположениеСтрокВКонтейнере = "")
	
	ЭтоНоваяСтрока = РасположениеСтрокВКонтейнере = ПозицияСледующаяСтрока;
	
	Отступы = "										";
	
	МассивСтрок = Новый Массив;
		
	Для Каждого Строка Из СтрокиДерева Цикл
							
		Подстроки = ОбработатьСтрокиДерева(Строка.Строки, Отступ + Строка.Отступ, Строка.Позиция);
				
		Если Подстроки.Количество() > 0 Тогда
			
			РазделительКонтейнера  = Строка.Разделитель;
			РазделительТекстаКонтейнера = ?(ЗначениеЗаполнено(Строка.Текст), " ", "");
			
			Текст = СтрШаблон("%1%2%3", Строка.Текст, РазделительТекстаКонтейнера, СтрСоединить(Подстроки, РазделительКонтейнера));
						
		Иначе
			Текст = Строка.Текст;
		КонецЕсли;
		
		Если ЭтоНоваяСтрока И НЕ Строка.Виртуальная И Отступ > 0 Тогда
			Текст = СтрШаблон("%1%2", Лев(Отступы, Отступ), Текст);
		КонецЕсли; 
		
		Если ЭтоНоваяСтрока И НЕ Строка.Виртуальная Тогда
			Текст = СтрШаблон("%1%2", Символы.ПС, Текст);
		КонецЕсли;
				
	    МассивСтрок.Добавить(Текст);
			
	КонецЦикла;
	
	Возврат МассивСтрок;
	
КонецФункции

#КонецОбласти //ГенерацияТекста

#Область DDL

Функция Drop() Экспорт

	ТекущийУзел = ПолучитьНужныйУзел();
	
	ДобавитьУзел(ТекущийУзел, "DROP", "drop");
	
	Возврат ЭтотОбъект;

КонецФункции // Drop()

Функция Truncate(Знач ИмяТаблицы) Экспорт

	ТекущийУзел = ПолучитьНужныйУзел();
	
	ДобавитьСтроку(ТекущийУзел, "TRUCATE", СтрШаблон("truncate table %1", ИмяТаблицы));
	
	Возврат ЭтотОбъект;

КонецФункции // Truncate()


Функция Create() Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел();
	
	ДобавитьУзел(ТекущийУзел, "CREATE", "create");		
	
	Возврат ЭтотОбъект;

КонецФункции // Create()

Функция Table(Знач ИмяТаблицы) Экспорт

	Если УзелНужногоТипа(ТекущийУзел, "CREATE,INDEX,VARIABLE") Тогда
		ДобавитьУзел(ТекущийУзел, "TABLE", СтрШаблон("table %1", ИмяТаблицы));
	Иначе
		ДобавитьСтроку(ТекущийУзел, "TABLE", СтрШаблон("table %1", ИмяТаблицы));
	КонецЕсли;
	
	Возврат ЭтотОбъект;	

КонецФункции // Table()

Функция Index(Знач ИмяИндекса, Знач ИмяТаблицы) Экспорт
	
	Если НЕ УзелНужногоТипа(ТекущийУзел, "CREATE") Тогда
		ВызватьИсключение "Перед вызовом функции Index нужно вызвать функцию Create";
	КонецЕсли;
	
	МассивСтрок = Новый Массив;	
	МассивСтрок.Добавить("index");
	МассивСтрок.Добавить(ИмяИндекса);
	МассивСтрок.Добавить(Символы.ПС);
	МассивСтрок.Добавить("on");
	МассивСтрок.Добавить(ИмяТаблицы);
	
	ДобавитьСтроку(ТекущийУзел, "INDEX", СтрСоединить(МассивСтрок, " "));		
	
	Возврат ЭтотОбъект;
	
КонецФункции // CreateIndex()

Функция Clustered() Экспорт
		
	ТекущийУзел = ПолучитьНужныйУзел("CREATE");

	ТекущаяСтрока = ДобавитьСтроку(ТекущийУзел, "CLUSTERED", "clustered");
	
	Если ТекущийУзел.Строки.Количество() > 1 Тогда
		Если ТекущийУзел.Строки[0].Токен = "UNIQUE" Тогда
			РасположитьСтрокуВКонтейнере(ТекущаяСтрока, ТекущийУзел, 2);
		Иначе
			РасположитьСтрокуВКонтейнере(ТекущаяСтрока, ТекущийУзел);
		КонецЕсли;
	КонецЕсли;
	
	Возврат ЭтотОбъект;
	
КонецФункции

Функция Unique() Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел("CREATE");
		
	ТекущаяСтрока = ДобавитьСтроку(ТекущийУзел, "UNIQUE", "unique");
	
	РасположитьСтрокуВКонтейнере(ТекущаяСтрока, ТекущийУзел);
	
	Возврат ЭтотОбъект;
	
КонецФункции

Функция Columns(Знач Колонки) Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел("CREATE");
	
	ДобавитьСтроку(ТекущийУзел, "COLUMNS", СтрШаблон("(%1)", Колонки));
	
	Возврат ЭтотОбъект;
	
КонецФункции

Функция Include(Знач Колонки) Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел("CREATE");
	
	ДобавитьСтроку(ТекущийУзел, "INCLUDE", СтрШаблон("include (%1)", Колонки));
	
	Возврат ЭтотОбъект;
	
КонецФункции

Функция With(Знач Опции) Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел("CREATE");
	
	ДобавитьСтроку(ТекущийУзел, "WITH", СтрШаблон("with (%1)", Опции));
	
	Возврат ЭтотОбъект;
	
КонецФункции

#КонецОбласти //DDL

#Область TCL

Функция Tran() Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел();
	
	ДобавитьУзел(ТекущийУзел, "TRAN", "begin transaction");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	
	Возврат ЭтотОбъект;
	
КонецФункции // Tran()

Функция Commit() Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел();	
	
	ДобавитьСтроку(ТекущийУзел, "COMMIT", "commit transaction");
	
	Возврат ЭтотОбъект;
	
КонецФункции // Commit()

Функция Rollback() Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел();
	
	ДобавитьСтроку(ТекущийУзел, "ROLLBACK", "rollback transaction");
	
	Возврат ЭтотОбъект;
	
КонецФункции // Rallback()

#КонецОбласти //TCL

#Область DML

Функция Delete(Знач ИмяТаблицы) Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел();
	
	ДобавитьУзел(ТекущийУзел, "DELETE", "delete");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	
	ВиртуальныйКонтейнер(ТекущийУзел, "SELECTPARAMS", " ");
		
	ДобавитьСтроку(ТекущийУзел, "NAMETABLE", СтрШаблон(" %1", ИмяТаблицы));
	
	Возврат ЭтотОбъект;
	
КонецФункции // Delete()

Функция Update(Знач ИмяТаблицы) Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел();
	
	ДобавитьУзел(ТекущийУзел, "UPDATE", СтрШаблон("update %1", ИмяТаблицы));
	
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	
	Возврат ЭтотОбъект;
	
КонецФункции // Update()

Функция Insert(Знач ИмяТаблицы) Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел();
	
	ДобавитьУзел(ТекущийУзел, "INSERT", СтрШаблон("insert %1", ИмяТаблицы));
	
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	
	Возврат ЭтотОбъект;
	
КонецФункции // Insert()

Функция Fields(Знач Поля) Экспорт

	ТекущийУзел = ПолучитьНужныйУзел("INSERT");
	
	ВиртуальныйКонтейнер(ТекущийУзел, "FIELDSGROUP", ",");
	
	ДобавитьСтроку(ТекущийУзел, "FIELDS", СтрШаблон("(%1)",Поля));
		
	Возврат ЭтотОбъект;

КонецФункции // Fields()

Функция Values(Знач Значения) Экспорт

	ТекущийУзел = ПолучитьНужныйУзел("INSERT");
	
	ДобавитьСтроку(ТекущийУзел, "VALUES", СтрШаблон("values (%1)",Значения));
	
	Возврат ЭтотОбъект;

КонецФункции // Values()

Функция Select(Знач Поля = "") Экспорт

	Если НЕ УзелНужногоТипа(ТекущийУзел, "FROM,INSERT,FOR") Тогда
		ТекущийУзел = ПолучитьНужныйУзел();
	КонецЕсли; 
		
	ДобавитьУзел(ТекущийУзел, "SELECT", "select");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	
	ВиртуальныйКонтейнер(ТекущийУзел, "FIELDSGROUP", ",");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	ТекущийУзел.Отступ = 1;
				
	ОбработатьПараметрСписок(Поля, "Field");
		
	Возврат ЭтотОбъект;

КонецФункции // Select()

Функция Into(Знач ИмяТаблицы) Экспорт
	ТекущийУзел = ПолучитьНужныйУзел("SELECT,FETCHNEXT");
	ДобавитьСтроку(ТекущийУзел, "INTO", СтрШаблон("into %1", ИмяТаблицы));
	Возврат ЭтотОбъект;	
КонецФункции

Функция Distinct() Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел("SELECT");
	
	ВиртуальныйКонтейнер(ТекущийУзел, "SELECTPARAMS" , , 0);
		
	ДобавитьСтроку(ТекущийУзел, "DISTINCT");
	
	Возврат ЭтотОбъект;
КонецФункции

Функция Top(Знач Количество) Экспорт
	
	ПервыйДистинкт = Ложь;
	
	Если ТекущийУзел.Токен <> "SELECTPARAMS" Тогда
		ТекущийУзел = ПолучитьНужныйУзел("SELECT,DELETE");
		ВиртуальныйКонтейнер(ТекущийУзел, "SELECTPARAMS" , , 0);
	ИначеЕсли ТекущийУзел.Строки.Количество() > 0 И ТекущийУзел.Строки[0].Токен = "DISTINCT" Тогда
		ПервыйДистинкт = Истина;
	КонецЕсли;
	
	ТекущаяСтрока = ДобавитьСтроку(ТекущийУзел, "TOP", СтрШаблон("top (%1)", Формат(Количество, "ЧГ=0")));
	
	Если НЕ ПервыйДистинкт И ТекущийУзел.Строки.Количество() > 0 Тогда
		ИндексСтроки = ТекущийУзел.Строки.Индекс(ТекущаяСтрока);
		ТекущийУзел.Строки.Сдвинуть(ТекущаяСтрока, -ИндексСтроки);
	КонецЕсли;
			
	Возврат ЭтотОбъект;
КонецФункции

Функция Field(Знач ТекстПоля, Знач Псевдоним = "") Экспорт
		
	Если ЗначениеЗаполнено(Псевдоним) Тогда
		ТекстПоля = СтрШаблон("%1 as %2", ТекстПоля, Псевдоним);
	КонецЕсли;
	
	ТекущаяСтрока = ДобавитьСтроку(ТекущийУзел, "FIELD", ТекстПоля);
				
	Возврат ЭтотОбъект;

КонецФункции // Field()

Функция From(Знач ИмяТаблицы = "", Знач Псевдоним = "") Экспорт

	ТекущийУзел = ПолучитьНужныйУзел("SELECT,DELETE,UPDATE,INSERT,FETCHNEXT");
		
	Текст = "from";
	Если ЗначениеЗаполнено(ИмяТаблицы) Тогда
		Если ЗначениеЗаполнено(Псевдоним) Тогда
			Текст = СтрШаблон("from %1 as %2", ИмяТаблицы, Псевдоним);
		Иначе
			Текст = СтрШаблон("from %1", ИмяТаблицы);
		КонецЕсли;
	КонецЕсли; 
	
	ДобавитьУзел(ТекущийУзел, "FROM", Текст);
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	ТекущийУзел.Отступ = 1;
			
	Возврат ЭтотОбъект;		

КонецФункции // From()

Функция Join(Знач ИмяТаблицы, Знач Псевдоним) Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел("FROM,INNER,LEFT,JOIN");
	
	ДобавитьУзел(ТекущийУзел, "JOIN", СтрШаблон("join %1 as %2 on", ИмяТаблицы, Псевдоним));	

	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;	
	
	Возврат ЭтотОбъект;

КонецФункции // Join()

Функция InnerJoin(Знач ИмяТаблицы, Знач Псевдоним) Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел("FROM,INNER,LEFT,JOIN");
	
	ДобавитьУзел(ТекущийУзел, "INNER", СтрШаблон("inner join %1 as %2 on", ИмяТаблицы, Псевдоним));	
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;	
	
	ВиртуальныйКонтейнер(ТекущийУзел, "CONDITIONS", " and");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;	
	ТекущийУзел.Отступ = 1;
		
	Возврат ЭтотОбъект;
	
КонецФункции // Inner()

Функция LeftJoin(Знач ИмяТаблицы, Знач Псевдоним) Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел("FROM,INNER,LEFT,JOIN");
	
	ДобавитьУзел(ТекущийУзел, "LEFT", СтрШаблон("left join %1 as %2 on", ИмяТаблицы, Псевдоним));	

	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	
	Возврат ЭтотОбъект;
	
КонецФункции // Left()

Функция Where(Знач ТекстУсловия = "") Экспорт

	ТекущийУзел = ПолучитьНужныйУзел("SELECT,DELETE,UPDATE,INSERT");
	
	ДобавитьУзел(ТекущийУзел, "WHERE", "where");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	
	ВиртуальныйКонтейнер(ТекущийУзел, "CONDITIONS", " and");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	ТекущийУзел.Отступ = 1;	
		
	ОбработатьПараметрСписок(ТекстУсловия, "Condition");
	
	Возврат ЭтотОбъект;		

КонецФункции // Where()

Функция OrderBy(Знач Поля = "") Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел("SELECT,DELETE,UPDATE,INSERT");
	
	ДобавитьУзел(ТекущийУзел, "ORDERBY", "order by");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	
	ВиртуальныйКонтейнер(ТекущийУзел, "FIELDSGROUP", ",");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	ТекущийУзел.Отступ = 1;
			
	ОбработатьПараметрСписок(Поля, "Field");
	
	Возврат ЭтотОбъект;
	
КонецФункции // OrderBy()

Функция GroupBy(Знач Поля = "") Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел("SELECT,DELETE,UPDATE,INSERT");
	
	ДобавитьУзел(ТекущийУзел, "GROUPBY", "where");
		
	ВиртуальныйКонтейнер(ТекущийУзел, "FIELDSGROUP");
	
	ОбработатьПараметрСписок(Поля, "Field");
	
	Возврат ЭтотОбъект;	 
	
КонецФункции // GroupBy()

Функция Having(Знач ТекстУсловия = "") Экспорт

	ТекущийУзел = ПолучитьНужныйУзел("SELECT,DELETE,UPDATE,INSERT");
	
	ДобавитьУзел(ТекущийУзел, "HAVING", "having");
	
	ВиртуальныйКонтейнер(ТекущийУзел, "CONDITIONS", " and");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	ТекущийУзел.Отступ = 1;	
		
	ОбработатьПараметрСписок(ТекстУсловия, "Condition");
	
	Возврат ЭтотОбъект;

КонецФункции // Having()
    
Функция Condition(Знач ТекстУсловия) Экспорт
	ТекущаяСтрока = ДобавитьСтроку(ТекущийУзел, "CONDITION", ТекстУсловия);	
	Возврат ЭтотОбъект;	
КонецФункции // Condition()

Функция Declare() Экспорт

	ТекущийУзел = ПолучитьНужныйУзел();
	
	ДобавитьУзел(ТекущийУзел, "DECLARE", "declare"); 
	ТекущийУзел.Разделитель = ", ";
	
	Возврат ЭтотОбъект;		

КонецФункции // Declare()

Функция Variable(Знач Имя) Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел("DECLARE");

	Если НЕ УзелНужногоТипа(ТекущийУзел, "DECLARE") Тогда
		ВызватьИсключение "Пропущено слово DECLARE";
	КонецЕсли;
	
	ДобавитьУзел(ТекущийУзел, "VARIABLE", Имя);
	
	Возврат ЭтотОбъект;

КонецФункции // Variable()

Функция NVarChar(Знач Размер) Экспорт
	ДобавитьСтроку(ТекущийУзел, "TYPE", СтрШаблон("nVarChar(%1)",Размер));
	Возврат ЭтотОбъект;
КонецФункции // NVarChar()

Функция Binary(Знач Размер) Экспорт
	ДобавитьСтроку(ТекущийУзел, "TYPE", СтрШаблон("binary(%1)",Размер));
	Возврат ЭтотОбъект;
КонецФункции // Binary()

Функция _Int() Экспорт
	ДобавитьСтроку(ТекущийУзел, "TYPE", "int");
	Возврат ЭтотОбъект;
КонецФункции // Int()

Функция DateTime() Экспорт
	ДобавитьСтроку(ТекущийУзел, "TYPE", "DateTime");
	Возврат ЭтотОбъект;
КонецФункции // Int()

Функция Float() Экспорт
	ДобавитьСтроку(ТекущийУзел, "TYPE", "float");
	Возврат ЭтотОбъект;
КонецФункции // Int()

Функция Value(Знач Значение) Экспорт
	ДобавитьСтроку(ТекущийУзел, "VALUE", СтрШаблон(" = %1", Значение));
	Возврат ЭтотОбъект;
КонецФункции

Функция Set(Знач ИмяПеременной, Знач Значение) Экспорт
	
	ТекущийУзел = ПолучитьНужныйУзел();

	Если ВРЕГ(Значение) = "ON" ИЛИ ВРЕГ(Значение) = "OFF" Тогда
		Текст = СтрШаблон("set %1 %2", ИмяПеременной, Значение);
	Иначе
		Текст = СтрШаблон("set %1 = %2", ИмяПеременной, Формат(Значение, "ЧГ=0"));
	КонецЕсли;
	
	ТекущаяСтрока = ДобавитьСтроку(ТекущийУзел, "SET", Текст);

	Возврат ЭтотОбъект;	

КонецФункции // Set()

Функция _If(Знач Условие) Экспорт

	ТекущийУзел = ПолучитьНужныйУзел();
	
	ДобавитьУзел(ТекущийУзел, "IF", СтрШаблон("if (%1)", Условие));
	
	Возврат ЭтотОбъект;	

КонецФункции // _If()

Функция _While(Знач Условие) Экспорт
		
	ТекущийУзел = ПолучитьНужныйУзел();
	
	ДобавитьУзел(ТекущийУзел, "WHILE", СтрШаблон("while (%1)", Условие));
	
	Возврат ЭтотОбъект;
	
КонецФункции // WhileBegin()

Функция _Break() Экспорт 
	
	ТекущаяСтрока = ДобавитьСтроку(ТекущийУзел, "BREAK", "break");
	
	ТекущаяСтрока.Позиция = ПозицияСледующаяСтрока;
	
	Возврат ЭтотОбъект;	
	
КонецФункции // Break()

Функция Begin() Экспорт
	ДобавитьУзел(ТекущийУзел, "BEGIN", "begin");	
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	ТекущийУзел.Отступ = 1;
	Возврат ЭтотОбъект;
КонецФункции // Begin()

Функция End() Экспорт
	ТекущийУзел = ПолучитьНужныйУзел("BEGIN");
	ТекущаяСтрока = ДобавитьСтроку(ТекущийУзел, "END", "end");	
	ТекущаяСтрока.Отступ = -1;
	Возврат ЭтотОбъект;		
КонецФункции // End()

#КонецОбласти //DML

#Область _Try

Функция _Try() Экспорт
	ТекущийУзел = ПолучитьНужныйУзел();
	ДобавитьУзел(ТекущийУзел, "TRY", "begin try");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	ТекущийУзел.Отступ = 1;
	Возврат ЭтотОбъект;
КонецФункции // Try()

Функция _EndTry() Экспорт
	ТекущийУзел = ПолучитьНужныйУзел("TRY");
	ТекущаяСтрока = ДобавитьСтроку(ТекущийУзел, "ENDTRY", "end try");
	ТекущаяСтрока.Позиция = ПозицияСледующаяСтрока;
	Возврат ЭтотОбъект;	
КонецФункции // EndTry()
	
Функция Catch() Экспорт
	ТекущийУзел = ПолучитьНужныйУзел("TRY");
	ДобавитьУзел(ТекущийУзел, "CATCH", "begin catch"); 
	Возврат ЭтотОбъект;
КонецФункции // Catch()

Функция EndCatch() Экспорт
	ТекущийУзел = ПолучитьНужныйУзел("CATCH");
	ДобавитьСтроку(ТекущийУзел, "ENDCATCH", "end catch");
	Возврат ЭтотОбъект;
КонецФункции // EndCatch()

Функция RaiseError(Знач Сообщение, Знач Уровень) Экспорт
	ТекущийУзел = ПолучитьНужныйУзел();
	ДобавитьСтроку(ТекущийУзел, "RAISEERROR", СтрШаблон("raiserror(%1, %2, 1)", Сообщение, Уровень));
	Возврат ЭтотОбъект;
КонецФункции // RaiseError()

#КонецОбласти //Try

#Область Cursor

Функция Cursor(Знач Имя) Экспорт
	
	Если НЕ УзелНужногоТипа(ТекущийУзел, "DECLARE") Тогда
		ВызватьИсключение "Не найдено слово declare";
	КонецЕсли;
	
	ДобавитьУзел(ТекущийУзел, "CURSOR", СтрШаблон("%1 cursor", Имя));
	
	Возврат ЭтотОбъект;
	
КонецФункции // Cursor()

Функция Local() Экспорт
	
	Если НЕ УзелНужногоТипа(ТекущийУзел, "CURSOR") Тогда
		ВызватьИсключение "Не найдено объявление курсора";
	КонецЕсли;
	
	ДобавитьСтроку(ТекущийУзел, "CURSORARG", "local");
	
	Возврат ЭтотОбъект;
	
КонецФункции // Local()

Функция _For() Экспорт
	
	Если НЕ УзелНужногоТипа(ТекущийУзел, "CURSOR") Тогда
		ВызватьИсключение "Не найдено объявление курсора";
	КонецЕсли;
		
	ДобавитьУзел(ТекущийУзел, "FOR", "for");
	ТекущийУзел.Позиция = ПозицияСледующаяСтрока;
	
	Возврат ЭтотОбъект;
	
КонецФункции // For()

Функция Open(Знач ИмяКурсора) Экспорт
	ТекущийУзел = ПолучитьНужныйУзел();
	ДобавитьСтроку(ТекущийУзел, "OPEN", СтрШаблон("open %1", ИмяКурсора));
	Возврат ЭтотОбъект;
КонецФункции // Open()

Функция FetchNext(Знач ИмяКурсора) Экспорт
	ТекущийУзел = ПолучитьНужныйУзел();
	ДобавитьУзел(ТекущийУзел, "FETCHNEXT", СтрШаблон("fetch next from %1", ИмяКурсора));
	Возврат ЭтотОбъект;
КонецФункции // Next()

Функция Close(Знач ИмяКурсора) Экспорт
	ТекущийУзел = ПолучитьНужныйУзел();
	ДобавитьСтроку(ТекущийУзел, "CLOSE", СтрШаблон("close %1", ИмяКурсора));
	Возврат ЭтотОбъект;
КонецФункции // Close()

Функция Deallocate(Знач ИмяКурсора) Экспорт
	ТекущийУзел = ПолучитьНужныйУзел();
	ДобавитьСтроку(ТекущийУзел, "DEALLOCATE", СтрШаблон("deallocate %1", ИмяКурсора));
	Возврат ЭтотОбъект;
КонецФункции // Deallocate()
	
#КонецОбласти //Cursor

#Область Misc

Функция Comment(знач ТекстКомментария) Экспорт
	ТекущийУзел = ПолучитьНужныйУзел();
	ДобавитьСтроку(ТекущийУзел, "COMMENT", СтрШаблон("--%1", ТекстКомментария));
	Возврат ЭтотОбъект;
КонецФункции // Comment()

Функция EmptyString() Экспорт
	ТекущийУзел = ПолучитьНужныйУзел();
	ДобавитьСтроку(ТекущийУзел, "EMPTYSTRING", "");
	Возврат ЭтотОбъект;	
КонецФункции // EmptyString()

Функция Use(Знач ИмяБазы) Экспорт
	ТекущийУзел = ПолучитьНужныйУзел();
	ДобавитьУзел(ТекущийУзел, "USE", ИмяБазы); 
	Возврат ЭтотОбъект;
КонецФункции // Use()

#КонецОбласти //Misc