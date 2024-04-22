--- STEAMODDED HEADER
--- MOD_NAME: Enhance API
--- MOD_ID: EnhanceAPI
--- MOD_AUTHOR: [Numbuh214]
--- MOD_DESCRIPTION: Grants the ability to add custom enhancements to the game.
--- PRIORITY: -9001
----------------------------------------------
------------MOD CODE -------------------------
function SMODS.INIT.EnhanceAPI()
  Enhancements = {}
  E_ROWS = 2
  E_COLS = 5
  sendInfoMessage("Loaded!", 'EnhanceAPI')
end

function newEnhancement(_t)
  local v = {
    name = _t.name,
	slug = _t.slug,
	sprite = _t.sprite or _t.name,
	config = _t.config,
	pos = _t.pos,
	loc_txt = _t.loc_txt,
	effect = _t.effect or _t.name,
	label = _t.label or _t.name,
	order = #Enhancements+10,
  }
  v.mod_name = SMODS._MOD_NAME
  v.badge_colour = SMODS._BADGE_COLOUR
  v.key = v.slug
  if not v.config.extra then v.config.extra = {} end
  v.config.extra.playing_card = _t.playing_card
  v.config.extra.display_face = _t.display_face
  G.P_CENTERS[v.slug] = v
  G.P_CENTER_POOLS['Enhanced'][v.order-1] = v
  G.localization.descriptions['Enhanced'][v.slug]= {
    name = v.name,
    text = _t.loc_txt
  }
  sendInfoMessage("Registered Enhancement " .. v.name .. " with the slug " .. v.slug .. " at ID " .. v.order .. ".", 'EnhanceAPI')
  table.insert(Enhancements, v)
end

function getEnhancement(name)
    for k,v in pairs(Enhancements) do
      if v.name == name then
	    return value
      end
    end
    return nil
end

function get_best_table_number(value, rows)
  local composites = {2, 3, 4, 5, 6, 8, 9, 10, 12, 14, 15}
  for _, v in ipairs(composites) do
    if v >= value and v % rows == 0 then
      return v
    end
  end
  return 15
end

