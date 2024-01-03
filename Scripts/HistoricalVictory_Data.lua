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
                {type = "TERRITORY_CONTROL", territory = "SEA", minimumSize = 1},
                {type = "TERRITORY_CONTROL", territory = "DESERT", minimumSize = 1},
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
            },
            score = 1
        },
		-- end of victory conditions
    },

    LEADER_GORGO = {
        {
			id = "THERMOPYLAE",
			index = "1",
            year = nil,
			era = "ERA_CLASSICAL",
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_GREEK_HOPLITE", count = 10},
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
			era = nil,
            objectives = {
                {type = "FULLY_UPGRADE_UNIT_COUNT", id = "UNIT_GREEK_HOPLITE", count = 2},
                {type = "UNIT_CONQUER_CITY_COUNT", id = "UNIT_GREEK_HOPLITE", count = 5}, -- TODO
            },
            score = 1
        },
		-- end of victory conditions
    },

    LEADER_RAMSES = {
        {
			id = "MONUMENTS_OF_THE_PHARAOHS",
			index = "1",
            year = nil,
			era = "ERA_ANCIENT",
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_PYRAMID"},
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_SPHINX", count = 1},
				{type = "WONDER_ADJACENT", id = "BUILDING_PYRAMID", adjacentImprovement = "IMPROVEMENT_SPHINX"},
            },
            score = 1
        },
        {
            id = "THE_NEW_KINGDOM",
			index = "2",
            year = nil,
			era = "ERA_CLASSICAL",
            objectives = {
                {type = "CITY_WITH_FLOODPLAIN_COUNT", count = 5}, --TODO
                {type = "UNIT_KILL_COUNT", id = "UNIT_EGYPTIAN_CHARIOT_ARCHER", count = 20},
            },
            score = 1
        },
        {
            id = "KARNAK",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "FIRST_GREAT_PERSON_CLASS", id = "GREAT_PERSON_CLASS_PROPHET"},
                {type = "FIRST_BUILDING_CONSTRUCTED", id = "BUILDING_TEMPLE"},
            },
            score = 1
        },
		-- end of victory conditions
    },

    -- CIVILIZATIONS

    CIVILIZATION_EGYPT = {
        {
			id = "MONUMENTS_OF_THE_PHARAOHS",
			index = "1",
            year = nil,
			era = "ERA_ANCIENT",
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_PYRAMID"},
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_SPHINX", count = 1},
				{type = "WONDER_ADJACENT_IMPROVEMENT", wonder = "BUILDING_PYRAMID", improvement = "IMPROVEMENT_SPHINX"},
            },
            score = 1
        },
        {
            id = "NILE_KINGDOM",
			index = "2",
            year = nil,
			era = nil,
            objectives = {
                {type = "CONTROL_ALL_CAPITAL_ADJACENT_RIVER"}, --TODO
            },
            score = 1
        },
        {
            id = "BREADBASKET_OF_ANCIENT_WORLD",
			index = "3",
			year = -30,
			era = nil,
            objectives = {
                {type = "MOST_ACTIVE_TRADEROUTES_ALL"},
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
            },
            score = 1
        },
        {
            id = "CELTIC_MIGRATIONS",
			index = "2",
            year = -50,
            era = nil,
            objectives = {
                {type = "BORDERING_CITY_COUNT", count = 5},
            },
            score = 1 
        },
        {
            id = "GALLIC_WARRIORS",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "UNIT_KILL_COUNT", id = "UNIT_GAUL_GAESATAE", count = 20},
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
            objectives = {
                {type = "GREAT_PEOPLE_ACTIVATED", count = 4}, -- TODO
            },
            score = 1 
        },
        {
            id = "KOINE_GREEK",
			index = "3",
			year = nil,
			era = "ERA_CLASSICAL",
            objectives = {
                {type = "DISTRICT_ON_NUM_CONTINENTS", id = "DISTRICT_ACROPOLIS", count = 3}, -- TODO
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
            id = "HOUSE_OF_KUHUL_AJAW",
			index = "2",
            year = nil,
            era = "ERA_MEDIEVAL",
            objectives = {
                {type = "HIGHEST_CITY_POPULATION"},
            },
            score = 1 
        },
        {
            id = "LONG_COUNT_CALENDAR",
			index = "3",
			year = nil,
			era = "ERA_INDUSTRIAL",
            objectives = {
                {type = "MINIMUM_CONTINENT_TECH_COUNT", continent = "CONTINENT_EUROPE"},
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
            },
            score = 1
        },
        {
            id = "FJORD_FORTRESSES",
			index = "2",
            year = nil,
            era = "ERA_MEDIEVAL",
            objectives = {
                {type = "FJORD_FORTRESSES"}, -- TODO
            },
            score = 1 
        },
        {
            id = "LAND_OF_THE_MIDNIGHT_SUN",
			index = "3",
			year = nil,
			era = "ERA_RENAISSANCE",
            objectives = {
                {type = "6_POP_CITY_ABOVE_ARCTIC", count = 5}, -- TODO
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
                {type = "OCCUPIED_CAPITAL_COUNT", count = 3},
            },
            score = 1
        },
        {
            id = "ACHAEMENID_ARCHITECTURE",
			index = "2",
            year = -350,
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
                {type = "PROJECT_COMPLETED", id = "PROJECT_COTHON_CAPITAL_MOVE"}, -- TODO
                {type = "CITY_ADJACENT_TO_CAPITAL_SEA_COUNT", count = 5}, -- TODO
            },
            score = 1
        },
        {
            id = "PHOENICIAN_VOYAGES",
			index = "3",
			year = nil,
			era = "ERA_MEDIEVAL",
            objectives = {
                {type = "CIRCUMNAVIGATE_HOME_CONTINENT"}, -- TODO
            },
            score = 1
        },
		-- end of victory conditions
    },

	CIVILIZATION_ROME = {
        {
			id = "PAX_ROMANA",
			index = "1",
            year = 100,
			era = nil,
            objectives = {
                -- {type = "UNIT_COUNT", id = "UNIT_WARRIOR", count = 1},
                -- {type = "DISTRICT_COUNT", id = "DISTRICT_CITY_CENTER", count = 1},
                -- {type = "ROUTE_COUNT", count = 1},
                {type = "UNIT_COUNT", id = "UNIT_ROMAN_LEGION", count = 1},
            },
            score = 1 -- Score awarded for completing this set of objectives
        },
        {
            id = "IMPERIUM_ROMANUM",
			index = "2",
            year = 200,
			era = nil,
            objectives = {
                -- {type = "LAND_AREA_HOME_CONTINENT", percent = 20},
                -- {type = "FOREIGN_CONTINENT_CITIES", count = 5},
                {type = "IMPROVEMENT_COUNT", id = "IMPROVEMENT_MINE", count = 1},
            },
            score = 1 -- Score awarded for completing this set of objectives
        },
        {
            id = "MARE_NOSTRUM",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "TERRITORY_CONTROL", territory = "SEA", minimumSize = 8},
                -- {type = "BORDERING_CITY_COUNT", count = 1},
            },
            score = 1 -- Score awarded for completing this set of objectives
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
                {type = "UNIT_KILL_COUNT", id = "UNIT_SUMERIAN_WAR_CART", count = 10},
				{type = "FIRST_GREAT_PERSON_CLASS", id = "GREAT_PERSON_CLASS_WRITER"},
            },
            score = 1
        },
		-- end of victory conditions
    },
    -- Other civilizations' conditions follow...
}