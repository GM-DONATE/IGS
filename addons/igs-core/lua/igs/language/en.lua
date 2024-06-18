IGS.LANG["en"] = {
    lang_name = "English", --очевидно
    autodonatecopyright = "Autodonate from gm-donate.net", -- не меняйте пж
    autodonate = "Autodonate",
    --start БАЗА

    balance = "Balance", -- сверху пишется баланс
    inventory = "Inventory",--}
    profile = "Profile",    -- } эта четверка это кнопки снизу
    purchases = "Purchases",  --}
    store = "Store", --      }

    --end БАЗА

    --start ПЛЮРАЛИЗАЦИЯ

    CurrencyPlurals = {
        "dollar",  -- 1 алкобакс
        "dollars", -- 3 алкобакса
        "dollars" -- 5 алкобаксов
    },

    PL_POYAVILSA = {
        "appeared", -- 1 предмет
        "appeared", -- 5 предметов
        "appeared"  -- 100 предметов
    },

    PL_NEW = {
        "new", -- 1 предмет
        "new", -- 5 предметов
        "new" -- 100 предметов
    },

    PL_ITEMS = {
        "item",  -- 1 предмет
        "items", -- 5 предметов
        "items" -- 100 предметов
    },

    PL_DAYS = {
        "day",
        "days",
        "days"
    },

    PL_VARIANTS = {"option", "options", "options"},

    --end ПЛЮРАЛИЗАЦИЯ

    --start Окно об новом предмете
    new_items = "In our /donate store %s %s %s %s. Would you like to take a look?",
    new_items_title = "Replenishment of the store", --nah
    --end

    --start ЧАТ
    yourpurchininv = "Your purchase is in /donate inventory",
    TopDon_TextRecord = "$nick broke the donation record this month by replenishing the account with $sum RUB.\nThe previous record was set by $nick_prev, replenishing the account with $sum_prev RUB",
    TopDon_TextFirstDon = "$nick was the first to deposit money this month. $nick is smart. Be like $nick - /donate", -- доступен шаблон $sum
    pldonated = "%s replenished the account with %s. His new Score: %s",
    pldonatedthanks = "Thank you for adding funds to your account. " .. "Your new Score on all projects is %d. " .. "What is Score: vk.cc/caHTZi",
    youcanspend = "You can spend %s via /donate",
    yourscore = "Your Score %s. More details: vk.cc/caHTZi",
    buyed = "buyed",

    --end ЧАТ

    --start ИНВЕНТАРЬ

    buy = "Purchase",
    activation = "Activation",
    drop = "Drop",
    pick = "Pick",

    yourinv = "Your inventory",
    yourinvisempty = "It's a little empty here...",

    activate = "Activate",
    droponfloor = "Throw it on the floor",

    invitemact = "Actions on the item",
    invchoose = "Select an item to get a list of actions for it",
    invchooselong = "The purchased items will be located here." ..
    "\n\nThanks to the inventory, you can share the purchase with your friend who does not have enough money to buy the service. " ..
        "Just buy it instead and throw it on the floor. After activating the item, it will appear in his inventory." ..
    "\n\nThe Good Samaritans use the inventory to organize cool contests. " ..
        "They stuff their inventory with items, and then, under certain conditions, they are distributed",

    invinfofpurc = "Information about your purchase will be displayed here when you make it",

    deactivated = "Purchase is disabled",
    alrdeactivated = "The service has already been disabled",
    actionswithinv = "Inventory operations",
    plinvlogtt = "Operation ID: %s. In front of the nickname is the global Score of the player",
    plinvlogcopysidowner = "Copy the owner's SID",
    plinvlogcopysidinfl = "Copy the artist's SID",
    plinvlogactions = "Player Actions",
    plinvlogactionswith = "Actions with", -- не забудьте пробел
    plinvactivation = "Activation",
    plinvdisable = "Disable",

    doninvlogactions = "Actions",
    doninvlogaction = "Action",
    doninvlogowner = "Owner",
    doninvloginfl = "Executor",
    doninvlogitem = "Item",
    doninvloggiftid = "Gift ID",
    doninvlogdate = "Date",

    doninvsearchtext = "SteamID or UID item",
    doninvfind = "Search",
    doninvallloaded = "Everything is loaded (%s)",
    doninvloadmore = "Show more (%s/%s)",

    --end ИНВЕНТАРЬ

    --start Разное
    latestpurch = "Recent purchases",
    other = "Other",
    resetfilter = "Filter reset",
    allfrom = "All by",
    from = "From",
    to = "to",
    loading = "Loading...",
    itemdeystv = "Act.",
    decsription = "Description",
    information = "Information",
    image = "Image",
    notification = "Notification",
    openpurchases = "Open the shopping list",
    buisnesslevel = "got a new (%s) business level -",
    npctext = "Donation services",
    --end

    --start Купоны
    entercouponcode = "Enter the coupon code",
    activatecoupon = "Activate the coupon",
    couponactivation = "Coupon activation",
    couponactivationexp = "If you have a donation coupon, then enter it below",
    couponactiovationerr = "Coupon activation error",
    couponactivationsuccess = "The money has been credited to your account. You can look at this in transactions by reopening the donation menu",
    couponactivationsuccesstitle = "Successful activation of the coupon",
    --end Купоны

    --start Предмет
    buyedwho = "Buyed:",
    purchased = "Purchased",
    forwhat = "Until: ",
    whatserver = "On: ",
    endless = "infinitely",
    forever = "forever",
    disposable = "disposable",
    category = "Category",
    validto = "Valid",
    price = "Price",
    nodiscount = "No discount",
    doesitstack = "Purchases are stack up",
    buyfor = "Buy for",
    notenoughmoney = "Not enough money",
    notenoughmoneyexp = "You don't have enough %s to buy %s.\nWould you like to top up your account instantly?",

    yesitdoes = "yes",
    noitdoesnt = "no",

    --end

    --start Профиль
    profileinfo = "Profile Information",
    profilestatus = "Status",
    profilenobody = "Nobody :(",
    profilenextstatus = "Next status",
    profileneedenforstat = "Need",
    profiletransactions = "Transactions",
    profileserver = "Server",
    profileammount = "Amount",
    profilebalance = "Balance",
    profileaction = "Actions",
    profiledate = "Date",
    profilelasttransactions = "Recent %s transactions",

    profileaddmoney = "Add funds to your account",
    profilecoupon = "Coupon",
    profiletransid = "Transaction ID in the system:",
    profileoriglabel = "The original label:",
    profilenumoftrans = "Operations",
    profiletransic = "1 Operation",
    profilenumoftranspcs = "pcs.", -- сколько было транзакций
    profilenotrans = "Did not have",

    --end

    --start Окно пополнения
    depositsum = "Enter the deposit amount below",
    depositbtn = "Top up your account with %s RUB",
    depostisumerr = "Incorrect deposit amount is specified",
    depostiminimal = "Minimum deposit amount",
    depositsafekey = "Request a digital signature of the request from the server...",
    deposittitle = "The procedure for adding funds to the account",
    depositgotkey = "The signature has been received. starting the payment process",
    depositfundsauto = "The account will be replenished immediately or after a re-enter",
    depositlog = "Operation log",
    depositopened = "The deposit dialog is open",
    depositconnected = "The connection is established!",
    depositfastestfund = "The money will be credited instantly and automatically",
    deposticheckfrom = "Checking the possibility of payment via",
    depostiadded = "Accrued",
    depositerror = "Replenishment error:",
    depositerror1 = "An unknown method came from the server",
    depositerror2 = "and an error occurred",
    depositupdate = "Updating the payment status",


    --end

    --start Покупки
    limitedbuy = "You bought %s%s times from %s",
    limitederr = "This item can only be bought %s times",
    itemgivenon = "The item was issued on %s servers",
    yourecieved = "You received",
    yourecieveditems = "%s items added to your inventory",
    activepurchases = "Active purchases",
    purchasebuyed = "Purchased",
    purchaseexpire = "It will expire",
    purchaseswhatshere = "What's here?",
    purchasesexplain = "Your active purchases will be displayed here\n\n" .. "Isn't it the right time to make the first one?\n\n" .. "The plaque will immediately become more beautiful. Honestly, honestly",
    purchasealrhaveexpl = "Your active services are displayed on the left.\n\n" .. "The more services, the more beautiful this sign looks, and the administration is happier ;)",

    purchasebuybtn = "Buy a bun",
    purchasenever = "Never",
    purchasedesc = "Server name: %s\nID in the system: %s\nOriginal name: ", -- тут пробел в конце
    purchasedone = "Successful purchase",
    purchasethanks = "Thanks for the purchase. It was easy, wasn't it? :)",
    purchasethxandact = "Thanks for the purchase. It is in your /donate inventory.\n\nShould I activate it now?",

    --end

    --start Оружие
    weapgiveonspawn = "Give out when spawning",
    weapwillgivenonspawn = "will be issued when spawning",
    weapnot = "not", 
    weapwillgivenonresawn = "%s now it will be given at each respawn. " .. "If you want to temporarily disable the giving, " .. " then uncheck the item card in the /donate menu",
    --end

    --start Vehicle
    vehalrspawned = "You have this car spawned",
    --end

    --start Активация
    statusdisabled = "Disab.",
    statusglobal = "Glob.",
    itemactivatedthx = "The item is activated. Thank you!",
    itemactivated = "Successful activation",
    --end

    --start Энтити
    invoverloaded = "You have too many items in your inventory",
    itemmoving = "An item in the process of being moved to inventory",
    iferror = "If the process is endless, then make the evidence as soon as possible and inform the administrator",
    itemmoved = "The item is placed in /donate inventory",
    validuntil = "Valid",
    --end

    --start Ошибки

    error = "Error",
    isunpacked = "It looks like the autodonate is unpacked in /addons. Automatic updates are not available",
    isworkshop = "Remove the autodonat from your collection in the workshop. Updates work via GitHub",
    autodonatedisabled = "Autodonate is temporarily disabled",
    transactiononotherserver = "Transaction on another server",
    dropdisabled = "Item drop is disabled by the administrator",
    autodonateisnotworking = "Autodonate is temporarily out of service",
    autodonateisnotloaded = "[IGS] Autodonate is not loaded",
    autodonateinstalledwrong = "[IGS] Autodonate installed incorrectly. Inform the administration",
    howdidyoufindme = "How did you find me?",
    youbroke = "To purchase, you need",
    invisfull = "You have an overload in your donation inventory. And you're also one of the few people who saw it!",
    purchinprogress = "The purchase request is in progress. Please wait.",
    purcherror = "Purchase error %s: %s",
    purchaseerror = "Purchase error",
    invisdisabled = "Inventory is disabled. The activation of items is instant",
    itemisalractivated = "The item has already been activated. ID:",
    itemnotfound = "The item was not found. It may already be activated",
    noitem = "This item most likely once existed or exists on another server, but not here",
    noitemfound = "This item is not on the server. How did you find it?",
    noitembro = "This item is not on the server. You can destroy it",
    acterror = "Activation error",
    itsonlyfordonater = "This is for donators (/donate)",
    thisitemisover = "This item is out of stock",
    noitemsinconf = "Set up the items of the autodonate in sh_additems.lua",

    -- end Ошибки

    --start Панель
    panelgaveitem = "You have been given a new item:",
    panelmoveordisableitem = "Reloading the purchase list due to the transfer or disconnection of items",
    paneltableresetted = "List has been reloaded",
    panelinvreset = "Reloading the inventory",
    panelinvresetted = "Inventory has been reloaded",

    --end Панель

    --start BWHITELIST
    youinawhitelist = "You on the whitelist",
    --end

    --start ULX
    youalrhavethat = "You already have this item",
    autorecovery = "Auto-recovery %s for %s",
    --end

    --start SERVERGUARD
    setssgrouperr = "IGS: A non-existent group is specified in SetSGGroup",
    --end

    --start DARKRP
    drpmoneydesc = "Instantly and without problems replenishes the balance of the game currency by %s of the currency.",

}
