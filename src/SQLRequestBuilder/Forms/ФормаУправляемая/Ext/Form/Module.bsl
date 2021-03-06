
&НаКлиенте
Процедура Тест(Команда)
	ТестНаСервере();
КонецПроцедуры

&НаСервере
Процедура ТестНаСервере()

	ЭтаОбработка = РеквизитФормыВЗначение("Объект");
	
	ПараметрДерево = РеквизитФормыВЗначение("Дерево");
		
	Результат = ЭтаОбработка.Тест(Код1С, ПараметрДерево);
	
	ЗначениеВРеквизитФормы(ПараметрДерево, "Дерево");

КонецПроцедуры

&НаСервере
Процедура СозданиеКолонокДерева(ПараметрДерево)

    МассивДобавляемыхРеквизитов = Новый Массив;
    Для Каждого Колонка Из ПараметрДерево.Колонки Цикл
        МассивДобавляемыхРеквизитов.Добавить(Новый РеквизитФормы(Колонка.Имя, Колонка.ТипЗначения, "Дерево"));
	КонецЦикла;
	   
    ИзменитьРеквизиты(МассивДобавляемыхРеквизитов);

    Для Каждого Колонка Из ПараметрДерево.Колонки Цикл
        НовыйЭлемент = Элементы.Добавить("Дерево" + Колонка.Имя, Тип("ПолеФормы"),Элементы.Дерево);
        НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
        НовыйЭлемент.ПутьКДанным = "Дерево." + Колонка.Имя;
    КонецЦикла;

КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЭтаОбработка = РеквизитФормыВЗначение("Объект");
	ЭтаОбработка.Инициализация();
	СозданиеКолонокДерева(ЭтаОбработка.ДеревоAST);
КонецПроцедуры