local create_UIBox_your_collection_enhancements_ref = create_UIBox_your_collection_enhancements
function create_UIBox_your_collection_enhancements(exit)
  local deck_tables = {}
  local rows, cols = 0, 0
  local page = 0

  rows = E_ROWS
  cols = E_COLS
  local count = math.min(cols * rows, #G.P_CENTER_POOLS["Enhanced"])
  local table_amount = get_best_table_number(count, rows)
  --sendDebugMessage("Best is "..table_amount.."...?")
  G.your_collection = {}
  for j = 1, rows do
    G.your_collection[j] = CardArea(
      G.ROOM.T.x + 0.2*G.ROOM.T.w/rows,0.4*G.ROOM.T.h,
      4.65*G.CARD_W,
      1.23*G.CARD_H,
      {card_limit = cols, type = 'title', highlight_limit = 0})
    table.insert(deck_tables,
    {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
      {n=G.UIT.O, config={object = G.your_collection[j]}}
    }}
    )
  end
  --sendDebugMessage("There are "..#G.P_CENTER_POOLS["Enhanced"].." enhancements.")
  local offset = 0
  for j = 1, rows do
    for i = 1, cols do
	  if count%rows > 0 and j <= count%rows and i == cols then
	    offset = offset + 1
	    break
	  end
      if i+(j-1)*cols-offset > count + (count % rows) then
        --sendDebugMessage("There are only "..#G.P_CENTER_POOLS[#Enhancements+8].." enhancements.")
        break
      end
      local center = G.P_CENTER_POOLS["Enhanced"][i+(j-1)*cols-offset+(cols * rows * page)]

      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/rows*1.75, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
      G.your_collection[j]:emplace(card)
      --sendDebugMessage(center.name.." added.")
    end
  end

  local enhance_options = {}

  local t = create_UIBox_generic_options({ infotip = localize('ml_edition_seal_enhancement_explanation'), back_func = exit or 'your_collection', snap_back = true, contents = {
            {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
          }})

  if #G.P_CENTER_POOLS["Enhanced"] > rows * cols then
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Enhanced/(rows*cols)) do
      table.insert(enhance_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Enhanced/(rows*cols))))
    end
    t = create_UIBox_generic_options({ infotip = localize('ml_edition_seal_enhancement_explanation'), back_func = exit or 'your_collection', snap_back = true, contents = {
            {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
			{n=G.UIT.R, config={align = "cm"}, nodes={
                    create_option_cycle({options = enhance_options, w = 4.5, cycle_shoulders = true, opt_callback = 'your_collection_enhancements_page', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, r = rows, c = cols, colour = G.C.RED, no_pips = true})
                  }}
          }})
  end
  return t
end

G.FUNCS.your_collection_enhancements_page = function(args)
  if not args or not args.cycle_config then return end
  local rows = E_ROWS
  local cols = E_COLS
  local page = args.cycle_config.current_option
  if page > math.ceil(#G.P_CENTER_POOLS.Enhanced/(rows * cols)) then
    page = page - math.ceil(#G.P_CENTER_POOLS.Enhanced/(rows * cols))
  end
  sendDebugMessage(page.." / "..math.ceil(#G.P_CENTER_POOLS.Enhanced/(rows * cols)))
  local count = rows * cols
  local offset = (rows * cols)*(page-1)
  sendDebugMessage("Page offset: "..tostring(offset))

  for j=1, #G.your_collection do
    for i=#G.your_collection[j].cards,1,-1 do
	  if G.your_collection[j] ~= nil then
	    local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
        c:remove()
        c = nil
	  end
	end
  end

  for j = 1, rows do
    for i = 1, cols do
	  if count%rows > 0 and i <= count%rows and j == cols then
	    offset = offset - 1
	    break
	  end
	  local idx = i+(j-1)*cols+offset
      if idx > #G.P_CENTER_POOLS["Enhanced"] then
		sendDebugMessage("End of Enhancement table.")
	    return
	  end
	  sendDebugMessage("Loading Enhancement "..tostring(idx))
      local center = G.P_CENTER_POOLS["Enhanced"][idx]
	  sendDebugMessage("Enhancement "..((center and "loaded") or "did not load").." successfuly.")
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
      card:start_materialize(nil, i>1 or j>1)
      G.your_collection[j]:emplace(card)
    end
  end
  sendDebugMessage("All Enhancements of Page "..page.." loaded.")
end

local setability_ref = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
  for _, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
    if v.key == center.key and self.ability then
        self.ability.extra = self.ability.extra or { }
    end
  end
  return setability_ref(self, center, initial, delay_sprites)
end

local setsprites_ref = Card.set_sprites
function Card:set_sprites(_center, _front)
	local enhancement = false
	if _center and _center.key then
	  for k, v in pairs(Enhancements) do
	    if v.key == _center.key then
		  enhancement = true
		  break
	    end
      end
	end
    if enhancement then
	  if self.ability and self.ability.extra.display_face then
	    self.children.front = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["cards_"..(G.SETTINGS.colourblind_option and 2 or 1)], self.config.card.pos)
		sendDebugMessage("G.ASSET_ATLAS["..self.config.center_key.."] is "..tostring(G.ASSET_ATLAS[self.config.center_key]))
		local pos = G.P_CENTERS[self.config.center_key].pos
        self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[self.config.center_key], pos or {x=0,y=0})
	  else
        self.children.front = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[self.config.center_key], self.config.card.pos)
        self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS['centers'], {x = 1, y = 0})
        self.children.center:set_sprite_pos({x = 1, y = 0})
	  end
      align_layer(self, self.children.front)
      align_layer(self, self.children.center)
      if not self.children.back then
        self.children.back = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["centers"], self.params.bypass_back or (self.playing_card and G.GAME[self.back].pos or G.P_CENTERS['b_red'].pos))
        align_layer(self, self.children.back)
      end
	else
	  if _center and _center.key then
	    for i=1, 8 do
		  local v = G.P_CENTER_POOLS["Enhanced"][i]
		  --sendDebugMessage("("..v.key.." = ".._center.key..") ...?")
		  if v.key == _center.key and v.key ~= "m_stone" and self.children.front ~= nil then
			_front = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["cards_"..(G.SETTINGS.colourblind_option and 2 or 1)], self.config.card.pos) --reset for vanilla enhancements
			break
		  end
		end
	  end
	  return setsprites_ref(self, _center, _front)
    end
end

