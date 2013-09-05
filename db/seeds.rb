# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

moscow = Region.create(name: 'Москва', kind: :city)

regions = {"Центральный АО" => ["Арбат",
                                "Басманный",
                                "Замоскворечье",
                                "Красносельский",
                                "Мещанский",
                                "Пресненский",
                                "Таганский",
                                "Тверской",
                                "Хамовники",
                                "Якиманка"],
           "Северный АО" => ['Аэропорт',
                             'Беговой',
                             'Бескудниковский',
                             'Войковский',
                             'Восточное Дегунино',
                             'Головинский',
                             'Дмитровский',
                             'Западное Дегунино',
                             'Коптево',
                             'Левобережный',
                             'Молжаниновский',
                             'Савёловский',
                             'Сокол',
                             'Тимирязевский',
                             'Ховрино',
                             'Хорошёвский'],
           "Северо-Восточный АО" => ['Алексеевский',
                                     'Алтуфьевский',
                                     'Бабушкинский',
                                     'Бибирево',
                                     'Бутырский',
                                     'Лианозово',
                                     'Лосиноостровский',
                                     'Марфино',
                                     'Марьина Роща',
                                     'Останкинский',
                                     'Отрадное',
                                     'Ростокино',
                                     'Свиблово',
                                     'Северный',
                                     'Северное Медведково',
                                     'Южное Медведково',
                                     'Ярославский'],
           "Восточный АО" => ['Богородское',
                              'Вешняки',
                              'Восточный',
                              'Восточное Измайлово',
                              'Гольяново',
                              'Ивановское',
                              'Измайлово',
                              'Косино-Ухтомский',
                              'Метрогородок',
                              'Новогиреево',
                              'Новокосино',
                              'Перово',
                              'Преображенское',
                              'Северное Измайлово',
                              'Соколиная Гора',
                              'Сокольники'],
           "Юго-Восточный АО" => ['Выхино-Жулебино',
                                  'Капотня',
                                  'Кузьминки',
                                  'Лефортово',
                                  'Люблино',
                                  'Марьино',
                                  'Некрасовка',
                                  'Нижегородский',
                                  'Печатники',
                                  'Рязанский',
                                  'Текстильщики',
                                  'Южнопортовый'],
           "Южный АО" => ['Бирюлёво Восточное',
                          'Бирюлёво Западное',
                          'Братеево',
                          'Даниловский',
                          'Донской',
                          'Зябликово',
                          'Москворечье-Сабурово',
                          'Нагатино-Садовники',
                          'Нагатинский Затон',
                          'Нагорный',
                          'Орехово-Борисово Северное',
                          'Орехово-Борисово Южное',
                          'Царицыно',
                          'Чертаново Северное',
                          'Чертаново Центральное',
                          'Чертаново Южное'],
           "Юго-Западный АО" => ['Академический',
                                 'Гагаринский',
                                 'Зюзино',
                                 'Коньково',
                                 'Котловка',
                                 'Ломоносовский',
                                 'Обручевский',
                                 'Северное Бутово',
                                 'Тёплый Стан',
                                 'Черёмушки',
                                 'Южное Бутово',
                                 'Ясенево'],
           "Западный АО" => ['Дорогомилово',
                             'Внуково',
                             'Крылатское',
                             'Кунцево',
                             'Можайский',
                             'Ново-Переделкино',
                             'Очаково-Матвеевское',
                             'Проспект Вернадского',
                             'Раменки',
                             'Солнцево',
                             'Тропарёво-Никулино',
                             'Филёвский Парк',
                             'Фили-Давыдково'],
           "Северо-Западный АО" => ['Куркино',
                                    'Митино',
                                    'Покровское-Стрешнево',
                                    'Северное Тушино',
                                    'Строгино',
                                    'Хорошёво-Мнёвники',
                                    'Щукино',
                                    'Южное Тушино'],
           "Зеленоградский АО" => ['Матушкино',
                                   'Савёлки',
                                   'Старое Крюково',
                                   'Силино',
                                   'Крюково'],
           "Новомосковский АО" => ['Воскресенское',
                                   'Внуковское',
                                   'Десёновское',
                                   'Кокошкино',
                                   'Марушкинское',
                                   'Московский',
                                   '«Мосрентген»',
                                   'Рязановское',
                                   'Сосенское',
                                   'Филимонковское',
                                   'Щербинка'],
           "Троицкий АО" => ['Вороновское',
                             'Киевский',
                             'Клёновское',
                             'Краснопахорское',
                             'Михайлово-Ярцевское',
                             'Новофёдоровское',
                             'Первомайское',
                             'Роговское',
                             'Троицк',
                             'Щаповское']}

regions.each do |adm_region_name, mun_region_names|
  adm_region = Region.create(name: adm_region_name, kind: :adm_region, parent: moscow)
  mun_region_names.each do |mun_region_name|
    Region.create(name: mun_region_name, kind: :mun_region, parent: adm_region)
  end
end

#TODO всё это вынести в yaml и грузить из внешнего файла
adm_regions_with_single_tic = []
adm_regions_with_single_tic << Region.where("name LIKE ?", "%Новомосковский%").first.id
adm_regions_with_single_tic << Region.where("name LIKE ?", "%Троицкий%").first.id

Region.mun_regions.where("parent_id NOT IN (?)", adm_regions_with_single_tic).update_all has_tic: true
Region.adm_regions.where("id IN (?)", adm_regions_with_single_tic).update_all has_tic: true

roles = [
  %w(admin администратор АДМ),
  ['db_operator', 'оператор базы данных', 'ОБД'],
  ["observer", "наблюдатель на участке", "наблюдатель"],
  ["mobile", "участником мобильной группы", "участником мобильной группы"],
  ["callcenter", "оператором колл-центра", "оператором колл-центра"],
  ["federal_repr", "федеральный представитель наблюдательного объединения", "ФП"],
  ["tc", "территориальный координатор", "ТК"],
  ["mc", "координатор мобильной группы", "МК"],
  ["cc", "координатор колл-центра", "КК"],
  ["other", "прочее заинтересованное лицо", "заинтересованное лицо"]
]

roles.each do |slug, name, short_name|
  Role.create slug: slug, name: name, short_name: short_name
end

organisations = ["РосВыборы", "Гражданин Наблюдатель", "Сонар", "Голос"]
organisations.each do |name|
  Organisation.create name: name
end

NominationSource.create :name => 'ЕР', :variant => 'parliament'

NominationSource.create :name => 'КПРФ', :variant => 'party'
NominationSource.create :name => 'СР', :variant => 'party'
NominationSource.create :name => 'ЛДПР', :variant => 'party'
NominationSource.create :name => 'Яблоко', :variant => 'party'
NominationSource.create :name => 'РПР-Парнас', :variant => 'party'

NominationSource.create :name => 'Навальный', :variant => 'candidate'
NominationSource.create :name => 'Митрохин', :variant => 'candidate'
NominationSource.create :name => 'Мельников', :variant => 'candidate'
NominationSource.create :name => 'Дегтярёв', :variant => 'candidate'
NominationSource.create :name => 'Левичев', :variant => 'candidate'
NominationSource.create :name => 'Собянин', :variant => 'candidate'

NominationSource.create :name => 'СМИ', :variant => 'media'
