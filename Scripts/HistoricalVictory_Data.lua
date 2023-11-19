-- ===========================================================================
--	Historical Victory Data
-- ===========================================================================
print("Loading HistoricalVictory_Data.lua")

-- Insert Civilizations or Leaders into this table for custom historical victories
-- Civs or Leaders not in this table will use the generic conditions
-- This table tracks the index and objective count for each challenge, to be used to generate text and check properties
HSD_victoryCivilizationData = {
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
    CIVILIZATION_ROME = {
        {
			id = "PAX_ROMANA",
			index = "1",
            year = 100,
            objectives = {
                {type = "BUILDING", id = "BUILDING_MONUMENT", count = 1},
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