function align_layer(card, v)
    if v ~= nil then
      v.states.hover = card.states.hover
      v.states.click = card.states.click
      v.states.drag = card.states.drag
      v.states.collide.can = false
      v:set_role({major = card, role_type = 'Glued', draw_major = card})
	end
end

local copy_ref = copy_card
function copy_card(other, new_card, card_scale, playing_card, strip_edition)
   local postage = copy_ref(other, new_card, card_scale, playing_card, strip_edition)
   postage:set_sprites(postage.config.center, nil)
   return postage
end

local card_h_popup_ref = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
	local t = card_h_popup_ref(card)
	local badges = t.nodes[1].nodes[1].nodes[1].nodes[3]
	--sendDebugMessage("Looking for badges...")
	badges = badges and badges.nodes or nil
	if card.config then
	  if card.config.center then
	    if card.config.center.key then
	      for k, v in pairs(Enhancements) do
		    if v.slug == card.config.center.key then
			  local gen = generate_fake_badges(card, {})
			  for k,v in pairs(gen) do
			    badges[#badges + 1] = create_badge(localize(v, "labels"), get_badge_colour(v))
			  end
		      badges[1] = create_badge(card.ability.name, G.C.SECONDARY_SET.Enhanced, nil, 1.2)
			  local mod_name = Enhancements[k].mod_name
			  mod_name = mod_name:sub(1, 16)
			  local len = string.len(mod_name)
			  badges[#badges + 1] = create_badge(mod_name, Enhancements[k].badge_colour or G.C.UI.BACKGROUND_INACTIVE, nil,
				len <= 6 and 0.9 or 0.9 - 0.02 * (len - 6))
			  break
	        end
		  end
	    end
	  end
	end
	return t
end

local generate_UIBox_ability_table_ref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table()
    local fl_vars = {
	  new_enhance = nil
	}
    for k, v in pairs(Enhancements) do
	  if v.name == self.ability.name then
	    fl_vars.new_enhance = v.slug
	    break
	  end
	end
	if not fl_vars or fl_vars.new_enhance == nil then
	  real_ui_table = generate_UIBox_ability_table_ref(self)
	  return real_ui_table
	else
	  sendDebugMessage("Enhancement is "..tostring(fl_vars.new_enhance))
	  fl_vars.nominal_chips = self.base.nominal > 0 and self.base.nominal or nil
      fl_vars.bonus_chips = (self.ability.bonus + (self.ability.perma_bonus or 0)) > 0 and (self.ability.bonus + (self.ability.perma_bonus or 0)) or nil
      local fake_card = Card(-100, -100, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS['m_mult'])
      local fake_ui_table = generate_UIBox_ability_table_ref(fake_card)
	  fake_ui_table.main = fake_localize(self.config.center, fl_vars, fake_ui_table.main[1][1].config.scale)
	  fake_ui_table.name = {}
	  if (self.ability.set == 'Default' or self.ability.set == 'Enhanced') and self.ability.extra.playing_card == true and fake_ui_table.name ~= nil and fake_ui_table:len() > 0 then
	    fl_vars.value = self.base.value
	    fl_vars.suit = self.base.suit
	    fl_vars.colour = self.base.colour
	    localize{type = 'other', key = 'playing_card', set = 'Other', nodes = full_UI_table.name, vars = {localize(fl_vars.value, 'ranks') or fl_vars.value, localize(fl_vars.suit, 'suits_plural'), colours = {fl_vars.colour}}}
	  end
      fake_card:start_dissolve({G.C.BLACK},true,0.0,true)
	  return fake_ui_table
	end
end

local generate_card_ui_ref = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end)
	if specific_vars ~= nil and specific_vars.new_enhance == true then
      full_UI_table = generate_card_ui_ref(G.P_CENTERS['m_mult'], nil, {420}, card_type, badges, hide_desc, main_start, main_end)
	  if specific_vars.playing_card then
		full_UI_table.name = {}
		localize{type = 'other', key = 'playing_card', set = 'Other', nodes = full_UI_table.name, vars = {localize(specific_vars.value, 'ranks'), localize(specific_vars.suit, 'suits_plural'), colours = {specific_vars.colour}}}
		full_UI_table.name = full_UI_table.name[1]
      end
      return full_UI_table
	end
	return generate_card_ui_ref(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end)
end

