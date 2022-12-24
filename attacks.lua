return function(mod) --pass modinit info

    local battle_defs = require "battle/battle_defs"
    local CARD_FLAGS = battle_defs.CARD_FLAGS
    local BATTLE_EVENT = battle_defs.BATTLE_EVENT

    --[[
        item: Shock-Box
        combos: Wide Jargon + Stacked Deck or Graft: Memory Lock

        - spend charge: if empty use overcharge?
    ]]

    local squeeze_post = function( self, battle, attack )
        local cards = battle:DrawCards(self.card_draw)
        local cost = 0
        for i,card in ipairs(cards) do
            local base = card.cost or 0
            local calc = battle:CalculateActionCost(card) or 0
            cost = cost + math.max(base, calc)
        end
        if cost > 0 then self.owner:AddCondition("SURGE", cost * self.multiplier, self) end
    end

    local attacks_merge =
    {
        -- sal's cards
        feint =
        {
            defend_amount = 5,
        },
        feint_plus =
        {
            defend_amount = 7,
        },
        feint_plus2d =
        {
            defend_amount = 8,
        },
        feint_plus2a =
        {
            defend_amount = 5,
        },
        feint_plus2b =
        {
            defend_amount = 5,
        },
        feint_plus2e =
        {
            defend_amount = 5,
        },
        feint_plus2f =
        {
            defend_amount = 5,
        },
        feint_plus2g =
        {
            defend_amount = 5,
        },
        feint_plus2h =
        {
            defend_amount = 5,
        },
        feint_plus2i =
        {
            defend_amount = 5,
        },

        spines =
        {
            cost = 1,
        },
        spines_plus =
        {
            cost = 1,
        },
        spines_plus2 =
        {
            cost = 0,
            defend_amount = 4,
            flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        },
        spines_plus2b = 
        {
            cost = 1,
        },
        spines_plus5c = 
        {
            series = "SAL",
            name = "Stone Spines",
            features = {DEFEND = 4},
        },
        
        into_the_night =
        {
            defend_amount = 2,
        },
        into_the_night_plus =
        {
            defend_amount = 3,
        },
        
        slippery =
        {
            defend_amt = 5,
        },
        slippery_plus =
        {
            defend_amt = 7,
        },
        slippery_plus2 =
        {
            defend_amt = 5,
        },

        stab_plus2b =
        {
            defend_amt = 3,
        },

        elbow_strike_plus2e =
        {
            defend_amt = 3,
        },

        chamber =
        {
            defend_amount = 5,
        },
        chamber_plus =
        {
            defend_amount = 7,
        },

        stringer =
        {
            defend_amount = 4,
        },
        stringer_plus =
        {
            defend_amount = 4,
            riposte_amount = 6,
        },
        stringer_plus2 =
        {
            defend_amount = 4,
            cost = 0,
        },
        stringer_plus2b =
        {
            defend_amount = 6,
        },
        stringer_plus2c =
        {
            defend_amount_alt = 6,
        },
        
        survival_reflexes =
        {
            defend_amt = 6,
        },        
        survival_reflexes_plus =
        {
            defend_amt = 6,
            desc_fn = function(self, fmt_str)
                return loc.format(fmt_str, self:CalculateDefendText( self.defend_amt ))
            end,
        },
        survival_reflexes_plus2 =
        {
            defend_amt = 6,
        },      
        survival_reflexes_plus2b =
        {
            defend_amt = 8,
        },      
        survival_reflexes_plus2c =
        {
            defend_amt = 6,
        },      
        survival_reflexes_plus2d =
        {
            defend_amt = 8,
        },      
        
        prediction =
        {
            base_defend = 4,
        },
        prediction_plus2 =
        {
            base_defend = 6,
        },
        
        wild_lunge_plus2 =
        {
            OnPostResolve = function( self, battle, attack )
                for i, hit in attack:Hits() do
                    if not hit.evaded then
                        hit.target:AddCondition("WOUND", 1, self)
                    end
                end
            end
        },

        --rook's cards
        crank =
        {
            defend_amt = 3,
        },
        crank_plus =
        {
            defend_amt = 3,
        },
        crank_plus2 =
        {
            defend_amt = 5,
        },
        crank_plus2b =
        {
            defend_amt = 3,
        },
        crank_plus2c =
        {
            defend_amt = 3,
        },

        hunker_down =
        {
            defend_amt = 4,
        },
        hunker_down_plus2a =
        {
            defend_amt = 6,
        },
        hunker_down_plus2b =
        {
            defend_amt = 4,
        },
        hunker_down_plus2c =
        {
            defend_amt = 4,
        },
        hunker_down_plus2d =
        {
            defend_amt = 4,
        },
        hunker_down_plus3b = --modded
        {
            defend_amt = 4,
            desc = "Apply {1} {DEFEND}.\n<#UPGRADE>Spend 1 {CHARGE}: Apply 3 additional {DEFEND}.</>",
            desc_fn = function(self, fmt_str)
                return loc.format(fmt_str, self:CalculateDefendText( self.defend_amt ))
            end,
        },

        spurs_plus2 =
        {
            defend_amt = 2,
        },

        shovel =
        {
            flags = CARD_FLAGS.MELEE,
        },
        shovel_plus2b =
        {
            flags = CARD_FLAGS.MELEE,
        },
        shovel_plus2c =
        {
            flags = CARD_FLAGS.MELEE,
        },
        shovel_plus2d =
        {
            flags = CARD_FLAGS.MELEE,
        },
        shovel_plus2e =
        {
            flags = CARD_FLAGS.MELEE | CARD_FLAGS.STICKY,
        },

        challenger =
        {
            defend_amt = 4,
        },
        challenger_plus =
        {
            defend_amt = 6,
        },

        casings =
        {
            cost = 2,
        },
        casings_plus =
        {
            cost = 1,
        },
        casings_plus2 =
        {
            cost = 2,
        },
        casings_plus2b =
        {
            cost = 2,
        },
        casings_plus2c =
        {
            cost = 2,
        },
        casings_plus2d =
        {
            cost = 2,
        },

        wounding_shot_plus5c =
        {
            series = "ROOK",
            name = "Pale Wounding Shot",
            pre_anim = "blast_pre",
            flavour = "'Take them apart one piece at a time.'",
            anim = "blast",
            post_anim = "blast_pst",
            desc = "Apply 1 {WOUND} per empty cell.",
            desc_fn = function ( self, fmt_str )
                return loc.format(fmt_str, self.lumin_charge or 1)
            end,
    
            cost = 1,
    
            flags = CARD_FLAGS.RANGED | CARD_FLAGS.UPGRADED,
            rarity = CARD_RARITY.UNCOMMON,
    
            min_damage = 3,
            max_damage = 4,
    
            wound_boost = 0,
    
            OnPostResolve = function( self, battle, attack )
                local tracker = self.owner:GetCondition("lumin_tracker")
                if tracker and tracker:GetEmptyCharges() > 0 then
                    attack:AddCondition("WOUND", tracker:GetEmptyCharges() + self.wound_boost, self)
                end
            end
        },
        
        dugout =
        {
            desc = "Apply {1} {DEFEND}.\nApply 1 {WIDE_OPEN} at the beginning of your next turn.",
            
            OnPostResolve = function( self, battle, attack)
                attack:AddCondition("DEFEND", self.defend_amt, self)
                attack:AddCondition("dugout", 1, self)
            end,
        },
        dugout_plus =
        {
            desc = "Apply <#UPGRADE>{1} {DEFEND}</>.\nApply 1 {WIDE_OPEN} at the beginning of your next turn.",
            
            OnPostResolve = function( self, battle, attack)
                attack:AddCondition("DEFEND", self.defend_amt, self)
                attack:AddCondition("dugout", 1, self)
            end,
        },
        dugout_plus2 =
        {
            desc = "Apply {1} {DEFEND}.\nApply 1 <#UPGRADE>{EXPOSED}</> at the beginning of your next turn.",

            OnPostResolve = function( self, battle, attack)
                attack:AddCondition("DEFEND", self.defend_amt, self)
                attack:AddCondition("dugout_plus2", 1, self)
            end,
        },

        accelerant = 
        {
            desc = "Apply {1} {SCORCHED} and {2} {BURN} to all enemies.",
            cost = 1,
            scorched_amt = 2,
            burn_amt = 2,
            flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
            target_mod = TARGET_MOD.TEAM,
        },    
        accelerant_plus =
        {
            name = "Boosted Accelerant",
            desc = "Apply <#UPGRADE>{1} {SCORCHED}</> and <#UPGRADE>{2} {BURN}</> to all enemies.",
            scorched_amt = 3,
            burn_amt = 3,
            target_mod = TARGET_MOD.TEAM,
        },
        accelerant_plus2 = 
        {
            name = "Focused Accelerant",
            desc = "Apply <#UPGRADE>{1} {SCORCHED}</> and <#UPGRADE>{2} {BURN}</> to <#DOWNGRADE>an enemy.</>",
            scorched_amt = 3,
            burn_amt = 6,
            target_mod = TARGET_MOD.SINGLE,
        },
        accelerant_plus2b =
        {
            name = "Promoted Accelerant",
            desc = "Apply {1} {SCORCHED} and <#UPGRADE>{2} {BURN}</> to all enemies.",
            burn_amt = 4,
            target_mod = TARGET_MOD.TEAM,
        },
        accelerant_plus2c =
        {
            name = "Pale Accelerant",
            desc = "Apply {1} {SCORCHED} and {2} {BURN} to all enemies.",
            cost = 0,
            target_mod = TARGET_MOD.TEAM,
        },
        accelerant_plus2d =
        {
            name = "Initial Accelerant",
            desc = "Apply {1} {SCORCHED} and {2} {BURN} to all enemies.",
            flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.AMBUSH,
            target_mod = TARGET_MOD.TEAM,
        },
        accelerant_plus2e =
        {
            name = "Enduring Accelerant",
            desc = "Apply {1} {SCORCHED} and {2} {BURN} to all enemies.",
            flags = CARD_FLAGS.SKILL,
            scorched_amt = 2,
            target_mod = TARGET_MOD.TEAM,
        },
        accelerant_plus2f =
        {
            name = "Twisted Accelerant",
            desc = "Apply <#DOWNGRADE>{1} {SCORCHED}</> and <#UPGRADE>{2} {BURN}</> to all enemies.",
            scorched_amt = 1,
            burn_amt = 5,
            target_mod = TARGET_MOD.TEAM,
        },

        focused_strike =
        {
            concentration_amt = 3,
    
            OnPostResolve = function( self, battle, attack )
            end,
            OnPreResolve = function( self, battle, attack )
                local tracker = self.owner:GetCondition("lumin_tracker")
                if tracker and tracker:GetCharges() == 0 then
                    self.owner:AddCondition("CONCENTRATION", self.concentration_amt, self)
                end
            end,
            -- event_priorities =
            -- {
            --     [ BATTLE_EVENT.ON_HIT ] = 5,
            -- },
            -- event_handlers =
            -- {
            --     [ BATTLE_EVENT.ON_HIT ] = function( self, battle, attack, hit )
            --     end,
            -- },
        },    
        focused_strike_plus =
        {   
            OnPostResolve = function( self, battle, attack )
            end,
            OnPreResolve = function( self, battle, attack )
                local tracker = self.owner:GetCondition("lumin_tracker")
                if tracker and tracker:GetCharges() == 0 then
                    self.owner:AddCondition("CONCENTRATION", self.concentration_amt, self)
                end
            end,
        },    
        focused_strike_plus2 =
        {
            OnPostResolve = function( self, battle, attack )
            end,
            OnPreResolve = function( self, battle, attack )
                local tracker = self.owner:GetCondition("lumin_tracker")
                if tracker and tracker:GetCharges() == 0 then
                    self.owner:AddCondition("CONCENTRATION", self.concentration_amt, self)
                end
            end,
        },

        squeeze = 
        {
            OnPostResolve = squeeze_post
        },
        squeeze_plus =
        {
            OnPostResolve = squeeze_post
        },    
        squeeze_plus2 =
        {
            OnPostResolve = squeeze_post
        },

        fixed_plus =
        {
            fixed_amt = 4,
        },


        --smith's cards
        toughen_up =
        {
            defend_amt = 4,
        },
        toughen_up_plus2a =
        {
            defend_amt = 4,
        },
        toughen_up_plus2b =
        {
            defend_amt = 6,
        },
        toughen_up_plus2c =
        {
            defend_amt = 4,
        },
        toughen_up_plus2d =
        {
            defend_amt = 3,
        },
        toughen_up_plus2e =
        {
            defend_amt = 4,
        },
        toughen_up_plus3a =
        {
            defend_amt = 4,
        },

        improvise_murder_bay_blaster_upgraded2d =
        {		
            features =
            {
            },
        },

        mean_streak_plus5c =
        {
            series = "SMITH",
            name = "Lasting Mean Streak",
            desc = "{THRESHOLD} {1}: Reduce all <b>Thresholds</> by 1 for the rest of this <#UPGRADE>battle</>.",
            desc_fn = function( self, fmt_str )
                return loc.format( fmt_str, self:CalculateThresholdText(self))
            end,
            flags = CARD_FLAGS.MELEE | CARD_FLAGS.UPGRADED,
    
            ThresholdEffect = function( self, battle, attack )
                self.owner:AddCondition("mean_streak_plus5c", 1, self)
            end,
    
            condition =
            {
                hidden = true,
    
                event_handlers =
                {
                    [ BATTLE_EVENT.CALC_THRESHOLD ] = function( self, threshold, card )
                        if card.owner == self.owner then
                            threshold:AddValue(-self.stacks, self)
                        end
                    end,
                },
            },
        },

        hammer_swing_IV_upgraded2c =
        {
            desc = "Apply {1} {TRAUMA}.\nAttack twice.\n{CHAIN}",
            desc_fn = function( self, fmt_str )
                return loc.format(fmt_str, self.trauma_amt)
            end,

            trauma_amt = 2,

            OnPostResolve = function( self, battle, attack )
                attack:AddCondition("TRAUMA", self.trauma_amt, self)
            end,
        },
        hammer_swing_IV_upgraded2b =
        {
            desc = "Apply {1} {TRAUMA}.\nAttack twice.\n{CHAIN}",
            desc_fn = function( self, fmt_str )
                return loc.format(fmt_str, self.trauma_amt)
            end,

            trauma_amt = 2,

            OnPostResolve = function( self, battle, attack )
                attack:AddCondition("TRAUMA", self.trauma_amt, self)
            end,
        },

        -- item/npc/status cards
        zyns_razor =
        {
            flags = CARD_FLAGS.ITEM | CARD_FLAGS.UNPLAYABLE | CARD_FLAGS.SKILL | CARD_FLAGS.REPLENISH,
        },

        auxiliary =
        {
            flags = CARD_FLAGS.UNPLAYABLE | CARD_FLAGS.REPLENISH | CARD_FLAGS.ITEM,
        },

        makeshift_dagger_plus = 
        {
            desc = "Apply <#UPGRADE>{1}</> {WOUND}.\n50% chance to {EXPEND} this card.",
            OnPostResolve = function( self, battle, attack )
                attack:AddCondition("WOUND", self.wound_amt, self)
                if math.random() < .5 then
                    battle:ExpendCard( self )
                end
            end
        },

        brain_gills2 =
        {
            series = CARD_SERIES.GENERAL,
            icon = "FumisDeck:textures/brain_gills2.png",
            name = "Memory Implant",
            desc = "The next card played this turn gains 3 additional XP.",
            flavour = "'What doesn't kill you makes you smarter.'",
            desc_fn = function( self, fmt_str )
                return loc.format( fmt_str, self.xp_gain )
            end,
    
            item_tags = ITEM_TAGS.UTILITY | ITEM_TAGS.COMBAT,
            flags = CARD_FLAGS.EXPEND | CARD_FLAGS.REPLENISH | CARD_FLAGS.ITEM,
            rarity = CARD_RARITY.UNCOMMON,
    
            cost = 0,
            xp_gain = 3,
            target_type = TARGET_TYPE.SELF,
    
            OnPostResolve = function( self, minigame )
                local local_condition = self.owner:AddCondition("brain_gills2", 1, self)
                local_condition.owner_card = self
                local_condition.xp_gain = self.xp_gain
            end,
    
            condition =
            {
                hidden = true,
    
                event_handlers =
                {
                    [ BATTLE_EVENT.POST_RESOLVE ] = function( self, battle, attack )
                        local card = attack.card
                        if attack.attacker == self.owner and card ~= self.owner_card then
                            if not card:IsHatched() then
                                card:AddXP( self.xp_gain, true )
                            end
                            self.owner:RemoveCondition( self.id, 1 )
                        end
                    end,
    
                    [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                        self.owner:RemoveCondition( self.id, 1 )
                    end
                }
            }
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

    -- shops
    CARD_SHOP_DEFS["GROG_N_DOG_ITEMS"] = function(stock)
        AddShopItems(stock, 4, {"hip_flask", "liquid_courage", "tincture", "vial_of_slurry", "salve", "adrenaline_shot", "brain_gills", "brain_gills2"})
    end

    local bcard = Content.GetBattleCard( "damnation" )
    bcard["condition"]["damage_amt"] = 40
    bcard.flags = CARD_FLAGS.SKILL

    -- local autodiscard = { "current", "wave", "riptide", "shear", "whirl", "twist", "melt" } -- TODO: still does not work with full hand
    -- for i, card in pairs(autodiscard) do
    --     local event = Content.GetBattleCard( card ).event_handlers
    --     local event_old = event[BATTLE_EVENT.DRAW_CARD]
    --     event[BATTLE_EVENT.DRAW_CARD] = function( self, battle, card, start_of_turn )
    --         event_old( self, battle, card, start_of_turn )
    --         if card == self then self.engine:DiscardCard( self ) end        
    --         --if card == self then battle:DealCard( self, battle:GetDiscardDeck()) end
    --     end
    -- end

    local battleCondition_merge = 
    {
        malfunctioning_charge_cells =
        {
            event_handlers = 
            {
                [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                    local tracker = self.owner:GetCondition("lumin_tracker")
                    if self.applier:IsActive() and tracker and tracker:GetFullCharges() > 0 then
                        self.owner:ApplyDamage(tracker:GetFullCharges() * self.damage[math.min(GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1, #self.damage)], nil, nil, nil, {"lumin"})
                    end
                    self.owner:RemoveCondition(self.id, 1, self)
                end
            },
        },

        fixed =
        {
            desc = "Whenever this target is hit, you gain <#HILITE>{1} {DEFEND}</>. At the start of {2}'s turn, halve <b>Fixed</>.",
            event_handlers =
            {
                [ BATTLE_EVENT.ON_HIT ] = function( self, battle, attack, hit )
                    if hit.target == self.owner then
                        battle:GetPlayerFighter():AddCondition("DEFEND", self.stacks, self)
                    end
                end,
                [ BATTLE_EVENT.BEGIN_TURN ] = function( self, fighter )
                    if fighter == self.owner then
                        local decay_stacks = math.max( 0, math.round(self.stacks * 0.5) )
                        self.owner:RemoveCondition( self.id, decay_stacks, self )
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

    -- excluded surrendered enemies from random targets
    local BattleEngine = BattleEngine
    function BattleEngine:CollectAllTargets( card, t, max_count )
        max_count = max_count or math.huge
        t = t or {}
    
        for i, fighter in self:ActiveFighters() do
            if card.owner:CanTarget( card, fighter ) then
                local isRandom = (card.target_mod == TARGET_MOD.RANDOM1 or card.target_mod == TARGET_MOD.RANDOM2 or card.target_mod == TARGET_MOD.RANDOM3) 
                if not isRandom or fighter:GetStatus() ~= FIGHT_STATUS.SURRENDER then
                    table.insert( t, fighter )
                    if #t >= max_count then
                        return t
                    end
                end
            end
        end
    
        return t
    end

end