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

function newEnhancement(args)
  local _t = args
  local v = {
    name = _t.name,
    slug = _t.slug,
    atlas = _t.atlas or _t.name,
    atlas_hc = _t.atlas_hc or _t.atlas,
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
  v.set = "Enhanced"
  v.config.playing_card = _t.playing_card
  v.config.display_rank = _t.display_rank
  v.VT = { w = 0, h = 0 }
  v.loc_vars = _t.loc_vars or {}
  
  G.P_CENTERS[v.key] = v
  G.P_CENTER_POOLS['Enhanced'][v.order-1] = v
  G.localization.descriptions['Enhanced'][v.slug]= {
    name = v.name,
    text = _t.loc_txt
  }
  sendInfoMessage("Registered Enhancement " .. v.name .. " with the slug " .. v.slug .. " at ID " .. v.order .. ".", 'EnhanceAPI')
  table.insert(Enhancements, v)
end

local createcard_ref = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    --sendDebugMessage(tostring(_type))
    return createcard_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
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
  local enhanced = {}
  for k, v in pairs(G.P_CENTERS) do
    if (v.set == "Enhanced") then
	  table.insert(enhanced,v)
	end
  end
  table.sort(enhanced, function(a,b) return a.order < b.order end)
  for k, v in pairs(enhanced) do
    --sendDebugMessage(tostring(v.key))
  end
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
  local index = 1+(rows*cols*page)
  for j = 1, rows do
    for i = 1, cols do
      if count%rows > 0 and j < rows and i == cols then
        offset = offset + 1
        break
      end
      if index > count then
        --sendDebugMessage("There are only "..#G.P_CENTER_POOLS[#Enhancements+8].." enhancements.")
        break
      end
      local center = enhanced[index]
      sendDebugMessage("Adding "..center.name..".")
	  
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/rows*1.75, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
	  card:set_sprites(center)
	  if center.config.display_rank ~= false then
	    card.children.front = nil
	  end
	  G.your_collection[j]:emplace(card)
	  index = index + 1
      sendDebugMessage(center.name.." added.")
    end
	if index > count then break end
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
	  card:set_sprites(center)
      card:start_materialize(nil, i>1 or j>1)
      G.your_collection[j]:emplace(card)
    end
  end
  sendDebugMessage("All Enhancements of Page "..page.." loaded.")
end

local setsprites_ref = Card.set_sprites
function Card:set_sprites(_center, _front)
  if _center and self.ability and (self.ability.set == "Enhanced" or self.ability.set == "Default") then
    local atlas = _center.atlas
	local rank_pos = {x = 0, y = 0}
	local hide_rank = false
	local has_ranks = true
	local has_suits = true
	for k, v in pairs(Enhancements) do
	  if v.slug == _center.key then
	    hide_rank = v.config.display_rank == false
		has_suits = v.config.has_suits
		has_ranks = v.config.has_ranks
	  end
	end
	if has_ranks and self.base and self.base.value and SMODS.Card.RANKS[self.base.value] then
	  rank_pos.x = SMODS.Card.RANKS[self.base.value].pos.x
	elseif has_ranks and self.config and self.config.card and SMODS.Card.RANKS[self.config.card.value] then
	  rank_pos.x = SMODS.Card.RANKS[self.config.card.value].pos.x
	elseif _front then
      rank_pos.x = _front.pos.x or 0
	end
	if has_suits and self.base and self.base.suit and SMODS.Card.SUITS[self.base.suit] then
	  rank_pos.y = SMODS.Card.SUITS[self.config.card.suit].card_pos.y
	elseif has_suits and self.config and self.config.card and SMODS.Card.SUITS[self.config.card.suit] then
	  rank_pos.y = SMODS.Card.SUITS[self.config.card.suit].card_pos.y
	elseif _front then
      rank_pos.x = _front.pos.y
	end
	if G.SETTINGS.colourblind_option and _center.atlas ~= _center.atlas_hc then
	  atlas = _center.atlas_hc
	end
	if hide_rank then
	  self.children.front = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[atlas or 'centers'], _center.pos or {x = 1, y = 0})
	  self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS['centers'], {x = 1, y = 0})
	else
	  --sendDebugMessage("default atlas is "..tostring(default_atlas(self)))
	  self.children.front = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[default_atlas(self) or "cards_"..(G.SETTINGS.colourblind_option and 2 or 1)], rank_pos)
	  self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[atlas or 'centers'], _center.pos or {x = 1, y = 0})
	end
	align_layer(self, "front")
	align_layer(self, "center")
	if not self.children.back then
	  self.children.back = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["centers"], self.params.bypass_back or (self.playing_card and G.GAME[self.back].pos or G.P_CENTERS['b_red'].pos))
	end
	align_layer(self, "back")
  else
    setsprites_ref(self, _center, _front)
  end
