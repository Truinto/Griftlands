return function(mod) --pass modinit info

    local negotiation_defs = require "negotiation/negotiation_defs"
    local CARD_FLAGS = negotiation_defs.CARD_FLAGS
    local EVENT = negotiation_defs.EVENT
    local battle_defs = require "battle/battle_defs"
    local BATTLE_EVENT = battle_defs.BATTLE_EVENT

    local function AddHelperCards( graft_def )
        if graft_def.negotiation_modifier then
        
            local negotiation_defs = require "negotiation/negotiation_defs"
            
            local id = graft_def.negotiation_modifier.id or graft_def.id
            
            if not graft_def.negotiation_modifier.desc then
                if graft_def.desc then
                    if type(graft_def.desc) == "function" then
                        graft_def.negotiation_modifier.desc = function(condition, minigame) return condition.graft:GetDesc() end
                    else 
                        graft_def.negotiation_modifier.desc = graft_def.desc
                    end
                end
            end
            
            graft_def.negotiation_modifier.desc = graft_def.negotiation_modifier.desc or "MISSING GRAFT CONDITION DESCRIPTION"
            graft_def.negotiation_modifier.name = graft_def.negotiation_modifier.name or graft_def.name
            graft_def.negotiation_modifier.icon = graft_def.negotiation_modifier.icon or graft_def.img
    
            AddNegotiationModifier(id, graft_def.negotiation_modifier)
            graft_def.negotiation_modifier = id
        end
    end

    local grafts_merge =
    {
        swear_jar =
        {
            desc = "Start your run with an additional 500 shills.",
            event_handlers =
            {
                ["new_game"] = function( self, gamestate )
                    gamestate:GetCaravan():AddMoney(500)
                end
            },
        },
        
        interior_drill = 
        {
            cost_reduction = 1,
            repeat_reduction = 1,
        },
        interior_drill_plus =
        {
            name = "Boosted Interior Drill",
            desc = "At the start of your turn, reduce the cost of <#UPGRADE>two</> random cards in your hand by 1 until played.",
            cost_reduction = 1,
            repeat_reduction = 2,
        },

        quick_charger =
        {
            cost_reduction = 1,
            repeat_reduction = 1,
        },
    
        quick_charger_plus =
        {
            name = "Boosted Quick Charger",
            desc = "At the start of your turn, reduce the cost of <#UPGRADE>two</> random cards in your hand by 1 until played.",
            cost_reduction = 1,
            repeat_reduction = 2,
        },
    }

    local battleCondition_merge =
    {
        quick_charger = 
        {
            event_handlers = 
            {
                [ BATTLE_EVENT.BEGIN_PLAYER_TURN ] = function( self, battle )
                    local hand = battle:GetHandDeck()
                    local count = self.graft:GetDef().repeat_reduction
                    for i = 1, count, 1 do
                        local card = hand:PickCardIf( self.CanReduceCost )
                        if card then
                            if self.chosen_cards == nil then
                                self.chosen_cards = {}
                            end
                            table.insert(self.chosen_cards, card)
        
                            battle:BroadcastEvent( BATTLE_EVENT.GRAFT_TRIGGERED, self.graft )
                        end
                    end
                end,

                [ BATTLE_EVENT.CALC_ACTION_COST ] = function( self, cost_acc, card, target )
                    if self.chosen_cards then
                        local count = table.count(self.chosen_cards, card)
                        for i = 1, count, 1 do
                            cost_acc:AddValue(-self.graft:GetDef().cost_reduction, self)
                        end
                    end
                end,

                [ BATTLE_EVENT.POST_RESOLVE ] = function( self, battle, attack )
                    if self.chosen_cards then
                        table.arrayremoveall( self.chosen_cards, attack.card )
                    end
                end,
            },
        },
    }

    local negotiationModifier_merge =
    {
        interior_drill = 
        {
            event_handlers = 
            {
                [ EVENT.HAND_DRAWN ] = function( self, minigame )
                    print("DEBUG: HAND_DRAWN")
                    local hand = minigame:GetHandDeck()
                    local count = self.graft:GetDef().repeat_reduction
                    for i = 1, count, 1 do
                        local card = hand:PickCardIf( self.CanReduceCost )
                        if card then
                            if self.chosen_cards == nil then
                                self.chosen_cards = {}
                            end
                            table.insert(self.chosen_cards, card)
                            minigame:BroadcastEvent( EVENT.GRAFT_TRIGGERED, self.graft )
                        end
                    end
                end,

                [ EVENT.CALC_ACTION_COST ] = function( self, cost_acc, card, target )
                    print("DEBUG: CALC_ACTION_COST")
                    if self.chosen_cards then
                        local count = table.count(self.chosen_cards, card)
                        for i = 1, count, 1 do
                            cost_acc:AddValue(-self.graft:GetDef().cost_reduction, self)
                        end
                    end
                end,

                [ EVENT.POST_RESOLVE ] = function( self, minigame, card )
                    print("DEBUG: POST_RESOLVE")
                    if self.chosen_cards then
                        table.arrayremoveall( self.chosen_cards, card )
                    end
                end,    
            },
        },
    }

    for i, id, data in sorted_pairs( grafts_merge ) do
        local graft = Content.GetGraft( id, data )
        for k,v in pairs(data) do
            graft[k] = v
        end
    end
    
    for i, id, data in sorted_pairs( battleCondition_merge ) do
        local modifier = Content.GetBattleCondition( id, data )
        for k,v in pairs(data) do
            modifier[k] = v
        end
    end
    
    for i, id, data in sorted_pairs( negotiationModifier_merge ) do
        local modifier = Content.GetNegotiationModifier( id, data )
        for k,v in pairs(data) do
            modifier[k] = v
        end
    end

end