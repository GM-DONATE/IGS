IGS.LANG["ru"] = {
    lang_name = "Русский", --очевидно
    autodonatecopyright = "Автодонат от gm-donate.net", -- не меняйте пж
    autodonate = "Автодонат",

    --start БАЗА

    balance = "Баланс", -- сверху пишется баланс
    inventory = "Инвентарь",--}
    profile = "Профиль",    -- } эта четверка это кнопки снизу
    purchases = "Покупки",  --}
    store = "Услуги", --      }

    --end БАЗА

    --start ПЛЮРАЛИЗАЦИЯ

    CurrencyPlurals = {
        "алкобакс",  -- 1 алкобакс
        "алкобакса", -- 3 алкобакса
        "алкобаксов" -- 5 алкобаксов
    },

    PL_POYAVILSA = {
        "появился", -- 1 предмет
        "появилось", -- 5 предметов
        "появилось"  -- 100 предметов
    },

    PL_NEW = {
        "новый", -- 1 предмет
        "новых", -- 5 предметов
        "новых" -- 100 предметов
    },

    PL_ITEMS = {
        "предмет",  -- 1 предмет
        "предмета", -- 5 предметов
        "предметов" -- 100 предметов
    },

    PL_DAYS = {
        "день",
        "дня",
        "дней"
    },

    PL_VARIANTS = {"вариант", "варианта", "вариантов"},

    --end ПЛЮРАЛИЗАЦИЯ

    --start Окно об новом предмете
    new_items = "В нашем /donate магазине %s %s %s %s. Желаете взглянуть?",
    new_items_title = "Пополнение магазина",
    --end

    --start ЧАТ
    yourpurchininv = "Ваша покупка находится в /donate инвентаре",
    TopDon_TextRecord = "$nick побил рекорд доната в этом месяце, пополнив счет на $sum руб.\nПредыдущий рекорд установил $nick_prev, пополнив счет на $sum_prev руб",
    TopDon_TextFirstDon = "$nick стал первым, кто задонатил в этом месяце. $nick умничка. Будь как $nick - /donate", -- доступен шаблон $sum
    pldonated = "%s пополнил счет на %s. Его новый Score: %s",
    pldonatedthanks = "Спасибо вам за пополнение счета. " .. "Ваш новый Score на всех проектах - %d. " .. "Что такое Score: vk.cc/caHTZi",
    youcanspend = "Вы можете потратить %s через /donate",
    yourscore = "Ваш Score %s. Подробнее: vk.cc/caHTZi",

    --end ЧАТ

    --start ИНВЕНТАРЬ

    buy = "Покупка",
    activation = "Активация",
    drop = "Дроп",
    pick = "Пик",

    yourinv = "Ваш инвентарь",
    yourinvisempty = "Что-то тут пустовато...",

    activate = "Активировать",
    droponfloor = "Бросить на пол",

    invitemact = "Действия над итемом",
    invchoose = "Выберите предмет, чтобы получить по нему список действий",
    invchooselong = "Купленные предметы будут находится здесь." ..
    "\n\nБлагодаря инвентарю вы можете поделиться покупкой со своим другом, у которого не хватает денег на покупку услуги. " ..
        "Просто купите ее вместо него и бросьте на пол. После активации предмета он появится у него в инвентаре." ..
    "\n\nДобрые саморитяне используют инвентарь для устраивания классных конкурсов. " ..
        "Они набивают свой инвентарь предметами, а затем при каких-то условиях их раздают",

    invinfofpurc = "Здесь будет отображена информация о вашей покупке, когда вы ее сделаете",

    deactivated = "Покупка отключена",
    alrdeactivated = "Услуга уже отключена",
    actionswithinv = "Операции с инвентарем",
    plinvlogtt = "ID операции: %s. Перед ником глобальный Score игрока",
    plinvlogcopysidowner = "Копировать SID владельца",
    plinvlogcopysidinfl = "Копировать SID исполнителя",
    plinvlogactions = "Действия игрока",
    plinvlogactionswith = "Действия с",
    plinvactivation = "Активация",
    plinvdisable = "Отключить",

    doninvlogactions = "Действия",
    doninvlogaction = "Действие",
    doninvlogowner = "Владелец",
    doninvloginfl = "Исполнитель",
    doninvlogitem = "Предмет",
    doninvloggiftid = "ID гифта",
    doninvlogdate = "Дата",

    doninvsearchtext = "SteamID или UID итема",
    doninvfind = "Найти",
    doninvallloaded = "Все загружено (%s)",
    doninvloadmore = "Загрузить еще (%s/%s)",

    --end ИНВЕНТАРЬ

    --start Разное
    latestpurch = "Последние покупки",
    other = "Разное",
    resetfilter = "Сброс фильтров",
    allfrom = "Все по",
    from = "От",
    to = "до",
    loading = "Загрузочка...",
    itemdeystv = "Действ.",
    decsription = "Описание",
    information = "Информация",
    image = "Изображение",
    notification = "Оповещение",
    openpurchases = "Открыть список покупок",
    buisnesslevel = "получил новый (%s) бизнес уровень -",
    npctext = "Донат услуги",
    --end

    --start Купоны
    entercouponcode = "Введите код купона",
    activatecoupon = "Активировать купон",
    couponactivation = "Активация купона",
    couponactivationexp = "Если у вас есть донат купон, то введите его ниже",
    couponactiovationerr = "Ошибка активации купона",
    couponactivationsuccess = "Деньги начислены на ваш счет. Можете посмотреть на это в транзакциях, переоткрыв донат меню",
    couponactivationsuccesstitle = "Успешная активации купона",
    buyed = "купил",
    --end Купоны

    --start Предмет
    buyedwho = "Купил:",
    purchased = "Куплено",
    forwhat = "До:",
    whatserver = "На:",
    endless = "бесконечно",
    forever = "навсегда",
    disposable = "единоразово",
    category = "Категория",
    validto = "Действует",
    price = "Цена",
    nodiscount = "Без скидки",
    doesitstack = "Покупки стакаются",
    buyfor = "Купить за",
    notenoughmoney = "Недостаточно денег",
    notenoughmoneyexp = "Вам не хватает %s для покупки %s.\nЖелаете мгновенно пополнить счет?",

    yesitdoes = "да",
    noitdoesnt = "нет",

    --end

    --start Профиль
    profileinfo = "Информация профиля",
    profilestatus = "Статус",
    profilenobody = "Никто :(",
    profilenextstatus = "След. статус",
    profileneedenforstat = "Нужно",
    profiletransactions = "Транзакции",
    profileserver = "Сервер",
    profileammount = "Сумма",
    profilebalance = "Баланс",
    profileaction = "Действия",
    profiledate = "Дата",
    profilelasttransactions = "Последние %s транзакции",

    profileaddmoney = "Пополнение счета",
    profilecoupon = "Купон",
    profiletransid = "ID транзакции в системе:",
    profileoriglabel = "Оригинальная отметка:",
    profilenumoftrans = "Операций",
    profiletransic = "1 Операция",
    profilenumoftranspcs = "Шт.", -- сколько было транзакций
    profilenotrans = "Не было",

    --end

    --start Окно пополнения
    depositsum = "Введите ниже сумму пополнения счета",
    depositbtn = "Пополнить счет на %s руб",
    depostisumerr = "Указана некорректная сумма пополнения",
    depostiminimal = "Минимальная сумма пополнения",
    depositsafekey = "Запрос цифровой подписи запроса от сервера...",
    deposittitle = "Процедура пополнения счета",
    depositgotkey = "Подпись получена. начинаем процесс оплаты",
    depositfundsauto = "Счет пополнится моментально или после перезахода",
    depositlog = "Лог операций",
    depositopened = "Открыт диалог пополнения счета",
    depositconnected = "Соединение установлено!",
    depositfastestfund = "Деньги будут зачислены мгновенно и автоматически",
    deposticheckfrom = "Проверка возможности платежа через",
    depostiadded = "Начислено",
    depositerror = "Ошибка пополнения счета:",
    depositerror1 = "С сервера пришел неизвестный метод",
    depositerror2 = "и возникла ошибка",
    depositupdate = "Обновление статуса платежа",


    --end

    --start Покупки
    limitedbuy = "Вы купили %s %s раз из %s",
    limitederr = "Этот предмет можно купить только %s раз(а)",
    itemgivenon = "Предмет выдан на %s серверах",
    yourecieved = "Вы получили",
    yourecieveditems = "В ваш инвентарь добавлено %s предметов",
    activepurchases = "Активные покупки",
    purchasebuyed = "Куплен",
    purchaseexpire = "Истечет",
    purchaseswhatshere = "Что тут?",
    purchasesexplain = "Здесь будут отображаться ваши активные покупки\n\n" .. "Не самое ли подходящее время, чтобы совершить первую?\n\n" .. "Табличка сразу станет красивее. Честно-честно",
    purchasealrhaveexpl = "Слева отображаются ваши активные услуги.\n\n" .. "Чем больше услуг, тем красивее эта табличка выглядит, а администрация более счастливая ;)",

    purchasebuybtn = "Купить плюшку",
    purchasenever = "Никогда",
    purchasedesc = "Имя сервера: %s\nID в системе: %s\nОригинальное название: ", -- тут пробел в конце
    purchasedone = "Успешная покупка",
    purchasethanks = "Спасибо за покупку. Это было просто, правда? :)",
    purchasethxandact = "Спасибо за покупку. Она находится в вашем /donate инвентаре.\n\nАктивировать ее сейчас?",

    --end

    --start Оружие
    weapgiveonspawn = "Выдавать при спавне",
    weapwillgivenonspawn = "будет выдаваться при спавне",
    weapnot = "не",
    weapwillgivenonresawn = "%s теперь будет выдаваться при каждом респавне. " .. "Если вы хотите временно отключить выдачу, " .. "то снимите галочку в карточке предмета в /donate меню",
    --end

    --start Vehicle
    vehalrspawned = "У вас есть заспавнена эта машина",
    --end

    --start Активация
    statusdisabled = "Откл.",
    statusglobal = "Глоб.",
    itemactivatedthx = "Предмет активирован. Спасибо вам!",
    itemactivated = "Успешная активация",
    --end

    --start Энтити
    invoverloaded = "У вас слишком много предметов в инвентаре",
    itemmoving = "Предмет в процессе перемещения в инвентарь",
    iferror = "Если процесс бесконечный, то поскорее сделайте доказательства и сообщите администратору",
    itemmoved = "Предмет помещен в /donate инвентарь",
    validuntil = "Действует",
    --end

    --start Ошибки

    error = "Ошибка",
    isunpacked = "Похоже, что автодонат распакован в /addons. Автоматические обновления недоступны",
    isworkshop = "Удалите автодонат из вашей коллекции в воркшопе. Обновления работают через GitHub",
    autodonatedisabled = "Автодонат временно отключен",
    transactiononotherserver = "Транзакция на другом сервере",
    dropdisabled = "Дроп предметов отключен администратором",
    autodonateisnotworking = "Автодонат временно не работает",
    autodonateisnotloaded = "[IGS] Автодонат не загружен",
    autodonateinstalledwrong = "[IGS] Автодонат установлен неправильно. Сообщите администрации",
    howdidyoufindme = "Как вы меня нашли?",
    youbroke = "Для покупки нужно",
    invisfull = "У вас перегруз в донат инвентаре. А еще вы один из немногих, кто видел это!",
    purchinprogress = "Запрос на покупку в процессе. Подождите, пожалуйста",
    purcherror = "Ошибка покупки %s: %s",
    purchaseerror = "Ошибка покупки",
    invisdisabled = "Инвентарь отключен. Активация предметов моментальная",
    itemisalractivated = "Предмет уже активирован. ID:",
    itemnotfound = "Предмет не найден. Возможно, уже активирован",
    noitem = "Этот предмет, скорее всего, когда-то существовал или существует на другом сервере, но не здесь",
    noitemfound = "Этого предмета на сервере нет. Как вы нашли его?",
    noitembro = "Этого предмета на сервере нет. Можете уничтожить его",
    acterror = "Ошибка активации",
    itsonlyfordonater = "Это для донатеров (/donate)",
    thisitemisover = "Этот предмет закончился",
    noitemsinconf = "Настройте предметы автодоната в sh_additems.lua",

    -- end Ошибки

    --start Панель
    panelgaveitem = "Вам выдана новая услуга:",
    panelmoveordisableitem = "Перезагрузка списка покупок из-за переноса или отключения услуг",
    paneltableresetted = "Список перезагружен",
    panelinvreset = "Перезагрузка инвентаря",
    panelinvresetted = "Инвентарь перезагружен",

    --end Панель

    --start BWHITELIST
    youinawhitelist = "Вы в вайтлисте",
    --end

    --start ULX
    youalrhavethat = "У вас уже действует эта услуга",
    autorecovery = "Автовосстановление %s для %s",
    --end

    --start SERVERGUARD
    setssgrouperr = "IGS: В SetSGGroup указана несуществующая группа",
    --end

    --start DARKRP
    drpmoneydesc = "Мгновенно и без проблем пополняет баланс игровой валюты на %s валюты.",

}
