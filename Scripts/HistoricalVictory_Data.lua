-- ===========================================================================
--	Historical Victory Data
-- ===========================================================================
print("Loading HistoricalVictory_Data.lua")

-- Insert Civilizations or Leaders into this table for custom historical victories
-- Civs or Leaders not in this table will use the generic conditions
-- This table tracks the index and objective count for each challenge, to be used to generate text and check properties
HSD_victoryCivilizationData = {
	["CIVILIZATION_PERSIA"] = {
			{ victory = 1, objectives = 2 },
			{ victory = 2, objectives = 2 },
			{ victory = 3, objectives = 1 },
	},
    ["CIVILIZATION_ROME"] = 
		{ 
			{ victory = 1, objectives = 3 },
			{ victory = 2, objectives = 2 },
			{ victory = 3, objectives = 1 },
		},
	["CIVILIZATION_EGYPT"] = {
			{ victory = 1, objectives = 3 },
			{ victory = 2, objectives = 3 },
			{ victory = 3, objectives = 3 },
	},
	["CIVILIZATION_BRAZIL"] = {
			{ victory = 1, objectives = 1 },
			{ victory = 2, objectives = 1 }
	},
    ["LEADER_JULIUS_CAESAR"] = 
		{ 
			{ victory = 1, objectives = 1 },
			{ victory = 2, objectives = 1 },
			{ victory = 3, objectives = 1 },
	}
}

HSD_victoryConditionsConfig = {
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
    CIVILIZATION_PERSIA = {
        {
			id = "THE_IMMORTALS",
			index = "1",
            year = -450,
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
            objectives = {
                {type = "SUZERAINTY_COUNT", count = 5},
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
                {type = "LAND_AREA", region = "CONTINENT_EUROPE", percent = 20},
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
    -- Other civilizations' conditions follow...
}