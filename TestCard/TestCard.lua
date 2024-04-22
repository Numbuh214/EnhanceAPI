--- STEAMODDED HEADER
--- MOD_NAME: Test Card
--- MOD_ID: TestCard
--- MOD_AUTHOR: [Numbuh214]
--- MOD_DESCRIPTION: This enhancement does nothing, it just tests EnhanceAPI.
--- PRIORITY: -1000
----------------------------------------------
------------MOD CODE -------------------------
function SMODS.INIT.TestCard()
  local this_mod = SMODS.findModByID("TestCard")
  local test = {
    name = "Sample Enhancement",
    slug = "m_sample",
    atlas = "m_sample",
    pos = {x=0,y=0},
    effect = "Sample Enhancement",
    label = "Sample Enhancement",
    playing_card = true,
    display_face = true,
    config = {},
    loc_txt =
    {
      "Describe your enhancement {C:attention}here{}",
      "as you would {C:attention}anything{} else"
    }
  }
  local sample_sprite = SMODS.Sprite:new(
      "m_sample",
      this_mod.path,
      "m_sample.png",
      71, 95,
      "asset_atli"
    )
  newEnhancement(test)
  sample_sprite:register()
end