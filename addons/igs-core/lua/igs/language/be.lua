IGS.LANG["be"] = {
    lang_name = "Беларуская", --очевидно
    autodonatecopyright = "Аўтаданат ад gm-donate.net", -- не мяняйце калі ласка
    autodonate = "Аўтаданат",

    --start БАЗА

    balance = "Баланс", -- зверху пішацца баланс
    inventory = "Інвентар",--}
    profile = "Профіль",    -- } гэтая чацвёрка гэта кнопкі знізу
    purchases = "Пакупкі",  --}
    store = "Паслугі", --      }

    --end БАЗА

    --start ПЛЮРАЛІЗАЦЫЯ

    CurrencyPlurals = {
        "алкабакс",  -- 1 алкабакс
        "алкабакса", -- 3 алкабакса
        "алкабаксаў" -- 5 алкабаксаў
    },

    PL_POYAVILSA = {
        "з'явіўся", -- 1 прадмет
        "з'явілася", -- 5 прадметаў
        "з'явілася"  -- 100 прадметаў
    },

    PL_NEW = {
        "новы", -- 1 прадмет
        "новых", -- 5 прадметаў
        "новых" -- 100 прадметаў
    },

    PL_ITEMS = {
        "прадмет",  -- 1 прадмет
        "прадмета", -- 5 прадметаў
        "прадметаў" -- 100 прадметаў
    },

    PL_DAYS = {
        "дзень",
        "дні",
        "дзён"
    },

    PL_VARIANTS = {"варыянт", "варыянта", "варыянтаў"},

    --end ПЛЮРАЛІЗАЦЫЯ

    --start Вокны пра новы прадмет
    new_items = "У нашым /donate краме %s %s %s %s. Жадаеце паглядзець?",
    new_items_title = "Папаўненне крамы",
    --end

    --start ЧАТ
    yourpurchininv = "Ваша купля знаходзіцца ў /donate інвентары",
    TopDon_TextRecord = "$nick пабіў рэкорд даната ў гэтым месяцы, папоўніўшы рахунак на $sum руб.\nПапярэдні рэкорд устанавіў $nick_prev, папоўніўшы рахунак на $sum_prev руб",
    TopDon_TextFirstDon = "$nick стаў першым, хто задонаціў у гэтым месяцы. $nick малайчына. Будзь як $nick - /donate", -- даступны шаблон $sum
    pldonated = "%s папоўніў рахунак на %s. Яго новы Score: %s",
    pldonatedthanks = "Дзякуй вам за папаўненне рахунку. " .. "Ваш новы Score на ўсіх праектах - %d. " .. "Што такое Score: vk.cc/caHTZi",
    youcanspend = "Вы можаце патраціць %s праз /donate",
    yourscore = "Ваш Score %s. Падрабязней: vk.cc/caHTZi",

    --end ЧАТ

    --start ІНВЕНТАР

    buy = "Купля",
    activation = "Актывацыя",
    drop = "Дроп",
    pick = "Пік",

    yourinv = "Ваш інвентар",
    yourinvisempty = "Што-то тут пуставата...",

    activate = "Актываваць",
    droponfloor = "Кінуць на падлогу",

    invitemact = "Дзеянні над прадметам",
    invchoose = "Абярыце прадмет, каб атрымаць па ім спіс дзеянняў",
    invchooselong = "Купленыя прадметы будуць знаходзіцца тут." ..
    "\n\nДзякуючы інвентару вы можаце падзяліцца купляй з сваім сябрам, у якога не хапае грошай на куплю паслугі. " ..
        "Проста купіце яе замест яго і кінуць на падлогу. Пасля актывацыі прадмета ён з'явіцца ў яго ў інвентары." ..
    "\n\nДобрыя самарыцяне выкарыстоўваюць інвентар для арганізацыі класных конкурсаў. " ..
        "Яны набіваюць свой інвентар прадметамі, а потым пры якіх-небудзь умовах іх раздаюць",

    invinfofpurc = "Тут будзе адлюстравана інфармацыя аб вашай куплі, калі вы яе зробіце",

    deactivated = "Купля адключаная",
    alrdeactivated = "Паслуга ўжо адключаная",
    actionswithinv = "Аперацыі з інвентарам",
    plinvlogtt = "ID аперацыі: %s. Перад нікнеймам глабальны Score гульца",
    plinvlogcopysidowner = "Скапіраваць SID ўладальніка",
    plinvlogcopysidinfl = "Скапіраваць SID выканаўца",
    plinvlogactions = "Дзеянні гульца",
    plinvlogactionswith = "Дзеянні з ", -- не забудзьце прабел
    plinvactivation = "Актывацыя",
    plinvdisable = "Адключыць",

    doninvlogactions = "Дзеянні",
    doninvlogaction = "Дзеянне",
    doninvlogowner = "Уладальнік",
    doninvloginfl = "Выканаўца",
    doninvlogitem = "Прадмет",
    doninvloggiftid = "ID гіфта",
    doninvlogdate = "Дата",

    doninvsearchtext = "SteamID або UID прадмета",
    doninvfind = "Знайсці",
    doninvallloaded = "Усё загружана (%s)",
    doninvloadmore = "Загрузіць яшчэ (%s/%s)",

    --end ІНВЕНТАР

    --start Рознае
    latestpurch = "Апошнія куплі",
    other = "Рознае",
    resetfilter = "Скід фільтраў",
    allfrom = "Усё па",
    from = "Ад",
    to = "да",
    loading = "Загрузка...",
    itemdeystv = "Дзеян.",
    decsription = "Апісанне",
    information = "Інфармацыя",
    image = "Малюнак",
    notification = "Паведамленне",
    openpurchases = "Адкрыць спіс купляў",
    buisnesslevel = "атрымаў новы (%s) бізнес ўзровень -",
    npctext = "Данат паслугі",

    --end

    --start Купоны
    entercouponcode = "Увядзіце код купона",
    activatecoupon = "Актываваць купон",
    couponactivation = "Актывацыя купона",
    couponactivationexp = "Калі ў вас ёсць донат купон, увядзіце яго ніжэй",
    couponactiovationerr = "Памылка актывацыі купона",
    couponactivationsuccess = "Грошы залічаны на ваш рахунак. Можаце паглядзець на гэта ў транзакцыях, пераадкрыўшы донат меню",
    couponactivationsuccesstitle = "Паспяховая актывацыя купона",
    buyed = "купіў",
    --end Купоны

    --start Прадмет
    buyedwho = "Купіў:",
    purchased = "Куплена",
    forwhat = "Да: ",
    whatserver = "На:",
    endless = "бясконца",
    forever = "назаўжды",
    disposable = "аднаразова",
    category = "Катэгорыя",
    validto = "Дзейнічае",
    price = "Цана",
    nodiscount = "Без зніжкі",
    doesitstack = "Куплі стакаюцца",
    buyfor = "Купіць за",
    notenoughmoney = "Недастаткова грошай",
    notenoughmoneyexp = "Вам не хапае %s для куплі %s.\nЖадаеце імгненна папоўніць рахунак?",

    yesitdoes = "так",
    noitdoesnt = "не",

    --end

    --start Профіль
    profileinfo = "Інфармацыя профілю",
    profilestatus = "Статус",
    profilenobody = "Ніхто :(",
    profilenextstatus = "Наступны статус",
    profileneedenforstat = "Патрэбна",
    profiletransactions = "Транзакцыі",
    profileserver = "Сервер",
    -- ai stop
    profileammount = "Сума",
    profilebalance = "Баланс",
    profileaction = "Дзеянне",
    profiledate = "Дата",
    profilelasttransactions = "Апошнія % s транзакцыі",

    profileaddmoney = "Папаўненне рахунку",
    profilecoupon = "Купон",
    profiletransid = "ID транзакцыі ў сістэме:",
    profileoriglabel = "Арыгінальная адзнака:",
    profilenumoftrans = "Аперацыя",
    profiletransic = "1 Аперацыя",
    profilenumoftranspcs = "Шт.", -- сколько было транзакций
    profilenotrans = "Не было",

    --end

    --start Окно пополнения
    depositsum = "Увядзіце ніжэй суму папаўнення рахунку",
    depositbtn = "Папоўніць рахунак на %s руб",
    depostisumerr = "Указана некарэктная сума папаўнення",
    depostiminimal = "Мінімальная сума папаўнення",
    depositsafekey = "Запыт лічбавага подпісу запыту ад сервера...",
    deposittitle = "Працэдура папаўнення рахунку",
    depositgotkey = "Подпіс атрыманы. пачынаем працэс аплаты",
    depositfundsauto = "Кошт папоўніцца маментальна або пасля перезахода",
    depositlog = "Лагістыка",
    depositopened = "Адкрыты дыялог папаўнення рахунку",
    depositconnected = "Злучэнне ўстаноўлена!",
    depositfastestfund = "Грошы будуць залічаны імгненна і аўтаматычна",
    deposticheckfrom = "Праверка магчымасці плацяжу праз",
    depostiadded = "Налічаны",
    depositerror = "Памылка папаўнення рахунку:",
    depositerror1 = "З сервера прыйшоў невядомы метад",
    depositerror2 = "і ўзнікла памылка",
    depositupdate = "Абнаўленне статусу плацяжу",


    --end

    --start Покупки
    limitedbuy = "Вы купілі %s %S раз з %s",
    limitederr = "Гэты прадмет можна купіць толькі %s раз(а)",
    itemgivenon = "Прадмет выдадзены на %S серверах",
    yourecieved = "Вы атрымалі", -- не забудзьцеся пра прабел
    yourecieveditems = "У ваш інвентар дададзена %s прадметаў",
    activepurchases = "Актыўныя пакупкі",
    purchasebuyed = "Набыты",
    purchaseexpire = "Скончыцца",
    purchaseswhatshere = "Што тут?",
    purchasesexplain = "Тут будуць адлюстроўвацца вашыя актыўныя пакупкі\n\n" .. "Ці не самы зручны час, каб здзейсніць першую?\n\n" .. "Таблічка адразу стане прыгажэй. Шчыра-сумленна",
    purchasealrhaveexpl = "Злева адлюстроўваюцца вашы актыўныя паслугі.\n\n" .. "Чым больш паслуг, тым прыгажэй гэтая шыльда выглядае, а адміністрацыя больш шчаслівая ;)",

    purchasebuybtn = "Купіць плюшку",
    purchasenever = "Ніколі",
    purchasedesc = "Iмя сервера: %s\nID ў сістэме: %s\nОригинальное назва: ", -- тут пробел в конце
    purchasedone = "Паспяховая купля",
    purchasethanks = "Дзякуй за куплю. Гэта было проста, праўда? :)",
    purchasethxandact = "Дзякуй за куплю. Яна знаходзіцца ў вашым /donate інвентары.\n\nАктивировать яе цяпер?",
    --end

    --start Оружие
    weapgiveonspawn = "Выдаваць пры спаўне",
    weapwillgivenonspawn = "будзе выдавацца пры спаўне",
    weapnot = "не",
    weapwillgivenonresawn = "%s цяпер будзе выдавацца пры кожным респавне. " .. "Калі вы хочаце часова адключыць выдачу," .. "то зніміце галачку ў картцы прадмета ў / donate меню",    --end

    --start Vehicle
    vehalrspawned = "У вас ёсць заспавнена гэтая машына",
    --end

    --start Активация
    statusdisabled = "Адкл.",
    statusglobal = "Глоба.",
    itemactivatedthx = "Прадмет актываваны. Дзякуй вам!",
    itemactivated = "Паспяховая актывацыя",
    --end

    --start Энтити
    invoverloaded = "У вас занадта шмат прадметаў у інвентары",
    itemmoving = "Прадмет у працэсе перамяшчэння ў інвентар",
    iferror = "Калі працэс бясконцы, то хутчэй зрабіце доказы i паведаміце адміністратару",
    itemmoved = "Прадмет змешчаны ў /donate інвентар",
    validuntil = "Дзейнічае",
    --end

    --start Ошибки

    error = "Памылка",
    isunpacked = "Падобна на тое, што аўтадонат распакаваны ў /addons. Аўтаматычныя абнаўлення недаступныя",
    isworkshop = "Выдаліце аўтадонат з вашай калекцыі ў воркшопе. Абнаўлення працуюць праз GitHub",
    autodonatedisabled = "Аўтадонат часова адключаны",
    transactiononotherserver = "Транзакцыя на іншым серверы",
    dropdisabled = "Дропшыппінг адключаны адміністратарам",
    autodonateisnotworking = "Аўтадонат часова не працуе",
    autodonateisnotloaded = "[IGS] Аўтадонат не загружаны",
    autodonateinstalledwrong = "[IGS] Аўтадонат усталяваны няправільна. Паведаміце адміністрацыі",
    howdidyoufindme = "Як вы Мяне знайшлі?",
    youbroke = "Для куплі трэба",
    invisfull = "У вас перагруз у Данат інвентары. А яшчэ вы адзін з нямногіх, хто бачыў гэта!",
    purchinprogress = "Запыт на куплю ў працэсе. Пачакайце, калі ласка",
    purcherror = "Памылка пакупкі %s: %s",
    purchaseerror = "Памылка пакупкі",
    invisdisabled = "Iнвентар адключаны. Актывацыя прадметаў",
    itemisalractivated = "Прадмет ужо актываваны. ID:",
    itemnotfound = "Прадмет не знойдзены. Магчыма, ужо актываваны",
    noitem = "Гэты прадмет, хутчэй за ўсё, калісьці існаваў або існуе на іншым серверы, але не тут",
    noitemfound = "Гэтага прадмета на сэрвэры няма. Як вы знайшлі яго?",
    noitembro = " Гэтага прадмета на сэрвэры няма. Можаце знішчыць яго",
    acterror = "Памылка актывацыі",
    itsonlyfordonater = "Гэта для донатеров (/donate)",
    thisitemisover = "Гэты прадмет скончыўся",
    noitemsinconf = "Наладзьце прадметы аўтадоната ў sh_additems.lua",

    -- end Ошибки

    --start Панель
    panelgaveitem = "Вам выдадзена новая паслуга:",
    panelmoveordisableitem = "Перазагрузка спісу пакупак з-за пераносу або адключэння паслуг",
    paneltableresetted = "Спіс перазагружаны",
    panelinvreset = "Перазагрузка інвентара",
    panelinvresetted = "інвентар перазагружаны",
    --end Панель

    --start BWHITELIST
    youinawhitelist = "Вы ў вайтлісце",
    --end

    --start ULX
    youalrhavethat = "У вас ужо дзейнічае гэтая паслуга",
    autorecovery = "Автовосстановление %s для %s",
    --end

    --start SERVERGUARD
    setssgrouperr = "IGS: у SetSGGroup паказаная неіснуючая група",
    --end

    --start DARKRP
    drpmoneydesc = "Імгненна і без праблем папаўняе баланс гульнявой валюты на %s валюты.",

}
