require "ui/widgets/chargecell"

local battle_defs = require "battle/battle_defs"
local CARD_FLAGS = battle_defs.CARD_FLAGS
local BATTLE_EVENT = battle_defs.BATTLE_EVENT

local function NoCharges( self, battle )
    local tracker = self.owner:GetCondition("lumin_tracker") 
    return tracker and tracker:GetFullCharges() == 0
end

local function PreResolve( self, battle, attack )   -- impair_amt
    local tracker = self.owner:GetCondition("lumin_tracker") 
    if tracker then
        if self.impair_amt and tracker:GetFullCharges() == 0 then
            attack:AddCondition("IMPAIR", self.impair_amt, self)
        end
    end
end

local function PostResolve( self, battle, attack )  -- card_draw, lumin_charge: charge amount, lumin_only_empty: gain only charge if empty, surge_amt, concentration_amt
    if self.card_draw then
        battle:DrawCards(self.card_draw)
    end

    local tracker = self.owner:GetCondition("lumin_tracker")
    if tracker then
        if self.concentration_amt and tracker:GetFullCharges() == 0 then
            self.owner:AddCondition("CONCENTRATION", self.concentration_amt, self)
        end    

        if self.surge_amt and tracker:GetFullCharges() == 0 then
            self.owner:AddCondition("SURGE", self.surge_amt, self)
        end

        if self.lumin_charge and ( tracker:GetFullCharges() == 0 or self.lumin_only_empty ~= nil) then
            tracker:AddLuminCharges(self.lumin_charge, self)
        end
    end
end

local function EmptyHitTwice( self, battle )
    local tracker = self.owner:GetCondition("lumin_tracker")
    if tracker and tracker:GetFullCharges() == 0 then
        self.hit_count = 2
        return true
    else
        self.hit_count = 1
        return false
    end
end

local empty_cost_0 = 
{
    [ BATTLE_EVENT.CALC_ACTION_COST ] = function( self, cost_acc, card, target )
        if card == self then
            local tracker = self.owner:GetCondition("lumin_tracker")
            if tracker and tracker:GetFullCharges() == 0 then
                cost_acc:ModifyValue(0, self)
            end
        end
    end
}

local empty_cost_less = 
{
    [ BATTLE_EVENT.CALC_ACTION_COST ] = function( self, cost_acc, card, target )
        if card == self then
            local tracker = self.owner:GetCondition("lumin_tracker")
            if tracker and tracker:GetFullCharges() == 0 then
                cost_acc:AddValue(-1, self)
            end
        end
    end
}

local empty_bonus_damage = 
{
    [ BATTLE_EVENT.CALC_DAMAGE ] = function( self, card, target, dmgt )
        local tracker = self.owner:GetCondition("lumin_tracker")
        if tracker and tracker:GetFullCharges() == 0 then
            dmgt:AddDamage( 2, 2, self )
        end
    end
}

local attacks_merge = 
{
    kick_plus2b =
    {
        event_handlers = empty_cost_less
    },

    pistol_whip =
    {
        event_handlers = empty_cost_0
    },
    pistol_whip_plus =
    {
        event_handlers = empty_cost_0
    },
    pistol_whip_plus2 = 
    {
        event_handlers = empty_cost_0
    },

    lifeline = 
    {
        lumin_only_empty = true,
        OnPostResolve = PostResolve,
        PreReq = NoCharges,
        event_handlers = empty_cost_0
    },
    lifeline_plus = 
    {
        lumin_only_empty = true,
        OnPostResolve = PostResolve,
        PreReq = NoCharges,
        event_handlers = empty_cost_0
    },
    lifeline_plus2 = 
    {
        lumin_only_empty = true,
        OnPostResolve = PostResolve,
        PreReq = NoCharges,
        event_handlers = empty_cost_0
    },
    lifeline_plus2b = 
    {
        OnPostResolve = PostResolve,
        PreReq = NoCharges,
        event_handlers = empty_cost_0
    }, 

    sucker_punch =
    {
        PreReq = NoCharges,
        OnPreResolve = PreResolve,
        event_handlers = empty_bonus_damage
    },
    sucker_punch_plus =
    {
        PreReq = NoCharges,
        OnPreResolve = PreResolve,
        event_handlers = empty_bonus_damage
    },
    sucker_punch_plus2 =
    {
        PreReq = NoCharges,
        OnPreResolve = PreResolve,
        event_handlers = empty_bonus_damage
    },

    clean_open =
    {
        PreReq = EmptyHitTwice
    },
    clean_open_plus =
    {
        PreReq = EmptyHitTwice
    },
    clean_open_plus2 =
    {
        PreReq = EmptyHitTwice
    },
    clean_open_plus2c =
    {
        PreReq = EmptyHitTwice
    },
    clean_open_plus2b =
    {
        PreReq = function( self, battle )
            local tracker = self.owner:GetCondition("lumin_tracker")
            if tracker and tracker:GetFullCharges() == 0 then
                self.hit_count = 3
                return true
            else
                self.hit_count = 1
                return false
            end
        end,
    },
    clean_open_plus2d =
    {
        event_handlers = empty_cost_0
    },
    clean_open_plus2e =
    {
        surge_amt = 1,
        OnPostResolve = PostResolve
    },

    focused_strike =
    {
        PreReq = NoCharges,
        OnPostResolve = PostResolve,
    },
    focused_strike_plus =
    {
        PreReq = NoCharges,
        OnPostResolve = PostResolve,
    },
    focused_strike_plus2 =
    {
        PreReq = NoCharges,
        OnPostResolve = PostResolve,
    },
}

