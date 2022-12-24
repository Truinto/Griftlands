local version = "1.0.0"
local alias = "FumisDeck"
local title = "Fumi's Deck"
local description = "Tweaks and new cards"
local image = "preview.png"

local function OnLoad( mod )
	self_dir = alias .. ":"
	local content_dir = "content/"
	local LOAD_FILE_ORDER =
	{
		"attacks",
		"negotiation",
		"grafts",
		"console",
		"overcharge"
		-- content_dir .. "sal_actions",
	}
	for k, filepath in ipairs(LOAD_FILE_ORDER) do
		local ret = require(self_dir .. filepath)
		if ret and type(ret) == "function" then --deferring certain code so that GetModSettings can have mod.id
			ret(mod)
		end
	end

	DEFAULT_ADVANCEMENT[7][ADVANCEMENT_OPTION.METTLE_OFF] = nil
end

local function OnNewGame( mod, game_state )
    game_state:RequireMod(mod)
end

local MOD_OPTIONS =
{
    -- {
        -- title = "placeholder",
        -- spinner = true,
        -- key = "key_here",
        -- default_value = 1,
        -- values =
        -- {
            -- { name="DISABLED", desc="", data = 0 },
            -- { name="ENABLED", desc="", data = 1 },
        -- }
    -- },
}

return
{
	version = version,
	alias = alias,
	title = title,
	description = description,
	previewImagePath = image,
	
	OnNewGame = OnNewGame,
	OnLoad = OnLoad,
    load_after = 
	{
		"MoreUpgrades"
	},
	
	-- OnResumeGame = { },
	-- OnPreLoad = { },
	-- load_before = { },
    -- mod_options = MOD_OPTIONS,
}