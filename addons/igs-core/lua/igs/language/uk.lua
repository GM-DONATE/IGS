IGS.LANG["uk"] = {
    lang_name = "Український", --очевидно
    autodonatecopyright = "Автодонат вiд gm-donate.net", -- не мiняйте пж
    autodonate = "Автодонат",

    -- start БАЗА

    balance = "Баланс", -- зверху пишеться баланс
    inventory = "Iнвентар",--}
    profile = "Профiль",-- } ця четвiрка це кнопки знизу
    purchases = "Покупки",--}
    store = "Послуги",-- }

    -- end БАЗА

    -- start плюралiзацiя

    CurrencyPlurals = {
        "алкобакс", -- 1 алкобакс
        "алкобакса", -- 3 алкобакса
        "алкобаксов" -- 5 алкобаксов
    },

    PL_POYAVILSA = {
        "з'явився", -- 1 предмет
        "з'явилося", -- 5 предметiв
        "з'явилося" -- 100 предметiв
    },

    PL_NEW = {
        "Новий", -- 1 предмет
        "нових", -- 5 предметiв
        "нових" -- 100 предметiв
    },

    PL_ITEMS = {
        "предмет", -- 1 предмет
        "предмета", -- 5 предметiв
        "предметiв" -- 100 предметiв
    },

    PL_DAYS = {
        "день",
        "день",
        "день"
    },

    PL_VARIANTS = {"варiант", "варiанти", "варiантiв"},

    --end ПЛЮРАЛИЗАЦИЯ

    --start Окно об новом предмете
    new_items = " в нашому /donate магазинi %s %s %s %s. бажаєте поглянути?",
    new_items_title = "Поповнення магазину",
    --end

    --start ЧАТ
    yourpurchininv = "Ваша покупка знаходиться в /donate iнвентарi",
    TopDon_TextRecord = "$nick побив рекорд доната в цьому мiсяцi, поповнивши рахунок на $sum руб.\nПопереднiй рекорд встановив $nick_prev, поповнивши рахунок на $sum_prev руб",
    TopDon_TextFirstDon = " $ nick став першим, хто задонатiл в цьому мiсяцi. $nick розумниця. Будь як $nick - /donate", -- доступний шаблон $ sum
    pldonated = "% s поповнив рахунок на %s. Його новий Score: %s",
    pldonatedthanks = " дякую вам за поповнення рахунку. " .. "Ваш новий Score на всiх проектах - %d." .. "Що таке Score: vk.cc/caHTZi",
    youcanspend = "Ви можете витратити %s через /donate ",
    yourscore = "Ваш Score % s. Детальнiше: vk.cc/caHTZi",

    --end ЧАТ

    --start ИНВЕНТАРЬ

    buy = "Покупка",
    activation = "Активацiя",
    drop = "Дроп",
    pick = "Пiк",

    yourinv = "Ваш iнвентар",
    yourinvisempty = "Щось тут порожньо...",

    activate = "Активувати",
    droponfloor = "Кинути на пiдлогу",

    invitemact = "Дiї над iтемом",
    invchoose = "Виберiть предмет, щоб отримати по ньому список дiй",
    invchooselong = "Купленi предмети будуть знаходиться тут." ..
    "\n\nЗавдяки iнвентарю ви можете подiлитися покупкою зi своїм другом, у якого не вистачає грошей на покупку послуги. " ..
        "Просто купiть її замiсть нього i киньте на пiдлогу. Пiсля активацiї предмета вiн з'явиться у нього в iнвентарi." ..
    "\n\nдобрие саморитяни використовують iнвентар для влаштовування класних конкурсiв. " ..
        "Вони набивають свiй iнвентар предметами, а потiм за якихось умов їх роздають",

    invinfofpurc = "Тут буде вiдображена iнформацiя про вашу покупку, коли ви її зробите",

    deactivated = "Покупка вiдключена",
    alrdeactivated = "Послуга вже вiдключена",
    actionswithinv = "Операцiї з iнвентарем",
    plinvlogtt = "ID операцiї: %s. Перед нiком глобальний Score гравця",
    plinvlogcopysidowner = "Копiювати SID власника",
    plinvlogcopysidinfl = "Копiювати SID виконавця",
    plinvlogactions = "Дiї гравця",
    plinvlogactionswith = "Дiї з", -- не забудьте пробiл
    plinvactivation = "Активацiя",
    plinvdisable = "Вимкнути",

    doninvlogactions = "Дiї",
    doninvlogaction = "Дiя",
    doninvlogowner = "Власник",
    doninvloginfl = "Виконавець",
    doninvlogitem = "Предмет",
    doninvloggiftid = "ID GIFTA",
    doninvlogdate = "Дата",

    doninvsearchtext = "SteamID або UID iтема",
    doninvfind = "Знайти",
    doninvallloaded = "Все завантажено (%s)",
    doninvloadmore = "Завантажити бiльше (%s / %s)",

    --end ИНВЕНТАРЬ

    --start Разное
    latestpurch = "Останнi покупки",
    other = "Рiзне",
    resetfilter = "Скидання фiльтрiв",
    allfrom = "Все по",
    from = "Вiд",
    to = "до",
    loading = "Загрузочка...",
    itemdeystv = "Дiйств.",
    decsription = "Опис",
    information = "Iнформацiя",
    image = "Зображення",
    notification = "Оповiщення",
    openpurchases = "Вiдкрити список покупок",
    buisnesslevel = "отримав новий (%s) бiзнес рiвень -",
    npctext = "Донат послуги",

    --end

    --start Купоны
    entercouponcode = "Введiть код купона",
    activatecoupon = "Активувати купон",
    couponactivation = "Активацiя купона",
    couponactivationexp = "Якщо у вас є донат купон, то введiть його нижче",
    couponactiovationerr = "Помилка активацiї купона",
    couponactivationsuccess = "Грошi нарахованi на ваш рахунок. Можете подивитися на це в транзакцiях, перевiдкривши донат меню",
    couponactivationsuccesstitle = "Успiшна активацiї купона",
    buyed = "купив",
    --end Купоны

    --start Предмет
    buyedwho = "Купив:",
    purchased = "Куплено",
    forwhat = "До:",
    whatserver = "На:",
    endless = "нескiнченно",
    forever = "назавжди",
    disposable = "Одноразово",
    category = "Категорiя",
    validto = "Дiє",
    price = "Цiна",
    nodiscount = "Без знижки",
    doesitstack = "Покупки",
    buyfor = "Купити за",
    notenoughmoney = "недостатньо грошей",
    notenoughmoneyexp = " вам не вистачає %s для покупки %s. \nЖелаете миттєво поповнити рахунок?",

    yesitdoes = "Так",
    noitdoesnt = "Нi",

    --end

    --start Профиль
    profileinfo = "Iнформацiя профiлю",
    profilestatus = "Статус",
    profilenobody = "Нiхто :(",
    profilenextstatus = "Слiд. статус",
    profileneedenforstat = "Потрiбно",
    profiletransactions = "Транзакцiї",
    profileserver = "Сервер",
    profileammount = "Сума",
    profilebalance = "Баланс",
    profileaction = "Дiї",
    profiledate = "Дата",
    profilelasttransactions = "Останнi %s транзакцiї",

    profileaddmoney = "Поповнення рахунку",
    profilecoupon = "Купон",
    profiletransid = "ID транзакцiї в системi:",
    profileoriglabel = "Оригiнальна позначка:",
    profilenumoftrans = "операцiй",
    profiletransic = "1 операцiя",
    profilenumoftranspcs = " Шт.", -- скiльки було транзакцiй
    profilenotrans = "Не було",

    --end

    --start Окно пополнения
    depositsum = "Введiть нижче суму поповнення рахунку",
    depositbtn = "Поповнити рахунок на % S руб",
    depostisumerr = "Вказана некоректна сума поповнення",
    depostiminimal = "Мiнiмальна сума поповнення",
    depositsafekey = "Запит цифрового пiдпису запиту вiд сервера...",
    deposittitle = "Процедура поповнення рахунку",
    depositgotkey = "Пiдпис отримано. починаємо процес оплати",
    depositfundsauto = "Рахунок поповниться моментально або пiсля перезаходу",
    depositlog = "Лог операцiй",
    depositopened = "Вiдкрито дiалог поповнення рахунку",
    depositconnected = " З'єднання встановлено!",
    depositfastestfund = "Грошi будуть зарахованi миттєво i автоматично",
    deposticheckfrom = "Перевiрка можливостi платежу через",
    depostiadded = "Нараховано",
    depositerror = "помилка поповнення рахунку:",
    depositerror1 = "З сервера прийшов невiдомий метод",
    depositerror2 = "i виникла помилка",
    depositupdate = "Оновлення статусу платежу",


    --end

    --start Покупки
    limitedbuy = "Ви купили %s %S разiв з % s",
    limitederr = "Цей предмет можна купити тiльки %s раз (а)",
    itemgivenon = "Предмет виданий на % S серверах",
    yourecieved = "Ви отримали",
    yourecieveditems = "У ваш iнвентар додано %s предметiв",
    activepurchases = "Активнi покупки",
    purchasebuyed = "Куплений",
    purchaseexpire = "Закiнчиться",
    purchaseswhatshere = "Що тут?",
    purchasesexplain = "Тут вiдображатимуться вашi активнi покупки\n\n".. "Чи не найкращий час, щоб зробити першу?\n\n" .. "Табличка вiдразу стане красивiшою. Чесно-чесно",
    purchasealrhaveexpl = "злiва вiдображаються вашi активнi послуги.\n\n" .. "Чим бiльше послуг, тим красивiше ця табличка виглядає, а адмiнiстрацiя бiльш щаслива ;)",

    purchasebuybtn = "Купити плюшку",
    purchasenever = "Нiколи",
    purchasedesc = "iм'я сервера: %s \nID в системi: %s\nОригинальное назва: ", -- тут пробел в конце
    purchasedone = "Eспiшна покупка",
    purchasethanks = " Дякую за покупку. Це було просто, правда? :)",
    purchasethxandact = "Дякую за покупку. Вона знаходиться у вашому /donate iнвентарi.\n\nпактив її зараз?",
    --end

    -- start зброю
    weapgiveonspawn = "Видавати при спавнi",
    weapwillgivenonspawn = "буде видаватися при спавнi",
    weapnot = "не", 
    weapwillgivenonresawn = " %s тепер буде видаватися при кожному респавнi. " .. "Якщо ви хочете тимчасово вiдключити видачу," .. "то знiмiть галочку в картцi предмета в /donate меню",
    --end

    --start Vehicle
    vehalrspawned = "У вас є заспавнена ця машина",
    --end

    --start Активация
    statusdisabled = "Откл.",
    statusglobal = "Глоб.",
    itemactivatedthx = "Предмет активовано. Дякую вам!",
    itemactivated = "Успiшна активацiя",
    --end

    --start Энтити
    invoverloaded = "У вас занадто багато предметiв в iнвентарi",
    itemmoving = "Предмет в процесi перемiщення в iнвентар",
    iferror = "Якщо процес нескiнченний, то скорiше зробiть докази i повiдомте адмiнiстратору",
    itemmoved = "Предмет помiщений в /donate iнвентар",
    validuntil = "Дiє",
    --end

    --start Ошибки

    error = "Помилка",
    isunpacked = "Схоже, автодонат розпаковано в /addons. Автоматичнi оновлення недоступнi",
    isworkshop = "Видалiть автодонат з вашої колекцiї в воркшопi. Оновлення працюють через GitHub",
    autodonatedisabled = "Автодонат тимчасово вимкнено",
    transactiononotherserver = "Иранзакцiя на iншому серверi",
    dropdisabled = "Дроп предметiв вiдключений адмiнiстратором",
    autodonateisnotworking = "Автодонат тимчасово не працює",
    autodonateisnotloaded = "[IGS] Автодонат не завантажений",
    autodonateinstalledwrong = " [IGS] Автодонат встановлений неправильно. Повiдомте адмiнiстрацiї",
    howdidyoufindme = "Як ти мене знайшов?",
    youbroke = "Для покупки потрiбно",
    invisfull = " У вас перевантаження в донат iнвентарi. А ще ви один з небагатьох, хто бачив це!",
    purchinprogress = " запит на покупку в процесi. Зачекайте, будь ласка",
    purcherror = "Помилка покупки %s: %s",
    purchaseerror = "Помилка покупки",
    invisdisabled = "Iнвентар вимкнено. Активацiя предметiв моментальна",
    itemisalractivated = "Предмет вже активовано. ID:",
    itemnotfound = "Предмет не знайдено. Можливо, вже активовано",
    noitem = "Цей предмет, швидше за все, колись iснував або iснує на iншому серверi, але не тут",
    noitemfound = "Цього елемента на серверi немає. Як Ви знайшли його?",
    noitembro = "Цього елемента на серверi немає. Можете знищити його",
    acterror = "Помилка активацiї",
    itsonlyfordonater = "Це для донатерiв (/donate)",
    thisitemisover = "Цей предмет закiнчився",
    noitemsinconf = " Налаштуйте елементи автодонату в sh_additems.lua",

    -- end Ошибки

    --start Панель
    panelgaveitem = "Вам видана нова послуга:",
    panelmoveordisableitem = "Перезавантаження списку покупок через перенесення або вiдключення послуг",
    paneltableresetted = "Список перезавантажено",
    panelinvreset = "Перезавантаження iнвентарю",
    panelinvresetted = "Iнвентар перезавантажено",

    --end Панель

    --start BWHITELIST
    youinawhitelist = "Ви у вайтлiстi",
    --end

    --start ULX
    youalrhavethat = "У Вас вже дiє ця послуга",
    autorecovery = "Автовiдновлення %s для % s",
    --end

    --start SERVERGUARD
    setssgrouperr = "IGS: у SetSGGroup вказана неiснуюча група",
    --end

    --start DARKRP
    drpmoneydesc = "Миттєво i без проблем поповнює баланс iгрової валюти на %s валюти.",

}
