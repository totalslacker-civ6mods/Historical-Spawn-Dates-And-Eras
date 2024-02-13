-- ===========================================================================
--	Historical Victory Data
-- ===========================================================================
print("Loading HistoricalVictory_Data.lua")

-- Insert Civilizations or Leaders into this table for custom historical victories
-- Leader data is used if present, otherwise civilization data will be used
-- Civs or Leaders not in this table will use the generic conditions
-- This table tracks the index and objective count for each challenge, to be used to generate text and check properties

HSD_victoryConditionsConfig = {

    -- LEADERS
    LEADER_CLEOPATRA_ALT = {
        {
			id = "PTOLEMAIC_DYNASTY",
			index = "1",
            year = nil,
			era = nil,
            objectives = {
                {type = "2_WONDERS_IN_CITY", firstID = "BUILDING_GREAT_LIGHTHOUSE", secondID = "BUILDING_GREAT_LIBRARY"},
            },
            score = 1
        },
        {
            id = "ALEXANDRIAN_KINGDOM",
			index = "2",
            year = nil,
			era = nil,
            objectives = {
                {type = "TERRITORY_CONTROL", territory = "SEA", minimumSize = 6},
                {type = "TERRITORY_CONTROL", territory = "DESERT", minimumSize = 6},
            },
            score = 1
        },
        {
            id = "NILE_DELTA",
			index = "3",
			year = -30,
			era = nil,
            objectives = {
                {type = "NUM_CITIES_POP_SIZE", cityNum = 3, popNum = 10},
                {type = "HIGHEST_CULTURE"},
            },
            score = 1
        },
		-- end of victory conditions
    },

    LEADER_GORGO = {
        {
			id = "SPARTAN_VALOR",
			index = "1",
            year = nil,
			era = nil,
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_GREEK_HOPLITE", count = 10},
                {type = "FULLY_UPGRADE_UNIT_COUNT", id = "UNIT_GREEK_HOPLITE", count = 1},
                {type = "UNIT_CONQUER_CITY_COUNT", id = "UNIT_GREEK_HOPLITE", count = 5},
            },
            score = 1
        },
        {
            id = "DORIC_COLUMNS",
			index = "2",
            year = nil,
			era = "ERA_CLASSICAL",
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_STATUE_OF_ZEUS"},
                {type = "UNLOCK_ALL_ERA_CIVICS", id = "ERA_CLASSICAL"},
            },
            score = 1
        },
        {
            id = "PELOPONNESIAN_LEAGUE",
			index = "3",
			year = nil,
			era = "ERA_CLASSICAL",
            objectives = {
                {type = "SUZERAINTY_COUNT", count = 2},
                {type = "OCCUPIED_CAPITAL_COUNT", count = 2},
            },
            score = 1
        },
		-- end of victory conditions
    },

    LEADER_HARALD_ALT = {
        {
			id = "GREAT_HEATHEN_ARMY",
			index = "1",
            year = nil,
			era = nil,
            objectives = {
                {type = "UNIT_CONQUER_CITY_COUNT", id = "UNIT_NORWEGIAN_BERSERKER", count = 5},
                {type = "UNIT_PILLAGE_COUNT", id = "UNIT_NORWEGIAN_BERSERKER", count = 10},
                {type = "FULLY_UPGRADE_UNIT_COUNT", id = "UNIT_NORWEGIAN_BERSERKER", count = 1},
            },
            score = 1
        },
        {
            id = "COUNCIL_OF_THE_ALTHING",
			index = "2",
            year = nil,
			era = "ERA_MEDIEVAL",
            objectives = {
                {type = "SUZERAINTY_COUNT", count = 4},
            },
            score = 1
        },
        {
            id = "VALHALLA",
			index = "3",
			year = nil,
			era = "ERA_MEDIEVAL",
            objectives = {
                {type = "BUILDING_COUNT", id = "BUILDING_STAVE_CHURCH", count = 5},
                {type = "HOLY_CITY_COUNT", count = 3},
            },
            score = 1
        },
		-- end of victory conditions
    },

	LEADER_JULIUS_CAESAR = {
        {
			id = "GALLIC_WARS",
			index = "1",
            year = -50,
			era = nil,
            objectives = {
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_ROMAN_FORT", count = 5},
                {type = "UNIT_CONQUER_CITY_COUNT", id = "UNIT_ROMAN_LEGION", count = 5},
            },
            score = 1
        },
        {
            id = "BREAD_AND_CIRCUSES",
			index = "2",
            year = nil,
			era = nil,
            objectives = {
                {type = "WONDER_BUILT_CITIES_IN_RANGE", id = "BUILDING_COLOSSEUM", count = 6, range = 6},
                {type = "PROJECT_COUNT", id = "PROJECT_BREAD_AND_CIRCUSES", count = 10},
                {type = "FIRST_GOVERNMENT", id = "GOVERNMENT_FASCISM"},
            },
            score = 1
        },
        {
            id = "RICHER_THAN_CRASSUS",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "GOLD_COUNT", count = 10000},
            },
            score = 1
        },
		-- end of victory conditions
    },

    LEADER_KUBLAI_KHAN_CHINA = {
        {
            id = "YUAN_DYNASTY",
            index = "1",
            year = 1368,
            era = nil,
            objectives = {
                {type = "OCCUPIED_CAPITAL_COUNT", count = 3},
                {type = "LAND_AREA_HOME_CONTINENT", percent = 20},
            },
            score = 1
        },
        {
            id = "SILK_ROAD",
            index = "2",
            year = nil,
            era = "ERA_RENAISSANCE",
            objectives = {
                {type = "MOST_TRADING_POSTS_ALL"}, -- TODO
                {type = "MOST_ACTIVE_TRADE_ROUTES"},
                {type = "HIGHEST_GOLD_PER_TURN"},
            },
            score = 1
        },
        {
            id = "MIDDLE_KINGDOM",
            index = "3",
            year = nil,
            era = nil,
            objectives = {
                {type = "TERRITORY_CONTROL", territory = "DESERT", minimumSize = 6},
                {type = "TERRITORY_CONTROL", territory = "SEA", minimumSize = 6},
                {type = "TERRITORY_CONTROL", territory = "MOUNTAIN", minimumSize = 6},
            },
            score = 1
        },
        -- end of victory conditions
    },

    LEADER_QIN = {
        {
            id = "QIN_DYNASTY",
            index = "1",
            year = nil,
            era = "ERA_CLASSICAL",
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_TERRACOTTA_ARMY"},
                {type = "FIRST_CIVIC_RESEARCHED", id = "CIVIC_CIVIL_SERVICE"},
                {type = "GREAT_PERSON_ERA_COUNT", id = "ERA_CLASSICAL", count = 3},
            },
            score = 1
        },
        {
            id = "GRAND_CANAL",
            index = "2",
            year = nil,
            era = "ERA_MEDIEVAL",
            objectives = {
                {type = "DISTRICT_COUNT", id = "DISTRICT_CANAL", count = 5},
                {type = "GOLD_COUNT", count = 3000},
                {type = "HIGHEST_TECH_COUNT"},
            },
            score = 1
        },
        {
            id = "GREAT_WALL_OF_CHINA",
            index = "3",
            year = nil,
            era = nil,
            objectives = {
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_GREAT_WALL", count = 20},
                {type = "UNIT_KILL_COUNT", id = "UNIT_CHINESE_CROUCHING_TIGER", count = 10},
                {type = "GOLDEN_AGE_COUNT", count = 3},
            },
            score = 1
        },
        -- end of victory conditions
    },

    LEADER_RAMSES = {
        {
			id = "MONUMENTS_OF_THE_PHARAOHS",
			index = "1",
            year = -1700,
			era = nil,
            objectives = {
				{type = "WONDER_ADJACENT_IMPROVEMENT", id = "BUILDING_PYRAMIDS", improvement = "IMPROVEMENT_SPHINX"},
            },
            score = 1
        },
        {
            id = "THE_NEW_KINGDOM",
			index = "2",
            year = -1050,
			era = nil,
            objectives = {
                {type = "CITY_COUNT", count = 4},
                {type = "UNIT_KILL_COUNT", id = "UNIT_EGYPTIAN_CHARIOT_ARCHER", count = 5},
            },
            score = 1
        },
        {
            id = "KARNAK",
			index = "3",
            year = nil,
			era = "ERA_CLASSICAL",
            eraLimit = "END_ERA",
            objectives = {
                {type = "FIRST_GREAT_PERSON_CLASS", id = "GREAT_PERSON_CLASS_PROPHET"},
                {type = "FIRST_BUILDING_CONSTRUCTED", id = "BUILDING_TEMPLE"},
                {type = "HIGHEST_CULTURE"},
            },
            score = 1
        },
		-- end of victory conditions
    },

    LEADER_SALADIN_ALT = {
        {
			id = "DAMASCUS_STEEL",
			index = "1",
            year = nil,
			era = nil,
            objectives = {
				{type = "UNIT_CONQUER_CITY_COUNT", id = "UNIT_ARABIAN_MAMLUK", count = 10},
            },
            score = 1
        },
        {
            id = "HOLY_WAR",
			index = "2",
            year = nil,
			era = "ERA_MEDIEVAL",
            objectives = {
                {type = "HOLY_CITY_COUNT", count = 3},
            },
            score = 1
        },
        {
            id = "DESERT_EMPIRE",
			index = "3",
            year = nil,
			era = nil,
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_PETRA"},
                {type = "TERRITORY_CONTROL", territory = "DESERT", minimumSize = 12},
            },
            score = 1
        },
		-- end of victory conditions
    },

    LEADER_T_ROOSEVELT_ROUGHRIDER = {
        {
            id = "MANIFEST_DESTINY",
            index = "1",
            year = 1900,
            era = nil,
            objectives = {
                {type = "NATURAL_WONDER_COUNT", count = 4},
                {type = "UNIT_KILL_COUNT", id = "UNIT_AMERICAN_ROUGH_RIDER", count = 10},
                {type = "LAND_AREA_HOME_CONTINENT", percent = 40},
            },
            score = 1
        },
        {
            id = "AMERICANA",
            index = "2",
            year = nil,
            era = nil,
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_BROADWAY"},
                {type = "WONDER_BUILT", id = "BUILDING_STATUE_LIBERTY"},
                {type = "WONDER_BUILT", id = "BUILDING_GOLDEN_GATE_BRIDGE"},
            },
            score = 1
        },
        {
            id = "FOREIGN_ENTANGLEMENTS",
            index = "3",
            year = nil,
            era = nil,
            objectives = {
                {type = "ALLIANCE_COUNT", count = 5},
                {type = "MAXIMUM_ALLIANCE_LEVEL_COUNT", count = 4},
                {type = "RESOURCE_MONOPOLY", id = "RESOURCE_OIL", percent = 40},
            },
            score = 1
        },
        -- end of victory conditions
    },

    LEADER_WU_ZETIAN = {
        {
            id = "TANG_DYNASTY",
            index = "1",
            year = nil,
            era = "ERA_MEDIEVAL",
            objectives = {
                {type = "HIGHEST_CITY_POPULATION"},
                {type = "HIGHEST_CULTURE"},
                {type = "RESOURCE_MONOPOLY", id = "RESOURCE_SILK", percent = 60},
            },
            score = 1
        },
        {
            id = "IMPERIAL_EXAMS",
            index = "2",
            year = nil,
            era = nil,
            objectives = {
                {type = "FIRST_TECH_RESEARCHED", id = "TECH_MACHINERY"},
                {type = "FIRST_TECH_RESEARCHED", id = "TECH_GUNPOWDER"},
                {type = "FIRST_TECH_RESEARCHED", id = "TECH_PRINTING_PRESS"},
            },
            score = 1
        },
        {
            id = "PALACE_INTRIGUE",
            index = "3",
            year = nil,
            era = nil,
            objectives = {
                {type = "FULLY_UPGRADE_UNIT_COUNT", id = "UNIT_SPY", count = 1},
                {type = "COMPLETE_ALL_ESPIONAGE_MISSIONS"}, -- TODO
            },
            score = 1
        },
        -- end of victory conditions
    },

    LEADER_YONGLE = {
        {
            id = "MING_DYNASTY",
            index = "1",
            year = nil,
            era = "ERA_RENAISSANCE",
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_FORBIDDEN_CITY"},
                {type = "SUZERAINTY_COUNT", count = 4},
                {type = "NUM_CITIES_POP_SIZE", cityNum = 10, popNum = 10},
            },
            score = 1
        },
        {
            id = "TREASURE_FLEETS",
            index = "2",
            year = nil,
            era = "ERA_RENAISSANCE",
            objectives = {
                {type = "TERRITORY_CONTROL", territory = "SEA", minimumSize = 8},
                {type = "FIRST_TECH_RESEARCHED", id = "TECH_CARTOGRAPHY"},
                {type = "MOST_OUTGOING_TRADE_ROUTES"},
            },
            score = 1
        },
        {
            id = "MYRIADS",
            index = "3",
            year = nil,
            era = nil,
            objectives = {
                {type = "PROJECT_COUNT", id = "PROJECT_LIJIA_FAITH", count = 10},
                {type = "PROJECT_COUNT", id = "PROJECT_LIJIA_FOOD", count = 10},
                {type = "PROJECT_COUNT", id = "PROJECT_LIJIA_GOLD", count = 10},
            },
            score = 1
        },
        -- end of victory conditions
    },

    -- CIVILIZATIONS

    CIVILIZATION_AMERICA = {
        {
            id = "MANIFEST_DESTINY",
            index = "1",
            year = 1900,
            era = nil,
            objectives = {
                {type = "NATURAL_WONDER_COUNT", count = 4},
                {type = "NATIONAL_PARK_COUNT", count = 4}, --TODO
                {type = "LAND_AREA_HOME_CONTINENT", percent = 40},
            },
            score = 1
        },
        {
            id = "AMERICANA",
            index = "2",
            year = nil,
            era = nil,
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_BROADWAY"},
                {type = "WONDER_BUILT", id = "BUILDING_STATUE_LIBERTY"},
                {type = "WONDER_BUILT", id = "BUILDING_GOLDEN_GATE_BRIDGE"},
            },
            score = 1
        },
        {
            id = "SPACE_RACE",
            index = "3",
            year = nil,
            era = nil,
            objectives = {
                {type = "PROJECT_FIRST_COMPLETED", id = "PROJECT_MANHATTAN_PROJECT", count = 1},
                {type = "PROJECT_FIRST_COMPLETED", id = "PROJECT_LAUNCH_MOON_LANDING", count = 1},
                {type = "HIGHEST_TOURISM"},
            },
            score = 1
        },
        -- end of victory conditions
    },

    CIVILIZATION_ARABIA = {
        {
			id = "TRADE_CARAVANS",
			index = "1",
            year = nil,
			era = "ERA_MEDIEVAL",
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_PETRA"},
                {type = "MOST_ACTIVE_TRADE_ROUTES"},
            },
            score = 1
        },
        {
            id = "HOUSE_OF_WISDOM",
			index = "2",
            year = nil,
            era = "ERA_MEDIEVAL",
            objectives = {
                {type = "BUILDING_COUNT", id = "BUILDING_MADRASA", count = 4},
                {type = "GREAT_PERSON_ERA_COUNT", id = "ERA_MEDIEVAL", count = 4},
            },
            score = 1
        },
        {
            id = "CALIPHATE",
			index = "3",
			year = nil,
			era = "ERA_RENAISSANCE",
            objectives = {
                {type = "MOST_CITIES_FOLLOWING_RELIGION"},
                {type = "HIGHEST_FAITH_PER_TURN"},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_AUSTRALIA = {
        {
            id = "GREAT_SOUTHERN_LAND",
            index = "1",
            year = nil,
            era = "ERA_MODERN",
            objectives = {
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_OUTBACK_STATION", count = 10},
                {type = "COASTAL_CITY_COUNT", count = 5},
            },
            score = 1
        },
        {
            id = "ANZAC",
            index = "2",
            year = nil,
            era = nil,
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_DIGGER", count = 10},
            },
            score = 1
        },
        {
            id = "SURFERS_PARADISE",
            index = "3",
            year = nil,
            era = nil,
            objectives = {
                {type = "BUILD_WONDER", id = "BUILDING_SYDNEY_OPERA_HOUSE"},
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_BEACH_RESORT", count = 10},
                {type = "HIGHEST_TOURISM"},
            },
            score = 1
        },
        -- end of victory conditions
    },

    CIVILIZATION_AZTEC = {
        {
			id = "CHINAMPAS",
			index = "1",
            year = nil,
			era = "ERA_MEDIEVAL",
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_HUEY_TEOCALLI"},
                {type = "HIGHEST_CITY_POPULATION"},
            },
            score = 1
        },
        {
            id = "FLOWER_WARS",
			index = "2",
            year = nil,
            era = nil,
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_AZTEC_EAGLE_WARRIOR", count = 20},
            },
            score = 1
        },
        {
            id = "AZATLAN",
			index = "3",
			year = nil,
			era = "ERA_INDUSTRIAL",
            eraLimt = "END_ERA",
            objectives = {
                {type = "MOST_CITIES_ON_HOME_CONTINENT"},
                {type = "BUILDING_COUNT", id = "BUILDING_TLACHTLI", count = 4},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_BABYLON_STK = {
        {
			id = "LAND_OF_TWO_RIVERS",
			index = "1",
            year = nil,
			era = nil,
            objectives = {
                {type = "CONTROL_ALL_ADJACENT_RIVER_TO_CAPITAL"},
                {type = "WONDER_BUILT", id = "BUILDING_HANGING_GARDENS"},
            },
            score = 1
        },
        {
            id = "WALLS_OF_BABYLON",
			index = "2",
            year = nil,
            era = "ERA_CLASSICAL",
            eraLimit = "END_ERA",
            objectives = {
                {type = "BUILDING_IN_CAPITAL", id = "BUILDING_CASTLE"},
                {type = "UNIT_KILL_COUNT", id = "UNIT_BABYLONIAN_SABUM_KIBITTUM", count = 10},
            },
            score = 1
        },
        {
            id = "CENTER_OF_THE_WORLD",
			index = "3",
			year = nil,
			era = "ERA_CLASSICAL",
            eraLimit = "END_ERA",
            objectives = {
                {type = "HIGHEST_CITY_POPULATION"},
                {type = "HIGHEST_CULTURE"},
                {type = "FIRST_TECH_RESEARCHED", id = "TECH_ASTRONOMY"},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_BYZANTIUM = {
        {
            id = "HOLY_WISDOM",
            index = "1",
            year = 700,
            era = nil,
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_HAGIA_SOPHIA"},
            },
            score = 1
        },
        {
            id = "DEFENDER_OF_ORTHODOXY",
            index = "2",
            year = 1200,
            era = nil,
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_BYZANTINE_TAGMA", count = 10},
                {type = "UNIT_CONQUER_CITY_COUNT", id = "UNIT_BYZANTINE_TAGMA", count = 4},
                {type = "CONVERT_ALL_CITIES"},
            },
            score = 1
        },
        {
            id = "RENOVATIO_IMPERII",
            index = "3",
            year = 1500,
            era = nil,
            objectives = {
                {type = "OCCUPIED_CAPITAL_COUNT", count = 3},
                {type = "HOLY_CITY_COUNT", count = 3},
                {type = "FOREIGN_CONTINENT_CITIES", count = 5},
            },
            score = 1
        },
        -- end of victory conditions
    },

    CIVILIZATION_CHINA = {
        {
            id = "DYNASTIC_CYCLE",
            index = "1",
            year = nil,
            era = nil,
            objectives = {
                {type = "DIFFERENT_GOVERNMENTS_ADOPTED", count = 10}, -- TODO
                {type = "WONDER_BUILT", id = "BUILDING_FORBIDDEN_CITY"},
                {type = "FIRST_CIVIC_RESEARCHED", id = "CIVIC_CIVIL_SERVICE"},
            },
            score = 1
        },
        {
            id = "ART_OF_WAR",
            index = "2",
            year = nil,
            era = nil,
            objectives = {
                {type = "FIRST_GREAT_PERSON_CLASS", id = "GREAT_PERSON_CLASS_GENERAL"},
                {type = "WONDER_BUILT", id = "BUILDING_TERRACOTTA_ARMY"},
                {type = "UNIT_KILL_COUNT", id = "UNIT_CHINESE_CROUCHING_TIGER", count = 10},
            },
            score = 1
        },
        {
            id = "GREAT_WALL_OF_CHINA",
            index = "3",
            year = nil,
            era = nil,
            objectives = {
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_GREAT_WALL", count = 20},
                {type = "NUM_CITIES_CAPITAL_RANGE", count = 6, range = 6},
                {type = "HIGHEST_TOURISM"}, -- TODO
            },
            score = 1
        },
        -- end of victory conditions
    },

    CIVILIZATION_EGYPT = {
        {
			id = "MONUMENTS_OF_THE_PHARAOHS",
			index = "1",
            year = nil,
			era = "ERA_ANCIENT",
            objectives = {
				{type = "WONDER_ADJACENT_IMPROVEMENT", id = "BUILDING_PYRAMIDS", improvement = "IMPROVEMENT_SPHINX"},
            },
            score = 1
        },
        {
            id = "NILE_KINGDOM",
			index = "2",
            year = nil,
			era = nil,
            objectives = {
                {type = "CONTROL_ALL_ADJACENT_RIVER_TO_CAPITAL"},
                {type = "FIRST_NUM_ACTIVE_ALLIANCES", count = 5},
                {type = "MAXIMUM_ALLIANCE_LEVEL_COUNT", count = 1},
            },
            score = 1
        },
        {
            id = "BREADBASKET_OF_ANCIENT_WORLD",
			index = "3",
			year = -30,
            yearLimit = "ON_YEAR",
			era = nil,
            objectives = {
                {type = "MOST_ACTIVE_TRADE_ROUTES"},
                {type = "HIGHEST_CITY_POPULATION"},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_ENGLAND = {
        {
			id = "VICTORIAN_ERA",
			index = "1",
            year = nil,
			era = "ERA_INDUSTRIAL",
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_OXFORD_UNIVERSITY"},
				{type = "GREAT_PEOPLE_ACTIVATED", count = 5},
                {type = "HIGHEST_CULTURE"},
            },
            score = 1
        },
        {
            id = "INDUSTRIAL_REVOLUTION",
			index = "2",
            year = 1860,
            era = nil,
            objectives = {
                {type = "FIRST_TECH_RESEARCHED", id = "TECH_INDUSTRIALIZATION"},
                {type = "WONDER_BUILT", id = "BUILDING_BIG_BEN"},
                {type = "BUILDING_COUNT", id = "BUILDING_FACTORY", count = 3},
            },
            score = 1
        },
        {
            id = "SUN_NEVER_SETS",
			index = "3",
			year = 1920,
			era = nil,
            objectives = {
                {type = "NUM_CITIES_EVERY_CONTINENT", count = 1}, -- TODO
                {type = "UNIT_KILL_COUNT", id = "UNIT_ENGLISH_REDCOAT", count = 10},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_FRANCE = {
        {
			id = "AGE_OF_CHIVALRY",
			index = "1",
            year = 1450,
			era = nil,
            objectives = {
                {type = "CITY_WITH_IMPROVEMENT_COUNT", id = "IMPROVEMENT_CHATEAU", count = 4},
                {type = "UNIT_COUNT", id = "UNIT_KNIGHT", count = 5},
                {type = "WONDER_BUILT", id = "BUILDING_MONT_ST_MICHEL"},
            },
            score = 1
        },
        {
            id = "NAPOLEONIC_WARS",
			index = "2",
            year = 1815,
            era = nil,
            objectives = {
                {type = "UNIT_CONQUER_CITY_COUNT", id = "UNIT_FRENCH_GARDE_IMPERIALE", count = 5},
                {type = "GREAT_PERSON_TYPE_FROM_ERA", id = "GREAT_PERSON_CLASS_GENERAL", era = "ERA_INDUSTRIAL", count = 1}, -- TODO
            },
            score = 1
        },
        {
            id = "BELLE_EPOQUE",
			index = "3",
			year = 1900,
            yearLimit = "ON_YEAR",
			era = nil,
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_EIFFEL_TOWER"},
                {type = "HIGHEST_CULTURE"},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_GAUL = {
        {
			id = "DRUIDIC_LORE",
			index = "1",
            year = -250,
			era = nil,
            objectives = {
                {type = "BUILDING_COUNT", id = "BUILDING_ORACLE", count = 1},
				{type = "BUILDING_COUNT", id = "BUILDING_STONEHENGE", count = 1},
                {type = "FEATURE_COUNT", id = "FEATURE_FOREST", count = 5},
            },
            score = 1
        },
        {
            id = "CELTIC_MIGRATIONS",
			index = "2",
            year = -50,
            yearLimit = "ON_YEAR",
            era = nil,
            objectives = {
                {type = "BORDERING_CITY_COUNT", count = 5},
                {type = "GOLD_COUNT", count = 1000},
            },
            score = 1
        },
        {
            id = "PAINTED_WARRIORS",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_GAUL_GAESATAE", count = 20},
                {type = "UNIT_PILLAGE_COUNT", id = "UNIT_GAUL_GAESATAE", count = 10},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_GEORGIA = {
        {
			id = "BAGRATIONI_DYNASTY",
			index = "1",
            year = nil,
			era = nil,
            objectives = {
                {type = "MAXIMUM_ALLIANCE_LEVEL_COUNT", count = 3},
                {type = "SUZERAINTY_COUNT", count = 4},
                {type = "GOLDEN_AGE_COUNT", count = 3}, -- TODO
            },
            score = 1
        },
        {
            id = "DEFENDER_OF_THE_FAITH",
			index = "2",
            year = nil,
            era = "ERA_MEDIEVAL",
            objectives = {
                {type = "CONVERT_ALL_CITIES"},
                {type = "HIGHEST_FAITH_PER_TURN"},
                {type = "UNIT_KILL_COUNT", id = "UNIT_GEORGIAN_KHEVSURETI", count = 10},
            },
            score = 1
        },
        {
            id = "CAUCASIAN_IBERIA",
			index = "3",
			year = nil,
			era = "ERA_MEDIEVAL",
            objectives = {
                {type = "TERRITORY_CONTROL", territory = "MOUNTAIN", minimumSize = 4},
                {type = "BUILDING_IN_CAPITAL", id = "BUILDING_TSIKHE"},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_GERMANY = {
        {
			id = "HOLY_ROMAN_EMPIRE",
			index = "1",
            year = nil,
			era = "ERA_RENAISSANCE",
            objectives = {
                {type = "CONVERT_ALL_CITIES"},
				{type = "OCCUPIED_CAPITAL_COUNT", count = 3},
            },
            score = 1
        },
        {
            id = "HANSEATIC_LEAGUE",
			index = "2",
            year = nil,
            era = nil,
            objectives = {
                {type = "DISTRICT_COUNT", id = "DISTRICT_HANSA", count = 5},
                {type = "GREAT_PEOPLE_ACTIVATED", count = 4},
                {type = "FULLY_UPGRADE_UNIT_CLASS_COUNT", id = "PROMOTION_CLASS_NAVAL_RAIDER", count = 2},
            },
            score = 1
        },
        {
            id = "MITTELEUROPA",
			index = "3",
			year = nil,
			era = "ERA_MODERN",
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_RUHR_VALLEY"},
                {type = "HIGHEST_PRODUCTION"},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_GREECE = {
        {
			id = "CLASSICAL_AGE",
			index = "1",
            year = nil,
			era = "ERA_CLASSICAL",
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_ORACLE"},
				{type = "WONDER_BUILT", id = "BUILDING_COLOSSUS"},
            },
            score = 1
        },
        {
            id = "CRADLE_OF_THE_WEST",
			index = "2",
            year = nil,
            era = "ERA_CLASSICAL",
            eraLimit = "END_ERA",
            objectives = {
                {type = "GREAT_PEOPLE_ACTIVATED", count = 4},
                {type = "HIGHEST_CULTURE"},
            },
            score = 1
        },
        {
            id = "PHILHELLENES",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "FIRST_NUM_ACTIVE_ALLIANCES", count = 5},
                {type = "SUZERAINTY_COUNT", count = 5},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_MALI = {
        {
            id = "GOLDEN_AGE_OF_MALI",
            index = "1",
            year = nil,
            era = "ERA_MEDIEVAL",
            objectives = {
                {type = "GOLD_COUNT", count = 5000},
                {type = "HIGHEST_FAITH_PER_TURN"},
                {type = "WONDER_BUILT", id = "BUILDING_UNIVERSITY_SANKORE"},
            },
            score = 1
        },
        {
            id = "TRANS_SAHARAN_TRADE",
            index = "2",
            year = nil,
            era = "ERA_MEDIEVAL",
            objectives = {
                {type = "MOST_OUTGOING_TRADE_ROUTES"},
                {type = "DISTRICT_COUNT", id = "DISTRICT_SUGUBA", count = 4},
            },
            score = 1
        },
        {
            id = "SAHEL_EMPIRE",
            index = "3",
            year = nil,
            era = nil,
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_MALI_MANDEKALU_CAVALRY", count = 20},
                {type = "RESOURCE_MONOPOLY", id = "RESOURCE_SALT", percent = 60},
            },
            score = 1
        },
        -- end of victory conditions
    },

    CIVILIZATION_MAYA = {
        {
			id = "CHICHEN_ITZA",
			index = "1",
            year = nil,
			era = nil,
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_CHICHEN_ITZA"},
            },
            score = 1
        },
        {
            id = "STAR_WARS",
			index = "2",
            year = nil,
            era = nil,
            objectives = {
                {type = "NUM_CITIES_CAPITAL_RANGE", count = 6, range = 6},
                {type = "UNIT_KILL_COUNT", id = "UNIT_MAYAN_HULCHE", count = 10},
            },
            score = 1
        },
        {
            id = "LONG_COUNT_CALENDAR",
			index = "3",
			year = 2012,
			era = nil,
            objectives = {
                {type = "HIGHEST_TECH_COUNT"},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_MONGOLIA = {
        {
            id = "MONGOL_SHOT",
            index = "1",
            year = nil,
            era = nil,
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_MONGOLIAN_KESHIG", count = 50},
                {type = "BUILDING_COUNT", id = "BUILDING_ORDU", count = 5},
            },
            score = 1
        },
        {
            id = "SILK_ROAD",
            index = "2",
            year = nil,
            era = "ERA_RENAISSANCE",
            objectives = {
                {type = "MOST_ACTIVE_TRADE_ROUTES"},
                {type = "ROUTE_COUNT", count = 40},
            },
            score = 1
        },
        {
            id = "YEKE_MONGGHOL_ULUS",
            index = "3",
            year = nil,
            era = "ERA_RENAISSANCE",
            objectives = {
                {type = "CONTROL_ORIGINAL_CAPITALS", percent = 50},-- TODO
                {type = "GREAT_PERSON_TYPE_COUNT", id = "GREAT_PERSON_CLASS_GENERAL", count = 3}, -- TODO
            },
            score = 1
        },
        -- end of victory conditions
    },

    CIVILIZATION_NORWAY = {
        {
			id = "VIKING_AGE",
			index = "1",
            year = nil,
			era = nil,
            objectives = {
                {type = "UNIT_PILLAGE_COUNT", id = "UNIT_NORWEGIAN_LONGSHIP", count = 30},
                {type = "OCCUPIED_CAPITAL_COUNT", count = 3},
                {type = "MOST_OUTGOING_TRADE_ROUTES"},
            },
            score = 1
        },
        {
            id = "NORSE_EXPEDITIONS",
			index = "2",
            year = nil,
            era = "ERA_MEDIEVAL",
            objectives = {
                {type = "NATURAL_WONDER_COUNT", count = 4},
                {type = "FOREIGN_CONTINENT_CITIES", count = 3},
            },
            score = 1
        },
        {
            id = "LAND_OF_THE_MIDNIGHT_SUN",
			index = "3",
			year = nil,
			era = "ERA_RENAISSANCE",
            objectives = {
                {type = "FEATURE_COUNT", id = "FEATURE_ICE", count = 15},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_NUBIA = {
        {
			id = "KINGDOM_OF_GOLD",
			index = "1",
            year = nil,
			era = "ERA_CLASSICAL",
            objectives = {
                {type = "HIGHEST_GOLD_PER_TURN"},
                {type = "GOLD_COUNT", count = 1000},
            },
            score = 1
        },
        {
            id = "BOWMEN_OF_TASETI",
			index = "2",
            year = nil,
            era = nil,
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_NUBIAN_PITATI", count = 20},
                {type = "FULLY_UPGRADE_UNIT_COUNT", id = "UNIT_NUBIAN_PITATI", count = 1},
            },
            score = 1
        },
        {
            id = "MONUMENTS_OF_MEROE",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "WONDER_ADJACENT_IMPROVEMENT", id = "BUILDING_JEBEL_BARKAL", improvement = "IMPROVEMENT_PYRAMID"},
                {type = "IMPROVEMENT_PYRAMID", count = 10},
                {type = "GOLD_COUNT", count = 6000},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_PERSIA = {
        {
			id = "THE_IMMORTALS",
			index = "1",
            year = -450,
			era = nil,
            objectives = {
                {type = "UNIT_COUNT", id = "UNIT_PERSIAN_IMMORTAL", count = 5},
                {type = "UNIT_KILL_COUNT", id = "UNIT_PERSIAN_IMMORTAL", count = 10},
                {type = "OCCUPIED_CAPITAL_COUNT", count = 3},
            },
            score = 1
        },
        {
            id = "ACHAEMENID_ARCHITECTURE",
			index = "2",
            year = -330,
			era = nil,
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_APADANA"},
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_PAIRIDAEZA", count = 5},
            },
            score = 1
        },
        {
            id = "KING_OF_KINGS",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "FIRST_GOVERNMENT", id = "GOVERNMENT_MONARCHY"},
                {type = "SUZERAINTY_COUNT", count = 5},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_PHOENICIA = {
        {
			id = "MERCANTILE_EMPIRE",
			index = "1",
            year = nil,
			era = "ERA_CLASSICAL",
            eraLimit = "END_ERA",
            objectives = {
                {type = "MOST_OUTGOING_TRADE_ROUTES"},
            },
            score = 1
        },
        {
            id = "REFUGEES_OF_TYRE",
			index = "2",
            year = nil,
			era = "ERA_CLASSICAL",
            objectives = {
                {type = "PROJECT_COUNT", id = "PROJECT_COTHON_CAPITAL_MOVE", count = 1},
                {type = "COASTAL_CITY_COUNT", count = 6},
            },
            score = 1
        },
        {
            id = "PURPLE_DYE_MONOPOLY",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "RESOURCE_MONOPOLY", id = "RESOURCE_DYES", percent = 60},
            },
            score = 1
        },
		-- end of victory conditions
    },

	CIVILIZATION_ROME = {
        {
			id = "PAX_ROMANA",
			index = "1",
            year = 200,
			era = nil,
            objectives = {
                -- {type = "WONDER_BUILT", id = "BUILDING_COLOSSEUM"},
                -- {type = "DISTRICT_COUNT", id = "DISTRICT_BATH", count = 4},
                -- {type = "ROUTE_COUNT", count = 15},
                {type = "WONDER_BUILT_CITIES_IN_RANGE", id = "BUILDING_MONUMENT", count = 6, range = 6},
            },
            score = 1
        },
        {
            id = "IMPERIUM_ROMANUM",
			index = "2",
            year = 450,
			era = nil,
            objectives = {
                -- {type = "LAND_AREA_HOME_CONTINENT", percent = 20},
                -- {type = "FOREIGN_CONTINENT_CITIES", count = 5},
                {type = "FIRST_GOVERNMENT", id = "GOVERNMENT_CHIEFDOM"},
            },
            score = 1
        },
        {
            id = "MARE_NOSTRUM",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                -- {type = "TERRITORY_CONTROL", territory = "SEA", minimumSize = 8},
                {type = "NUM_CITIES_CAPITAL_RANGE", count = 1, range = 6},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_SCOTLAND = {
        {
			id = "SCOTTISH_ENLIGHTENMENT",
			index = "1",
            year = nil,
			era = nil,
            objectives = {
                {type = "FIRST_CIVIC_RESEARCHED", id = "CIVIC_THE_ENLIGHTENMENT"},
                {type = "GREAT_PERSON_ERA_COUNT", id = "ERA_INDUSTRIAL", count = 3},
            },
            score = 1
        },
        {
            id = "HIGHLAND_CHARGE",
			index = "2",
            year = nil,
            era = nil,
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_SCOTTISH_HIGHLANDER", count = 10},
            },
            score = 1
        },
        {
            id = "ACT_OF_UNION",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "ALLIANCE_COUNT", count = 5},
                {type = "MAXIMUM_ALLIANCE_LEVEL_COUNT", count = 3},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_SCYTHIA = {
        {
			id = "PARTHIAN_SHOT",
			index = "1",
            year = nil,
			era = "ERA_CLASSICAL",
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_SCYTHIAN_HORSE_ARCHER", count = 10},
                {type = "UNIT_PILLAGE_COUNT", id = "UNIT_SCYTHIAN_HORSE_ARCHER", count = 10},
            },
            score = 1
        },
        {
            id = "SCYTHIAN_MIGRATIONS",
			index = "2",
            year = nil,
            era = "ERA_CLASSICAL",
            objectives = {
                {type = "BORDERING_CITY_COUNT", count = 5},
                {type = "UNIT_CLASS_COUNT", id = "PROMOTION_CLASS_LIGHT_CAVALRY", count = 20},
                {type = "GOLD_COUNT", count = 1000},
            },
            score = 1
        },
        {
            id = "STEPPE_NOMADS",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "FIRST_TECH_RESEARCHED", id = "TECH_HORSEBACK_RIDING"},
                {type = "FIRST_TECH_RESEARCHED", id = "TECH_STIRRUPS"},
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_KURGAN", count = 10},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_SPAIN = {
        {
			id = "RECONQUISTA",
			index = "1",
            year = nil,
			era = nil,
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_SPANISH_CONQUISTADOR", count = 10},
                {type = "UNIT_CONQUER_CITY_COUNT", id = "UNIT_SPANISH_CONQUISTADOR", count = 5},
            },
            score = 1
        },
        {
            id = "AGE_OF_DISCOVERY",
			index = "2",
            year = 1650,
            era = nil,
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_CASA_DE_CONTRATACION"},
                {type = "NATURAL_WONDER_COUNT", count = 5},
            },
            score = 1
        },
        {
            id = "MISSIONARY_ZEAL",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "CONVERT_NUM_CONTINENTS", count = 3},
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_MISSION", count = 10},
            },
            score = 1
        },
		-- end of victory conditions
    },

    CIVILIZATION_SUMERIA = {
        {
			id = "CRADLE_OF_CIVILIZATION",
			index = "1",
            year = nil,
			era = nil,
            objectives = {
                {type = "FIRST_BUILDING_CONSTRUCTED", id = "BUILDING_LIBRARY"},
                {type = "FIRST_CIVIC_RESEARCHED", id = "CIVIC_EARLY_EMPIRE"},
                {type = "FIRST_WAR_DECLARED"},
            },
            score = 1
        },
        {
            id = "SUMERIAN_RENAISSANCE",
			index = "2",
            year = nil,
			era = "ERA_ANCIENT",
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_ETEMENANKI"},
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_ZIGGURAT", count = 3},
            },
            score = 1
        },
        {
            id = "EPIC_OF_GILGAMESH",
			index = "3",
			year = nil,
			era = "ERA_ANCIENT",
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_SUMERIAN_WAR_CART", count = 5},
				{type = "FIRST_GREAT_PERSON_CLASS", id = "GREAT_PERSON_CLASS_WRITER"},
            },
            score = 1
        },
		-- end of victory conditions
    },
    -- Other civilizations' conditions follow...
}