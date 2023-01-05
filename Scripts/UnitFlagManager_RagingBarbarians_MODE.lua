-- ===========================================================================
--	Unit Flag Manager (Raging Barbarians Mode)
--	Add the tribe name type to the unit flag
-- ===========================================================================

-- ===========================================================================
-- INCLUDES
-- ===========================================================================
include( "UnitFlagManager" )

-- ===========================================================================
--	CACHE BASE FUNCTIONS
-- ===========================================================================
local BASE_UpdateName		= UnitFlag.UpdateName

-- ===========================================================================
--	OVERRIDES
-- ===========================================================================

function UnitFlag.UpdateName( self )
	BASE_UpdateName(self)

	local localPlayerID : number = Game.GetLocalPlayer()
	if (localPlayerID == -1) then
		return
	end
	local iEra = Game.GetEras():GetCurrentEra()
	local szAppendName = ""
	if (iEra < 2) then
		-- print("Ancient or Classical era detected. Barbarians will be referred to as 'Tribes'.")
		szAppendName = "Tribes"
	elseif(iEra < 4) then
		-- print("Medieval or Renaissance era detected. Barbarians will be referred to as 'Heretics'.")
		szAppendName = "Heretics"
	elseif(iEra < 6) then
		-- print("Industrial or Modern era detected. Barbarians will be referred to as 'Nationalists'.")
		szAppendName = "Nationalists"
	elseif(iEra >= 7) then
		-- print("Atomic era or greater detected. Barbarians will be referred to as 'Terrorists'.")
		szAppendName = "Terrorists"
	end
	
	local pUnit : table = self:GetUnit()
	if(pUnit ~= nil)then
		local tribeIndex : number = pUnit:GetBarbarianTribeIndex()
		-- print("tribeIndex is "..tostring(tribeIndex))
		if(tribeIndex >= 0)then
			local pBarbarianTribeManager : table = Game.GetBarbarianManager()
			local nameString = self.m_Instance.UnitIcon:GetToolTipString()
			local barbType : number = pBarbarianTribeManager:GetTribeNameType(tribeIndex)
			if(barbType >= 0)then
				local pBarbTribe : table = GameInfo.BarbarianTribeNames[barbType]
				nameString = nameString .. "[NEWLINE]" .. Locale.Lookup(pBarbTribe.TribeDisplayName) .. " " .. szAppendName
				self.m_Instance.UnitIcon:SetToolTipString( nameString )
			end
		end
	end
end