return function(mod) --pass modinit info

    local negotiation_defs = require "negotiation/negotiation_defs"
    local CARD_FLAGS = negotiation_defs.CARD_FLAGS
    local EVENT = negotiation_defs.EVENT

    local cards_merge =
    {
        -- sal's Cards
        deflection =
        {
            composure_amt = 4,
        },
        deflection_plus2b =
        {
            composure_amt = 5,
        },
        deflection_plus2c =
        {
            composure_amt = 4,
        },
        deflection_plus2f =
        {
            composure_amt = 7,
        },
        deflection_plus3b =
        {
            composure_amt = 4,
        },
        deflection_plus3c =
        {
            composure_amt = 4,
        },

        invective =
        {
            desc = "Create {HEATED 1}\n{EVOKE}: Play {1} Hostility cards in a single turn. {2}",        
            OnPostResolve = function( self, minigame, targets )
                self.negotiator:CreateModifier("HEATED", 1, self)
            end,
        },
        invective_plus = 
        {
            desc = "Create {HEATED 1} <#UPGRADE>with 2 stacks</>\n{EVOKE}: Play {1} Hostility cards in a single turn. {2}",
            OnPostResolve = function( self, minigame, targets )
                self.negotiator:CreateModifier("HEATED", 2, self)
            end,
        },    
        invective_plus2 =
        {
            desc = "Create {HEATED 1}\n{EVOKE}: Play {1} Hostility cards in a single turn. {2}",
            OnPostResolve = function( self, minigame, targets )
                self.negotiator:CreateModifier("HEATED", 1, self)
            end,
        },	
        invective_plus2b =
        {
            desc = "Create {HEATED 1}\n{EVOKE}: Play <#UPGRADE>{1}</> Hostility cards in a single turn. {2}",
            OnPostResolve = function( self, minigame, targets )
                self.negotiator:CreateModifier("HEATED", 1, self)
            end,
        },
        invective_plus2c =
        {
            desc = "Create {HEATED 1}\n{EVOKE}: Play {1} Hostility cards in a single turn. {2}",
            OnPostResolve = function( self, minigame, targets )
                self.negotiator:CreateModifier("HEATED", 1, self)
            end,
        },
        invective_plus2d =
        {
            desc = "Create {HEATED 1} <#UPGRADE>with 3 stacks</>\n{EVOKE}: Play <#DOWNGRADE>{1}</> Hostility cards in a single turn. {2}",
            OnPostResolve = function( self, minigame, targets )
                self.negotiator:CreateModifier("HEATED", 3, self)
            end,
        },
        

        -- rook's cards
        rationale =
        {
            composure_amt = 4,
        },
        rationale_plus2a =
        {
            composure_amt = 5,
        },
        rationale_plus2b =
        {
            composure_amt = 4,
        },
        rationale_plus2d =
        {
            composure_amt = 4,
        },
        rationale_plus2e =
        {
            composure_amt = 4,
        },

        rant_plus5c =
        {
            series = "ROOK",
            name = "Sticky Rant",
            flags = CARD_FLAGS.HOSTILE | CARD_FLAGS.STICKY | CARD_FLAGS.UPGRADED,
        },

        gab_plus5c =
        {
            series = "ROOK",
            name = "Enduring Gab",    
            flags = CARD_FLAGS.MANIPULATE | CARD_FLAGS.UNPLAYABLE | CARD_FLAGS.UPGRADED,
        },

        
        spin_plus2b = -- fixes count not increased by 1
        {
            OnPostResolve = function( self, minigame, targets )
                for i,target in ipairs(targets) do
                    minigame:ApplyPersuasion( self, target, self.min, self.max )
                end

                local coin = self.negotiator:FindModifier("LUCKY_COIN")
                local count = 1
                if self.damage_dealt then
                    count = count + self.damage_dealt
                end
                if coin then
                    for i = 1, count do
                        coin:Gamble(self)
                    end
                end
                self.damage_dealt = nil
            end,
        },

        -- smith's cards
        bewilder =
        {
            composure_amt = 4,
        },
        bewilder_plus2a =
        {
            composure_amt = 5,
        },
        bewilder_plus2b =
        {
            composure_amt = 4,
        },
        bewilder_plus2f =
        {
            composure_amt = 4,
        },
        
        notion =
        {
            desc = "Gain 2 {DOMINANCE}.",
            OnPostResolve = function( self, minigame )
                self.negotiator:AddModifier( "DOMINANCE", self.stacks, self )
            end,
        },

        -- item/npc/status cards
        
        kickback =
        {
            flags = CARD_FLAGS.STATUS | CARD_FLAGS.BURNOUT,
        },

        brain_gills = 
        {
            --name = "Brain Gills (Negotiation)",
        },

        -- from mods
        improvise_shifty_upgraded2d =
        {
            cost = 0,
        },
        improvise_sleight_upgraded2d =
        {
            cost = 0,
        },
        improvise_reversal_upgraded2d =
        {
            cost = 1,
            flags = CARD_FLAGS.MANIPULATE | CARD_FLAGS.REPLENISH | CARD_FLAGS.STICKY,
        },
        improvise_gruff_upgraded2d =
        {
            desc = "{INCEPT} 2 {FLUSTERED}.",
            OnPostResolve = function( self, minigame, targets )
                self.anti_negotiator:InceptModifier("FLUSTERED", 2 , self )
            end
        },
        improvise_carry_over_upgraded2d =
        {
            cost = 1,
            flags = CARD_FLAGS.MANIPULATE | CARD_FLAGS.REPLENISH,            
            features =
            {
                FREE_ACTION = 2,
            },
        },
    }
    

    for i, id, data in sorted_pairs(cards_merge) do
        local card = Content.GetNegotiationCard( id )

        -- if card doesn't exist and series is defined add new card
        if card == nil and data.series ~= nil then  -- "SMITH" "SAL" "ROOK"
            Content.AddNegotiationCard( id, data )
        elseif card == nil then
            print("card missing! " .. id)
        else -- otherwise edit existing
            for k,v in pairs(data) do
                if k == "OnPostResolve" and v == false then
                    card[k] = nil
                else
                    card[k] = v
                end
            end
        end
    end

    local modifier_merge = 
    {
        DIVERSION = 
        {
            desc = "This argument gains <#HILITE>{1}</> resolve every time you {GAMBLE}. This argument must be targeted before any other arguments.",    
            event_handlers =
            {
                [ EVENT.GAMBLE ] = function( self, result, source )                    
                    self:ModifyResolve(self.stacks, self)
                end
            },
        },

        LUCKY_COIN = 
        {
            Reverse = function( self, source )
                if self.current_status == "HEADS" then
                    self.current_status = "SNAILS"
                    self:UpdateConditions(false)
                else
                    self.current_status = "HEADS"
                    self:UpdateConditions(true)
                end
                self.engine:BroadcastEvent( EVENT.GAMBLE, self.current_status, source)
            end,
            SetCoin = function( self, side, source )
                if side == nil then
                    local cards = {
                        Negotiation.Card( "coin_heads", self.owner ),
                        Negotiation.Card( "coin_snails", self.owner ),
                    }
                    local pick = self.engine:ImproviseCards( cards, 1, nil, nil, nil, self )[1]
                    side = pick and pick.side or "HEADS"
                    if pick then self.engine:ExpendCard(pick) end
                end
                if side == "HEADS" then
                    self.current_status = "HEADS"
                    self:UpdateConditions(true)
                else
                    self.current_status = "SNAILS"
                    self:UpdateConditions(false)
                end
                self.engine:BroadcastEvent( EVENT.GAMBLE, self.current_status, source)
                return side
            end,
        },
    }

    for i, id, data in sorted_pairs(modifier_merge) do
        local modifier = Content.GetNegotiationModifier( id )
        if modifier ~= nil then
            for k,v in pairs(data) do
                modifier[k] = v
            end
        end
    end

end