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
                {type = "UNLOCK_ALL_ERA_CIVICS", id = "ERA_CLASSICAL"}, -- TODO
            },
            score = 1
        },
        {
            id = "PELOPONNESIAN_LEAGUE",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "FULLY_UPGRADE_UNIT_COUNT", id = "UNIT_GREEK_HOPLITE", count = 2}, -- TODO
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
                {type = "IMPROVEMENT", id = "IMPROVEMENT_SPHINX", count = 1},
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
            },
            score = 1
        },
        {
            id = "SUN_GOD_ATEN",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "FIRST_GREAT_PERSON_CLASS", id = "GREAT_PERSON_CLASS_PROPHET"},
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
                {type = "BUILDING", id = "BUILDING_ORACLE"},
				{type = "BUILDING", id = "BUILDING_STONEHENGE"},
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
                {type = "GREAT_PEOPLE_ACTIVATED", count = 4},
            },
            score = 1 
        },
        {
            id = "KOINE_GREEK",
			index = "3",
			year = nil,
			era = "ERA_CLASSICAL",
            objectives = {
                {type = "DISTRICT_ON_NUM_CONTINENTS", id = "DISTRICT_ACROPOLIS", count = 3},
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
                {type = "FJORD_FORTRESSES"},
            },
            score = 1 
        },
        {
            id = "LAND_OF_THE_MIDNIGHT_SUN",
			index = "3",
			year = nil,
			era = "ERA_RENAISSANCE",
            objectives = {
                {type = "6_POP_CITY_ABOVE_ARCTIC", count = 5},
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
                {type = "UNIT", id = "UNIT_PERSIAN_IMMORTAL", count = 5},
                {type = "OCCUPIED_CAPITAL_COUNT", count = 2},
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
                {type = "IMPROVEMENT", id = "IMPROVEMENT_PAIRIDAEZA", count = 5},
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
            objectives = {
                {type = "MOST_TRADE_ROUTES_END_ERA"},
            },
            score = 1
        },
        {
            id = "REFUGEES_OF_TYRE",
			index = "2",
            year = nil,
			era = "ERA_CLASSICAL",
            objectives = {
                {type = "PROJECT_COMPLETED", id = "PROJECT_COTHON_CAPITAL_MOVE"},
                {type = "CITY_ADJACENT_TO_CAPITAL_SEA_COUNT", count = 5},
            },
            score = 1
        },
        {
            id = "PHOENICIAN_VOYAGES",
			index = "3",
			year = nil,
			era = "ERA_MEDIEVAL",
            objectives = {
                {type = "CIRCUMNAVIGATE_HOME_CONTINENT"},
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
                {type = "UNIT", id = "UNIT_WARRIOR", count = 1},
                {type = "DISTRICT", id = "DISTRICT_CITY_CENTER", count = 1},
                {type = "ROAD", count = 1},
            },
            score = 1 -- Score awarded for completing this set of objectives
        },
        {
            id = "IMPERIUM_ROMANUM",
			index = "2",
            year = 200,
			era = nil,
            objectives = {
                {type = "LAND_AREA_HOME_CONTINENT", percent = 20},
                {type = "FOREIGN_CONTINENT_CITIES", count = 5},
            },
            score = 1 -- Score awarded for completing this set of objectives
        },
        {
            id = "MARE_NOSTRUM",
			index = "3",
			year = nil,
			era = nil,
            objectives = {
                {type = "TERRITORY_CONTROL", territory = "SEA", minimumSize = 6},
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
                {type = "FIRST_TECH_RESEARCHED", id = "TECH_WRITING"},
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
                {type = "IMPROVEMENT", id = "IMPROVEMENT_ZIGGURAT", count = 3},
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