for i, id, data in sorted_pairs(attacks_merge) do
    local card = Content.GetBattleCard( id )
    
    -- if card doesn't exist and series is defined add new card
    if card == nil and data.series ~= nil then  -- "SMITH" "SAL" "ROOK"
        Content.AddBattleCard( id, data )
    elseif card == nil then
        print("card missing! " .. id)
    else -- otherwise edit existing
        for k, v in pairs(data) do
            if k == "OnPostResolve" and v == false then
                card[k] = nil
            else
                card[k] = v
            end
        end
    end
end

local battleCondition_merge = 
{
    BURN = -- don't consume scorched, if burn stack is 4 or less; can't reduce fighter below 1 hp if surrendered
    {
        event_handlers = 
        {
            [ BATTLE_EVENT.BEGIN_TURN ] = function( self, fighter )
                if fighter == self.owner then
                    if not self.calculated then
                        local total_damage = {}
                        for i,ally in ipairs(self.owner:GetTeam():GetFighters()) do
                            if ally:HasCondition("BURN") then
                                ally:GetCondition("BURN"):CalculateDamage(total_damage)
                            end
                        end

                        for fighter, damage in pairs(total_damage) do                            
                            if fighter:IsAlive() then
                                if fighter.can_surrender and ( fighter:GetStatus() == FIGHT_STATUS.SURRENDER or fighter:GetSurrenderHealth() > 0 ) then
                                    damage = math.min( damage, fighter:GetHealth() - 1 )
                                end
                                fighter:ApplyDamage(damage, nil, nil, true, {"burn"})
                                fighter:CheckForSurrender()
                            end
                        end
                    end

                    if self.stacks > 4 and self.owner:HasCondition("SCORCHED") then
                        self.owner:RemoveCondition("SCORCHED", 1)
                        self.owner:RemoveCondition("BURN", math.min(2, math.ceil(0.5*self.stacks)))
                    else
                        self.owner:RemoveCondition("BURN", math.ceil(0.5*self.stacks) )
                    end
                end
            end,

            [ BATTLE_EVENT.END_TURN ] = function( self, fighter )
                if fighter == self.owner then
                    self.calculated = false
                end
            end
        },
    },

    SURGE = 
    {
        event_handlers = 
        {
            [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                self.owner:RemoveCondition("SURGE", math.ceil(self.stacks * 0.5), self)
            end,

            [ BATTLE_EVENT.CALC_DAMAGE ] = function( self, card, target, dmgt )
                if card.owner == self.owner then
                    dmgt:AddDamage( 0, self.stacks, self)
                end
            end,

            [ BATTLE_EVENT.CONDITION_REMOVED ] = function( self, fighter, condition, stacks, source )
                if self.owner == fighter and condition.id == "SURGE" and source and source.owner == self.owner and source.id ~= "SURGE" then
                    local tracker = self.owner:GetCondition("lumin_tracker") 
                    if tracker then
                        self.battle:BroadcastEvent( BATTLE_EVENT.LUMIN_SPENT, self.battle, tracker:GetFullCharges() )
                    end
                end
            end,
        },
    },
    
    lumin_tracker =
    {
        -- hidden = true,
        -- defend_per_charge = 1,

        -- OnApply = function( self )
        --     self.charges = 0
        --     self.max_charges = self.owner:GetAgent():GetAspect("graft_owner"):GetGraft("rook_blasters") and self.owner:GetAgent():GetAspect("graft_owner"):GetGraft("rook_blasters").userdata.max_charges or 4
        --     self.primed = false
        -- end,

        -- ModifyMaxCharges = function( self, delta )
        --     self.max_charges = math.max( 0, self.max_charges + delta )
        -- end,

        -- AddLuminCharges = function( self, count, source )
        --     local counter = 0
        --     for i=1,count do
        --         local added = self:AddLuminCharge( source )
        --         if added then
        --             counter = counter + 1
        --         end
        --     end
        --     return counter
        -- end,

        AddLuminCharge = function( self, source )
            if self.charges < self.max_charges then
                self.charges = self.charges + 1
                self:CheckPrimed()
                self.battle:BroadcastEvent( BATTLE_EVENT.LUMIN_CHARGED, self.battle, self:GetFullCharges() )
                return true
            else
                self.owner:AddCondition("SURGE", 1, self)
                return false
            end
        end,

        RemoveCharges = function( self, count, source )
            local removed = 0
            local surge_limit = 3
            for i=1,count do
                if self.charges > 0 then
                    self.charges = self.charges - 1
                    self.battle:BroadcastEvent( BATTLE_EVENT.LUMIN_SPENT, self.battle, self:GetFullCharges() )
                    removed = removed + 1
                elseif self.owner:GetConditionStacks("SURGE") > 0 and surge_limit > 0 then
                    self.owner:RemoveCondition("SURGE", 1, self)
                    surge_limit = surge_limit - 1
                end
            end
            self:CheckPrimed()
            return removed

            --self.owner:RemoveCondition("SURGE", self.owner:GetConditionStacks("SURGE"), self)
        end,

        -- GetEmptyCharges = function( self )
        --     return self.max_charges - self.charges
        -- end,

        GetCharges = function( self )
            local surge = self.owner:GetConditionStacks("SURGE")
            surge = math.min(surge, 3)
            return surge + self.charges, surge + self.max_charges
        end,

        GetFullCharges = function( self )
            return self.charges, self.max_charges
        end,

        -- CheckPrimed = function( self )
        --     local primed = (self.charges >= self.max_charges)
        --     if primed ~= self.primed then
        --         self.primed = primed
        --         if primed then
        --             self.battle:BroadcastEvent( BATTLE_EVENT.PRIMED_GAINED, self.battle )
        --         else
        --             self.battle:BroadcastEvent( BATTLE_EVENT.PRIMED_LOST, self.battle )
        --         end
        --     end
        -- end,

        -- event_priorities =
        -- {
        --     [ BATTLE_EVENT.END_PLAYER_TURN  ] = 10,
        -- },

        -- event_handlers = 
        -- {
        --     [ BATTLE_EVENT.BEGIN_PLAYER_TURN ] = function( self, battle )
        --         self:AddLuminCharges(1, self, true)
        --     end,
        --     [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
        --         self.owner:AddCondition("DEFEND", self:GetEmptyCharges() * self.defend_per_charge, self)
        --     end
        -- },

        -- fighter_info_widget = function( fighter, condition, width, silent )
        --     return Widget.ChargeCellInfoWidget( fighter, condition, width, silent )
        -- end
    },
    
    fumes = 
    {
        event_handlers = 
        {
            [ BATTLE_EVENT.CALC_DAMAGE ] = function( self, card, target, dmgt )
                if not self.tracker then self.tracker = self.owner:GetCondition("lumin_tracker") end
                if self.tracker and self.tracker:GetFullCharges() == 0 and card.owner == self.owner then
                    dmgt:AddDamage(self.graft:GetDef().bonus_damage, self.graft:GetDef().bonus_damage, self)
                end
            end
        },
    },

    trench_knife = 
    {
        event_handlers =
        {
            [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                local tracker = self.owner:GetCondition("lumin_tracker")
                if tracker and tracker:GetFullCharges() == 0 then
                    self.owner:AddCondition("DEFEND", self.graft:GetDef().defend_amt, self)
                    self.owner:AddCondition("RIPOSTE", self.graft:GetDef().riposte_amt, self)
                    battle:BroadcastEvent( BATTLE_EVENT.GRAFT_TRIGGERED, self.graft )
                end
            end
        },
    },
}

for i, id, data in sorted_pairs( battleCondition_merge ) do
    local modifier = Content.GetBattleCondition( id, data )
    for k,v in pairs(data) do
        modifier[k] = v
    end
end

local rookMod = Content.FindMod("ROOK")
if rookMod ~= nil then
    local onbattle = rookMod.OnBattleEvent
    rookMod.OnBattleEvent = function( self, screen, eventname, ... )
        onbattle( self, screen, eventname, ... )
		if eventname == "CONDITION_ADDED" then
			local fighter, condition, stacks, source = ...
			if condition.id == "lumin_tracker" then
                local charges, max_cells = condition:GetFullCharges()
                if screen.cell_ui then
                    screen.cell_ui:UpdateCells( charges, max_cells )
                end
			end
		end
    end
end
