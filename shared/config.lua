lib.locale()
Config = {}

Config.EnableDebug = true
Config.PositioMenu = "top-right"

Config.TestDrive = true
Config.TestDriveTime = 30 --seconds
Config.MarkerDistance = 2.0
Config.RemoveMoneyCompany = true

Config.Shops = {
    cardealer = {
        -- Blip
        title = 'Dealership',
        color = 5,
        id = 227,
        scale = 0.8,
        coords = vector3(-52.2535, -1095.64, 26.422),
        -- Other
        requiredJob = false,
        jobName = 'cardealer',
        gradeBoss = 'Boss',
        bossMenu = vector3(-31.0925, -1106.57, 26.422),
        actionjob = vector3(-56.5321, -1099.30, 26.422),
        showcase = vector3(-55.3251, -1090.95, 26.422),
        spawnShowCase = vector4(-47.9474, -1096.73, 26.422, 42.292),
        spawnVehicleBuy = vector3(-35.9530, -1102.17, 26.422),
        camCoords = vector3(-52.0340, -1092.87, 26.422),
        TestDriveCoords = vector3(-889.877, -3205.54, 13.944)
    },
    police = {
        -- Blip
        title = 'Police Dealership',
        color = 38,
        id = 227,
        scale = 0.8,
        coords = vector3(418.4895, -1021.34, 29.030),
        -- Other
        requiredJob = true,
        jobName = 'police',
        gradeBoss = 'boss',
        bossMenu = vector3(-43.7882, -1116.28, 26.427),
        actionjob = vector3(417.5868, -1004.78, 29.233),
        showcase = vector3(421.2276, -1011.13, 29.129),
        spawnShowCase = vector4(423.9533, -1022.07, 28.929, 92.051),
        spawnVehicleBuy = vector3(-58.1253, -1116.52, 26.434),
        camCoords = vector3(414.4416, -1021.23, 29.199),
        TestDriveCoords = vector3(-889.877, -3205.54, 13.944)
    },
    boat = {
        -- Blip
        title = 'Boat Dealership',
        color = 2,
        id = 427,
        scale = 0.8,
        coords = vector3(-754.725, -1504.79, 5.0005),
        -- Other
        requiredJob = false,
        jobName = '',
        gradeBoss = '',
        bossMenu = vector3(0, 0, 0),
        actionjob = vector3(0, 0, 0),
        showcase = vector3(-755.026, -1507.16, 5.0069),
        spawnShowCase = vector4(-800.174, -1503.35, -0.474, 113.62),
        spawnVehicleBuy = vector3(-58.1253, -1116.52, 26.434),
        camCoords = vector3(-779.257, -1496.29, 1.7786),
        TestDriveCoords = vector3(-832.4774, -1532.5023, -0.4745)
    },
    plane = {
        -- Blip
        title = 'Plane Dealership',
        color = 30,
        id = 423,
        scale = 0.8,
        coords = vector3(-1013.82, -3022.10, 13.945),
        -- Other
        requiredJob = false,
        jobName = '',
        gradeBoss = '',
        bossMenu = vector3(0, 0, 0),
        actionjob = vector3(0, 0, 0),
        showcase = vector3(-1012.82, -3022.10, 13.945),
        spawnShowCase = vector4(-977.132, -2995.10, 13.944, 60.736),
        spawnVehicleBuy = vector3(-58.1253, -1116.52, 26.434),
        camCoords = vector3(-996.989, -2985.89, 13.945),
        TestDriveCoords = vector3(-889.877, -3205.54, 13.944)
    },
}

Config.Categories = {
    cardealer = {
        { label = 'Compacts',       name = 'compacts' },
        { label = 'Sendas',         name = 'sendas' },
        { label = 'SUVs',           name = 'suvs' },
        { label = 'Coupes',         name = 'coupes' },
        { label = 'Muscle',         name = 'muscle' },
        { label = 'Sports Classic', name = 'sportsclassic' },
        { label = 'Sports',         name = 'sports' },
        { label = 'Super',          name = 'super' },
        { label = 'Motorcycles',    name = 'motorcycles' },
        { label = 'Off-Road',       name = 'offroad' },
        { label = 'Vans',           name = 'vans' },
    },
    police = {
        { label = "Armored",    name = "armored" },
        { label = "Car",        name = "car" },
        { label = "Motorcycle", name = "motorcycle" },
    },
    boat = {
        { label = "Luxury",  name = "luxury" },
        { label = "Utility", name = "utility" },
    },
    plane = {
        { label = "Luxury",  name = "luxury" },
        { label = "Utility", name = "utility" },
    }
}