end

function default_atlas(card)
  local contrast = G.SETTINGS.colourblind_option
  local atlas = nil
  local suit_val = 0
  local rank_val = 0
  if card.base then
    suit_val = card.base.suit
  elseif card.config.card then
    suit_val = card.config.card.suit
  end
  if not SMODS.Card.SUITS[suit_val] then
    return "cards_"..(contrast and 2 or 1)
  end
  if contrast then
	atlas = SMODS.Card.SUITS[suit_val].card_atlas_high_contrast 
  else
	atlas = SMODS.Card.SUITS[suit_val].card_atlas_low_contrast
  end
  return atlas
end

function find_suit(y)
  for k, v in pairs(SMODS.Card.SUITS) do
    if y == v.card_pos.y then
	  return v
	end
  end
  return nil
end

function align_layer(card, layer)
    v = card.children[layer]
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

local generate_UIBox_ability_table_ref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table()
    local new_enhance = nil
	local loc_template = nil
    for k, v in pairs(Enhancements) do
      if v.name == self.ability.name then
        new_enhance = k
		loc_template = v.loc_vars
        break
      end
    end
    if new_enhance == nil then
      real_ui_table = generate_UIBox_ability_table_ref(self)
      return real_ui_table
    else
      sendDebugMessage("Enhancement is "..tostring(Enhancements[new_enhance].slug))
	  local loc_vars = {}
	  print_table(loc_template)
	  sendDebugMessage("-----------------------------------------")
	  for k, v in pairs(loc_template) do
	    if k == 'colours' then
		  loc_vars.colours = {}
		  for k2, v2 in pairs(v) do
		    if self.ability.extra[v2] == 'get_suit' then
		      loc_vars.colours[#loc_vars.colours+1] = G.C.SUITS[self.base.suit or "Hearts"]
			else
		      loc_vars.colours[#loc_vars.colours+1] = G.C[string.upper(self.ability.extra[v2])] or G.C.SUITS[self.ability.extra[v2]]
			end
		  end
		elseif self.ability.extra[v] == 'get_suit' then
		  loc_vars[#loc_vars+1] = self.base.suit or "Hearts"
		else
	      loc_vars[#loc_vars+1] = self.ability.extra[v]
		end
	  end
	  loc_vars.new_enhance = new_enhance
	  print_table(loc_vars)
      return generate_card_ui(self.config.center, nil, loc_vars, self.ability.set, generate_fake_badges(self, loc_vars))
    end
end

local generate_card_ui_ref = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end)
    if specific_vars and specific_vars.new_enhance then
	  local e = Enhancements[specific_vars.new_enhance]
      if not full_UI_table then 
        first_pass = true
        full_UI_table = generate_card_ui("c_bonus",nil,{chips = 30},card_type,badges,hide_desc,main_start,main_end)
      end
	  local desc_nodes = not full_UI_table.name and full_UI_table.main or full_UI_table.info
	  if e.playing_card and specific_vars.nominal_chips then
        localize{type = 'other', key = 'card_chips', nodes = desc_nodes, vars = {specific_vars.nominal_chips}}
      end
      localize{type = 'descriptions', key = _c.key, set = _c.set, nodes = desc_nodes, vars = specific_vars}
	  badges[1] = e
	  return full_UI_table
	else
      return generate_card_ui_ref(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end)
	end
end

function print_table(_table, idx)
  idx = idx or 0
  local line = ""
  local spc = ""
  for i = 1, idx do
    spc = " "..spc
  end
  if tostring(_table) == 'nil' then
    sendDebugMessage(spc.."nil value.")
    return
  end
  if type(_table) == 'table' then
    for k, v in pairs(_table) do
      if k ~= 'children' and k ~= 'nodes' and k ~= 'Mid' then
        if type(v) == 'table' then
          sendDebugMessage(spc..k..":")
          print_table(v, idx+1)
        else
          sendDebugMessage(spc..k..": "..tostring(v))
        end
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

local card_h_popup_ref = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
    local t = card_h_popup_ref(card)
    local badges = t.nodes[1].nodes[1].nodes[1].nodes[3] or {}
    --sendDebugMessage("Looking for badges...")
    badges = badges and badges.nodes or {}
    if card.config then
      if card.config.center then
        if card.config.center.key then
          for k, v in pairs(Enhancements) do
            if v.slug == card.config.center.key then
              local gen = generate_fake_badges(card, {})
              badges[1] = create_badge(card.ability.name, G.C.SECONDARY_SET.Enhanced, nil, 1.2)
              for k,v in pairs(gen) do
                badges[#badges + 1] = create_badge(localize(v, "labels"), get_badge_colour(v))
              end
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
----------------------------------------------
------------MOD CODE END----------------------