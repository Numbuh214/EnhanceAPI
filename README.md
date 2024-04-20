# Installation / Usage

1.) After installing Steamodded (via Lovely or the old installer), download and extract this Lua file into its own folder in the Mods folder (%AppData/Roaming/Balatro/Mods).

2.) In your own mod, define your Enhancement in the `INIT` function using this format:
```
{
  name = "Sample Enhancement",
  slug = "m_sample",
  sprite = "m_sample",
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
```
3.) Call the function `newEnhancement(table)` in order to insert your Enhancement into the custom table.

4.) Define a sprite, in the same manner as you would for anything else.

And that's your custom Enhancement added to the game! You'll have to create your own logic and such, depending on what you want the enhancement to actually *do*... but I know you'll do great things now that it's easy to get started!
