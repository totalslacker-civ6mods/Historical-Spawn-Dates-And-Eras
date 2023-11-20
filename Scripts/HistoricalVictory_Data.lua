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
    CIVILIZATION_PERSIA = {
        {
			id = "THE_IMMORTALS",
			index = "1",
            year = -450,
            objectives = {
                {type = "UNIT", id = "UNIT_PERSIAN_IMMORTAL", count = 5},
                {type = "CAPITAL_CONTROL_COUNT", count = 2},
            },
            score = 1 -- Score awarded for completing this set of objectives
        },
        {
            id = "ACHAEMENID_ARCHITECTURE",
			index = "2",
            year = -350,
            objectives = {
                {type = "WONDER_BUILT", id = "BUILDING_APADANA"},
                {type = "IMPROVEMENT", id = "IMPROVEMENT_PAIRIDAEZA", count = 5},
            },
            score = 1 -- Score awarded for completing this set of objectives
        },
        {
            id = "KING_OF_KINGS",
			index = "3",
			year = nil,
            objectives = {
                {type = "SUZERAINTY_COUNT", count = 5},
            },
            score = 1 -- Score awarded for completing this set of objectives
        },
		-- end of victory conditions
    },
	CIVILIZATION_ROME = {
        {
			id = "PAX_ROMANA",
			index = "1",
            year = 100,
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
            objectives = {
                {type = "LAND_AREA", region = "CONTINENT_EUROPE", percent = 20},
                {type = "OUT_OF_REGION_CITIES", region = "CONTINENT_EUROPE", count = 5},
            },
            score = 1 -- Score awarded for completing this set of objectives
        },
        {
            id = "MARE_NOSTRUM",
			index = "3",
			year = nil,
            objectives = {
                {type = "TERRITORY_CONTROL", territory = "SEA", minimumSize = 6},
            },
            score = 1 -- Score awarded for completing this set of objectives
        },
		-- end of victory conditions
    },
    -- Other civilizations' conditions follow...
}