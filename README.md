# РосВыборы / База наблюдателей

Задача РосВыборов - ввести в состав каждой ТИК/УИК максимально возможное количество своих наблюдателей в ролях ПСГ, наблюдатель и представитель СМИ, максимизировать время нахождения своих наблюдаталей на участках, обеспечить поддержку наблюдателей мобильными группами и контакт-центром.

РосВыборы вводит в состав комиссий своих наблюдателей, пользуясь в качестве источников выдвижения дружественными кандидатами, партиями и СМИ. Система РосВыборы позволяет собрать волонтёров, наделить их нужными ролями в наблюдательном процессе, равномерно распределить на участки, организовать мобильные группы и контакт-ценрты, и координировать работу всех участников на этапах подготовки и проведения выборов.

Подробности и постановки(реализовано не всё) можно посмотреть на [wiki](https://github.com/fbkinfo/rosvybory/wiki)


##Описание

В проекте логически можно выделить следующие основные части:

- Форма для создания заявок наблюдателей:
 - Сама форма, на DSL Formtastic'a, валидация через модель заявки
 - Результат заполнения формы - заявка, `UserApp`


- Админка `/control`, позволяющая просматривать созданные заявки, искать среди них нужные с помощью фильтров, создавать на их основе записи о людях, и т.п, по ТЗ.
 - Реализация админки - на основе [Active Admin](https://github.com/gregbell/active_admin)
 - Разграничение доступа - через CanCan по [ролям](https://github.com/fbkinfo/rosvybory/wiki/%D0%A0%D0%BE%D0%BB%D0%B8#%D0%A0%D0%BE%D0%BB%D0%B8-%D0%B2-%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D0%B5-%D0%BC%D0%BE%D0%B4%D0%B5%D0%BB%D1%8C-role) пользователей (`UserRole`)
 - Груповая рассылка писем и смс - через Resque и sms.ru
 - Импорт заявок из xls заявленного вида
 - Экспорт пользователей в xls

- Колцентр
 - Форма фиксации обращения для оператора КЦ `/call_center/reports/new`
 - Список зафикцированных сообщений в админке `/control/call_center_reports` с возможностью модерации
 - Выгрузка нарушений в JSON-файл / загрузка данных на карту нарушений в реальном времени - через Resque

##Установка

Пример разворачивания на ubuntu [есть в вики](https://github.com/fbkinfo/rosvybory/wiki/%D0%A0%D0%B0%D0%B7%D0%B2%D1%91%D1%80%D1%82%D1%8B%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82%D0%B0-%D1%81-%D0%BD%D1%83%D0%BB%D1%8F-%D0%BF%D0%BE%D0%B4-Ubuntu-Server).


##Участие

* Fork
* Create a topic branch - `git checkout -b feature-cool-stuff`
* Rebase your branch so that all your changes are reflected in one
  commit
* Push to your branch - `git push origin my_branch`
* Create a Pull Request from your branch, include as much documentation
  as you can in the commit message/pull request, following these
[guidelines on writing a good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
* That's it!
 