function print_table(_table, idx)
  idx = idx or 0
  local line = ""
  local spc = ""
  for i = 1, idx do
    spc = " "..spc
  end
  if tostring(_table) == 'nil' then
    sendDebugMessage("nil value.")
    return
  end
  if type(_table) == 'table' then
    for k, v in pairs(_table) do
      if type(v) == 'table' then
	    sendDebugMessage(spc..k..":")
	    print_table(v, idx+1)
	  else
        sendDebugMessage(spc..k..": "..tostring(v))
	  end
    end
  end
end

function generate_fake_badges(card, loc_vars)
    local badges = {
    }
    if card.edition then
        if card.edition.type == 'negative' and card.ability.consumeable then
            badges[(#badges or 0) + 1] = 'negative_consumable'
        else
            badges[(#badges or 0) + 1] = (card.edition.type == 'holo' and 'holographic' or card.edition.type)
        end
    end
    if card.seal then badges[(#badges or 0) + 1] = string.lower(card.seal)..'_seal' end
    if card.ability.eternal then badges[(#badges or 0) + 1] = 'eternal' end
    if card.ability.perishable then
        loc_vars = loc_vars or {}; loc_vars.perish_tally=card.ability.perish_tally
        badges[(#badges or 0) + 1] = 'perishable'
    end
    if card.ability.rental then badges[(#badges or 0) + 1] = 'rental' end
    if card.pinned then badges[(#badges or 0) + 1] = 'pinned_left' end

    if card.sticker then loc_vars = loc_vars or {}; loc_vars.sticker=card.sticker end

    return badges
end

function fake_localize(_c, loc_vars, def_scale)
	-- local loc_text = ""
	-- print_table(loc_vars)
	-- if loc_vars.new_enhance ~= nil then
	  --sendDebugMessage(loc_vars.new_enhance)
      --loc_text = G.localization.descriptions["Enhanced"][loc_vars.new_enhance].text
	-- else
      loc_text = G.localization.descriptions["Enhanced"][_c.key].text
	  print_table(loc_text)
	-- end
    --sendDebugMessage("G.localization.descriptions[".._c.set.."][".._c.key.."].text has "..#loc_text.." lines...?")
    --local times = (#loc_vars == 1 and "once") or (#loc_vars == 2 and "twice") or #loc_vars.." times"
    --sendDebugMessage("Should go through "..#loc_text.." lines "..times)
    --sendDebugMessage("loc_def length is "..#loc_text)
    --sendDebugMessage("table.main length is "..(#full_UI_table.main or 0).." x "..(#full_UI_table.main[1] or 0))
    def_scale  = def_scale or 0.32
    --sendDebugMessage("---------------------------------------------")

    --sendDebugMessage("---------------------------------------------")

    local default = {}
    local formatting = {{}}

    --replace loc_var values
    for j=1, #loc_text do
      if type(loc_text[j][1]) == table then break
      else
        default[j] = loc_text[j]
      end
      for i=1, #loc_vars do
        --sendDebugMessage(j..": ")
		default[j] = default[j]:gsub("#"..i.."#",loc_vars[i])
		--sendDebugMessage(" "..default[j])
        end
    end

	if loc_vars.bonus_chips then
	  table.insert(loc_text, 1, "{C:chips}+"..loc_vars.bonus_chips.."{} bonus chips")
	end

    --print_table(formatting)

    --gather other formatting
    --sendDebugMessage("---------------------------------------------")
    --sendDebugMessage("---------------------------------------------")
    --sendDebugMessage("Adjusting colouring and scaling...")
    --sendDebugMessage("---------------------------------------------")
    for i=1, #default do
      --sendDebugMessage("Loop "..i)
	  --print_table(default[i])
      local line = default[i].."{}"
      local j = 1
      local k = 1
      local sdm = ""
      local formats = ""
      while string.find(line,"}") ~= nil do
        local parse = string.find(line,"{")
        local _end = string.find(line,"}")
		if _end == line:len()-1 then
		  break
		end
        if formatting[i] == nil then
		  formatting[i] = {}
		end
        if formatting[i][j] == nil then
          formatting[i][j] = {
            n = 1,
            config =
            {
              colour = G.C.BLACK,
              text = "",
              scale = def_scale
            }
          }
        end
        --sendDebugMessage(line..": "..parse..", ".._end)
        if parse == 1 then
          k = 1
          --sendDebugMessage(tostring(line == nil))
          formats = formats..(string.sub(line,parse+1,_end-1) or "")..","
          --sendDebugMessage(formats)
          line = string.sub(line,_end+1)
        else
          if string.len(formats) > 0 then
            formats = string.gsub(formats,", ",",")..","
            local letter = ""
            local var = ""
			formatting[i][j].config.text = line:sub(1,line:find("{")-1)
            while true do
              letter = string.upper(string.sub(formats,1,1))
              var = string.sub(formats,3,string.find(formats,",")-1)
			  if type(var) == 'string' then
			    var = var:upper()
			    var = var:gsub("ATTENTION","IMPORTANT")
			  end
              --sendDebugMessage(letter..":"..var)
              if letter == "S" then
                formatting[i][j].config.scale = def_scale*(var or 1)
                --sendDebugMessage("Should be scaling text by "..100*var.."%")
              elseif letter == "V" then
                local idx = 0
                idx = idx + var
                local colour_test = loc_vars.colours[idx]
                if colour_test ~= nil then
                  formatting[i][j].config.colour = colour_test
                --sendDebugMessage("Should be changing colour to ("..(formatting[i][j].config.colour[1]*255)..", "..(formatting[i][j].config.colour[2]*255)..", "..(formatting[i][j].config.colour[3]*255)..", "..(formatting[i][j].config.colour[4]*255)..")")
                end
              elseif letter == "C" then
                var = (var or 'BLACK')
                local colour_test = G.C[string.upper(var)]
                if colour_test == nil then
                  colour_test = G.C.SUITS[string.upper(string.sub(var,1,1))..string.lower(string.sub(var,2,-1))]
                  if colour_test == nil  then
                    colour_test = G.C.UI['TEXT_'..string.upper(var)]
                  end
                end
				if formatting[i][j].nodes == nil then
                  formatting[i][j].config.colour = colour_test
				else
                  formatting[i][j].nodes[1].config.colour = colour_test
				end
                --sendDebugMessage("Should be changing colour to ("..(formatting[i][j].config.colour[1]*255)..", "..(formatting[i][j].config.colour[2]*255)..", "..(formatting[i][j].config.colour[3]*255)..", "..(formatting[i][j].config.colour[4]*255)..")")
              elseif letter == "X" then
                var = (var or 'WHITE')
				formatting[i][j].nodes = {}
				formatting[i][j].nodes[1] = {
				  n = 1
				}
			    formatting[i][j].nodes[1].config =
				{
				  colour = G.C.WHITE,
                  scale = formatting[i][j].config.scale or def_scale,
				  text = string.sub(line, 1, parse-1),
				}
				formatting[i][j].n = 3
				formatting[i][j].config.scale = nil
				formatting[i][j].config.text = nil
				var = string.upper(var)
                formatting[i][j].config.colour = G.C[var] or G.C.SUITS[var] or G.C.UI['BACKGROUND_'..var] or G.C.BLACK
				formatting[i][j].config.padding = 0.03
				formatting[i][j].config.res = 0.15
				formatting[i][j].config.align = 'm'
				formatting[i][j].config.r = 0.05
                --sendDebugMessage("Should be making node with background colour ("..(formatting[i][j].config.colour[1]*255)..", "..(formatting[i][j].config.colour[2]*255)..", "..(formatting[i][j].config.colour[3]*255)..", "..(formatting[i][j].config.colour[4]*255)..")")
              else
                --sendDebugMessage(letter)
              end
            if string.find(formats,",") == string.len(formats)-1 then
			  formats = ""
			  break
			end
            formats = string.sub(formats,string.find(formats,",")+1)
			end
          end
          if (formatting[i][j].nodes == nil) then
            formatting[i][j].config.text = string.sub(line, 1, parse-1)
          end
          --sendDebugMessage("added text: "..formatting[i][j].config.text)
          j = j + 1
          line = string.sub(line,parse)
        end
		if line:find("{") == line:len() - 2 and line:find("}") == line:len() - 1 then
		  --sendDebugMessage(line)
		  formatting[i][j].config.text = line:sub(1,-3)
		  break
		end
      end
      for j = 1, #formatting[i] do
        --sendDebugMessage("["..i.."]["..j.."]: ")

      end
    end
	--print_table(formatting)
    return formatting
end
----------------------------------------------
------------MOD CODE END----------------------