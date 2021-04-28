--
-- Add functionality to handle ranged attack distances and proximities
--
--

function modRangedAttack(rSource, rTarget, rRoll)
	-- Debug.console(rSource, rTarget, rRoll)
	-- Determine attack type
	local sAttackType = nil;
	if rRoll.sType == "attack" then
		sAttackType = string.match(rRoll.sDesc, "%[ATTACK.*%((%w+)%)%]");
		if not sAttackType then
			sAttackType = "M";
		end
	elseif rRoll.sType == "grapple" then
		sAttackType = "M";
	end
	if sAttackType == "R" then
		-- Debug.chat("Ranged attack!")
		local sAttackName = string.match(rRoll.sDesc, "%[.+%] (.+)")
		local creatureNode = DB.findNode(rSource.sCreatureNode)
		local weaponAttacks = DB.getChildren(creatureNode, "weaponlist")
		local weaponRange = nil
		for _, weaponAttack in pairs(weaponAttacks) do
			if sAttackName == DB.getValue(weaponAttack, "name") then
				weaponRange = DB.getValue(weaponAttack, "rangeincrement")
				break;
			end
		end
		-- Debug.chat("Range", weaponRange)
		if weaponRange then 
			local sourceToken = CombatManager.getTokenFromCT(rSource.sCTNode)
			local targetToken = CombatManager.getTokenFromCT(rTarget.sCTNode)
			local nDistanceBetweenTokens = Token.getDistanceBetween(sourceToken, targetToken)
			-- Debug.chat("Distance", nDistanceBetweenTokens)
			if(nDistanceBetweenTokens > weaponRange) then
				local distancePenalty = math.floor(nDistanceBetweenTokens / weaponRange - 0.000001) * 2
				-- Debug.chat("Penalty", distancePenalty)
				rRoll.nMod = rRoll.nMod - distancePenalty
				rRoll.sDesc = rRoll.sDesc .. " [RANGE PENALTY -" .. distancePenalty .. "]"
			end
		end
	end
end

function handleAttack(rSource, rTarget, rRoll)
	modRangedAttack(rSource, rTarget, rRoll)
	ActionAttack.modAttack(rSource, rTarget, rRoll)
end

function onInit()
	-- remove original result handlers
	ActionsManager.unregisterModHandler("attack");
	-- add new one
	ActionsManager.registerModHandler("attack", handleAttack);
end
