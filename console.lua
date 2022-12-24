function c_addgraft( id )
	local def = Content.GetGraft( id )
	if def then
        local graft = GraftInstance( id )
		TheGame:GetGameState():GetPlayerAgent().graft_owner:AddGraft( graft )
	end
end

function c_removegraft( id )
	local owner = TheGame:GetGameState():GetPlayerAgent().graft_owner
	local graft = owner:GetGraft( id )
	if graft then
		owner:RemoveGraft( graft )
	end
end

function c_addslot( isCombat, number )
	local type = GRAFT_TYPE.NEGOTIATION
	if isCombat == true then
		type = GRAFT_TYPE.COMBAT
	end
	TheGame:GetGameState():GetPlayerAgent().graft_owner:IncreaseMaxGrafts( type, number )
end

function c_forgetcard( id )
	for i,card in ipairs(TheGame:GetGameState():GetPlayerAgent().battler:GetCards()) do
		if card.id == id then
			card:Consume()
			return
		end
	end

	for i,card in ipairs(TheGame:GetGameState():GetPlayerAgent().negotiator:GetCards()) do
		if card.id == id then
			card:Consume()
			return
		end
	end
end

function c_sethealth( number, max )
	local health = TheGame:GetGameState():GetPlayerAgent():GetAspect("health") -- GetHealth()
	if health and max and health.max ~= max then
		local diff = max - health.max
		health.base_max = health.base_max + diff
		health:_RecalcMax()
		--health:AddStatModifier("BOG_SYMBIOSIS", 3)
	end
	health:Set(number)
end

function c_setmoral( number, max )
	local moral = TheGame:GetGameState():GetPlayerAgent():GetAspect("morale") -- GetMorale()
	if moral and max and moral.max ~= max then
		local diff = max - moral.max
		moral.base_max = moral.base_max + diff
		moral:_RecalcMax()
		--moral:AddStatModifier("BOG_SYMBIOSIS", 3)
	end
	moral:Set(number)
end

function c_setlumin( number )
	local gun_graft = TheGame:GetGameState():GetPlayerAgent().graft_owner:GetGrafts(GRAFT_TYPE.BLASTER)[1]
	gun_graft.userdata.max_charges = number
	print("set lumin tracker to " .. number)
end