Config.Vehicles = {
    -- Vehice Name                Vehicle Model          Vehicle Category            Vehicle Price Dealership
    { name = "Asbo",              model = "asbo",        category = "compacts",      price = 1000, dealership = "cardealer" },
    { name = "Blista",            model = "blista",      category = "compacts",      price = 1000, dealership = "cardealer" },
    { name = "Brioso",            model = "brioso",      category = "compacts",      price = 1000, dealership = "cardealer" },
    { name = "Cog Cabrio",        model = "cogcabrio",   category = "coupes",        price = 1000, dealership = "cardealer" },
    { name = "Exemplar",          model = "exemplar",    category = "coupes",        price = 1000, dealership = "cardealer" },
    { name = "f620",              model = "f620",        category = "coupes",        price = 1000, dealership = "cardealer" },
    { name = "Akuma",             model = "akuma",       category = "motorcycles",   price = 1000, dealership = "cardealer" },
    { name = "Avarus",            model = "avarus",      category = "motorcycles",   price = 1000, dealership = "cardealer" },
    { name = "Bagger",            model = "bagger",      category = "motorcycles",   price = 1000, dealership = "cardealer" },
    { name = "Blade",             model = "blade",       category = "muscle",        price = 1000, dealership = "cardealer" },
    { name = "Buccaneer",         model = "buccaneer",   category = "muscle",        price = 1000, dealership = "cardealer" },
    { name = "Buccaneer2",        model = "buccaneer2",  category = "muscle",        price = 1000, dealership = "cardealer" },
    { name = "Bfinjection",       model = "bfinjection", category = "offroad",       price = 1000, dealership = "cardealer" },
    { name = "Bifta",             model = "bifta",       category = "offroad",       price = 1000, dealership = "cardealer" },
    { name = "Brawler",           model = "brawler",     category = "offroad",       price = 1000, dealership = "cardealer" },
    { name = "Baller",            model = "baller",      category = "suvs",          price = 1000, dealership = "cardealer" },
    { name = "Baller2",           model = "baller2",     category = "suvs",          price = 1000, dealership = "cardealer" },
    { name = "Baller3",           model = "baller3",     category = "suvs",          price = 1000, dealership = "cardealer" },
    { name = "Asea",              model = "asea",        category = "sendas",        price = 1000, dealership = "cardealer" },
    { name = "Asterope",          model = "asterope",    category = "sendas",        price = 1000, dealership = "cardealer" },
    { name = "Cog55",             model = "cog55",       category = "sendas",        price = 1000, dealership = "cardealer" },
    { name = "Alpha",             model = "alpha",       category = "sports",        price = 1000, dealership = "cardealer" },
    { name = "Banshee",           model = "banshee",     category = "sports",        price = 1000, dealership = "cardealer" },
    { name = "Bestia GTS",        model = "bestiagts",   category = "sports",        price = 1000, dealership = "cardealer" },
    { name = "Ardent",            model = "ardent",      category = "sportsclassic", price = 1000, dealership = "cardealer" },
    { name = "Btype",             model = "btype",       category = "sportsclassic", price = 1000, dealership = "cardealer" },
    { name = "Btype2",            model = "btype2",      category = "sportsclassic", price = 1000, dealership = "cardealer" },
    { name = "Adder",             model = "adder",       category = "super",         price = 1000, dealership = "cardealer" },
    { name = "Autarch",           model = "autarch",     category = "super",         price = 1000, dealership = "cardealer" },
    { name = "Banshee2",          model = "banshee2",    category = "super",         price = 1000, dealership = "cardealer" },
    { name = "Bison",             model = "bison",       category = "vans",          price = 1000, dealership = "cardealer" },
    { name = "Bison2",            model = "bison2",      category = "vans",          price = 1000, dealership = "cardealer" },
    { name = "Bobcat",            model = "bobcatxl",    category = "vans",          price = 1000, dealership = "cardealer" },

    -- Police Armored
    { name = "riot",              model = "Riot",        category = "armored",       price = 1000, dealership = "police" },
    { name = "riot2",             model = "Riot2",       category = "armored",       price = 1000, dealership = "police" },

    -- Police Car
    { name = "Police",            model = "police",      category = "car",           price = 1000, dealership = "police" },
    { name = "Police 2",          model = "police2",     category = "car",           price = 1000, dealership = "police" },
    { name = "Police 3",          model = "police3",     category = "car",           price = 1000, dealership = "police" },

    --Police Motorcycle
    { name = "Police Motorcycle", model = "policeb",     category = "motorcycle",    price = 1000, dealership = "police" },

    --Boat Luxury
    { name = "Marquis",           model = "marquis",     category = "luxury",        price = 1000, dealership = "boat" },
    { name = "Toro",              model = "toro",        category = "luxury",        price = 1000, dealership = "boat" },

    --Boat Utility
    { name = "Dinghy2",           model = "dinghy2",     category = "utility",       price = 1000, dealership = "boat" },
    { name = "Squalo",            model = "squalo",      category = "utility",       price = 1000, dealership = "boat" },

    --Plane Luxury
    { name = "Luxor",             model = "luxor",       category = "luxury",        price = 1000, dealership = "plane" },
    { name = "Luxor2",            model = "luxor2",      category = "luxury",        price = 1000, dealership = "plane" },

    --Plane Utility
    { name = "Mammatus",          model = "mammatus",    category = "utility",       price = 1000, dealership = "plane" },
    { name = "Cuban800",          model = "cuban800",    category = "utility",       price = 1000, dealership = "plane" },
}
