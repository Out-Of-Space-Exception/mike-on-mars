# Mike on Mars

- **Play:** https://out-of-space-exception.github.io/mike-on-mars/
- **Code:** https://github.com/Out-Of-Space-Exception/mike-on-mars
- **Team:** Out of Space Exception (Brazil)
- **Challenge:** Build a Junior Astronaut Mission Trainer

## High-level project summary
Mike on Mars is a free browser game where kids aged 7 to 12 practice running a Mars base. Players manage energy, oxygen and shielding, grow crops and collect discoveries with NASA photographs and sourced facts. Archived NASA DONKI records inspire solar storms that turn resource management into a mission choice.

## Detailed project description
**What it does**
- Only 3 bars: Energy, Oxygen and Shield (protection from the Sun's radiation).
- **Build:** tap an item, then tap the ground. Items can be moved, removed and upgraded.
- **Plant:** grow real space crops in the greenhouse, like lettuce, radish and Hatch chile. Planting uses seeds, and the greenhouse lights use energy. Players start with lettuce seeds. Harvesting returns seeds; Earth packages bring more when an antenna is built.
- **Explore:** Mike needs enough shielding and spends 30 oxygen to explore. Some searches return empty; others bring back a sample tube. The tube shakes, glows in the color of its rarity and opens a card.
- **36 cards** in 4 rarities (common, rare, epic, legendary). Each card has a real name, a NASA photo and a 1-line fact.
- **Events** change resources and can bring discoveries. Example: in a solar storm, raising the shield uses energy, but a shielded player may win the legendary "Aurora on Mars" card. Other events: dust storm, dust devil, freezing night and no signal from Earth.
- **Real trade-off:** solar panels give lots of energy but suffer from dust; the nuclear battery (RTG) gives a little energy but never stops.
- **No game over.** A low bar only slows or pauses an action until it recovers. The game pauses when the player has to choose. Choices have no countdown.
- The base is saved on the device and keeps growing while the game is closed.
- Ingenuity, the Mars helicopter, flies behind Mike as a pet.

**Benefits**
- Kids discover real mission names (MOXIE, Ingenuity, Curiosity, Perseverance) and real Mars facts.
- Kids practice real mission choices: power vs. dust, shield vs. energy, plants vs. oxygen.
- Free. It runs in the phone browser, with no download and no login.
- No child data: the game asks for no name, photo or account.
- 4 languages: English, Portuguese, Spanish and French.

**What we want to achieve**
- Kids who feel that space missions are about smart choices, and who want to learn more.
- Next steps: two more places on Mars, Meridiani and Jezero. These are future ideas, outside the current playable Gale release.

**Tools**
- Game engine: Godot Engine 4.7.2, exported to the web.
- 3D models: Blender 5.3 and Kenney packs (CC0).
- Audio: Audacity.
- Published on GitHub Pages.

## NASA data
**1. DONKI: real solar storms**
- Source: DONKI, NASA's Space Weather Database Of Notifications, Knowledge, Information: https://ccmc.gsfc.nasa.gov/DONKI/
- What we use: 140 archived DONKI WSA-ENLIL records from 2024 with modeled Mars impacts, downloaded from the NASA API (https://api.nasa.gov/).
- How the game uses it: solar storms use dates from the archived records. Simulation outputs are not direct measurements of conditions at the base; resource costs and shielding are simplified game rules. The player chooses: raise the shield (uses energy) or keep Mike inside. The first storm is always the one of May 20, 2024, which the Curiosity rover measured in Gale Crater.
- This is archived data, not live. The game says so on its "NASA data" screen.

**2. Facts and photos on the 36 cards**
- Every card fact comes from a NASA page (nasa.gov, science.nasa.gov or jpl.nasa.gov). The game links each card to its source.
- Sources, card by card:
  - Lettuce: [fact](https://www.nasa.gov/wp-content/uploads/2019/04/veggie_fact_sheet_508.pdf); [photo](https://www.nasa.gov/image-article/tending-your-garden-space/).
  - Radish: [fact](https://www.nasa.gov/missions/station/astronauts-harvest-radish-crop-on-international-space-station/); [photo](https://www.nasa.gov/image-article/radish-bulbs-are-pictured-inside-stations-advanced-plant-habitat/).
  - Kale: [fact](https://www.nasa.gov/exploration-research-and-technology/growing-plants-in-space/); [photo](https://images.nasa.gov/details/iss075e0250227).
  - Potato: [fact](https://www.nasa.gov/science-research/nasa-plant-researchers-explore-question-of-deep-space-food-crops/); [photo](https://images.nasa.gov/details/KSC-95pc1197).
  - Zinnia: [fact](https://www.nasa.gov/humans-in-space/zinnias-from-space-nasa-studies-the-multiple-benefits-of-gardening/); [photo](https://www.nasa.gov/image-article/a-bloom-in-space/).
  - Hatch chile: [fact](https://www.nasa.gov/image-article/fresh-chiles-spice-up-taco-night/); [photo](https://www.nasa.gov/missions/station/nasas-second-pepper-harvest-sets-record-on-space-station/).
  - Sulfur: [fact](https://www.nasa.gov/missions/mars-science-laboratory/curiosity-rover/nasas-curiosity-rover-discovers-a-surprise-in-a-martian-rock/); [photo](https://science.nasa.gov/resource/curiosity-views-sulfur-crystals-within-a-crushed-rock/).
  - Solar panel: [fact](https://www.nasa.gov/wp-content/uploads/2024/01/mars-surface-power-generation-challenges-and-considerations.pdf); [photo](https://science.nasa.gov/resource/insights-dusty-solar-panel/).
  - Nuclear battery (RTG): [fact](https://science.nasa.gov/planetary-science/programs/radioisotope-power-systems/faq/); [photo](https://science.nasa.gov/resource/installing-the-mmrtg-power-source/).
  - MOXIE: [fact](https://www.nasa.gov/missions/mars-2020-perseverance/perseverance-rover/nasas-oxygen-generating-experiment-moxie-completes-mars-mission/); [photo](https://science.nasa.gov/photojournal/moxie-all-tucked-in/).
  - Kilopower: [fact](https://www.nasa.gov/news-release/demonstration-proves-nuclear-fission-system-can-provide-space-exploration-power/); [photo](https://www.nasa.gov/image-article/kilopower-13/).
  - Ingenuity: [fact](https://www.nasa.gov/news-release/after-three-years-on-mars-nasas-ingenuity-helicopter-mission-ends/); [photo](https://science.nasa.gov/photojournal/ingenuity-deployed-on-mars/).
  - Curiosity: [fact](https://www.jpl.nasa.gov/news/nasa-watches-mars-light-up-during-epic-solar-storm/); [photo](https://science.nasa.gov/photojournal/curiositys-selfie-at-mont-mercou/).
  - Sol (a Mars day): [fact](https://www.nasa.gov/wp-content/uploads/2024/01/mars-surface-power-generation-challenges-and-considerations.pdf); [photo](https://science.nasa.gov/resource/sunrise-on-mars-viking-2/).
  - Gale cold: [fact](https://science.nasa.gov/photojournal/steady-temperatures-at-mars-gale-crater/); [photo](https://science.nasa.gov/photojournal/curiosity-looks-downslope-from-the-sulfate-unit/).
  - Dust storm: [fact](https://science.nasa.gov/resource/insights-power-generation-after-landing-and-spring-2022/); [photo](https://science.nasa.gov/resource/insights-dusty-solar-panel/).
  - Dust devil: [fact](https://www.jpl.nasa.gov/news/spirit-gets-energy-boost-from-cleaner-solar-panels/); [photo](https://science.nasa.gov/photojournal/spirit-solar-panel-on-sol-1813-still-very-dusty/).
  - 2024 solar storm: [fact](https://www.jpl.nasa.gov/news/nasa-watches-mars-light-up-during-epic-solar-storm/); [photo](https://science.nasa.gov/resource/curiosity-sees-streaks-and-specks-during-2024-solar-storm/).
  - Frost on Mars: [fact](https://www.jpl.nasa.gov/images/pia00530-frost-on-utopia-planitia/); [photo](https://science.nasa.gov/photojournal/ice-on-mars/).
  - Aurora on Mars: [fact](https://science.nasa.gov/solar-system/planets/mars/nasa-observes-first-visible-light-auroras-at-mars/); [photo](https://science.nasa.gov/solar-system/planets/mars/nasa-observes-first-visible-light-auroras-at-mars/).
  - White veins: [fact](https://science.nasa.gov/resource/veins-in-sheepbed-outcrop/); [photo](https://science.nasa.gov/resource/veins-in-sheepbed-outcrop/).
  - Olivine: [fact](https://www.jpl.nasa.gov/news/nasa-rovers-first-soil-studies-help-fingerprint-martian-minerals/); [photo](https://www.jpl.nasa.gov/images/pia16174-wind-blown-martian-sand/).
  - Bagnold Dunes: [fact](https://science.nasa.gov/resource/high-dune-is-first-martian-dune-studied-up-close-2/); [photo](https://science.nasa.gov/resource/high-dune-is-first-martian-dune-studied-up-close-2/).
  - Mount Sharp: [fact](https://www.jpl.nasa.gov/news/cracks-in-ancient-martian-mud-surprise-nasas-curiosity-rover-team/); [photo](https://www.jpl.nasa.gov/images/pia16769-mount-sharp-panorama-in-raw-colors/).
  - Ancient lakes: [fact](https://www.jpl.nasa.gov/news/nasas-curiosity-rover-team-confirms-ancient-lakes-on-mars/); [photo](https://science.nasa.gov/photojournal/strata-at-base-of-mount-sharp/).
  - Mud cracks: [fact](https://www.jpl.nasa.gov/news/cracks-in-ancient-martian-mud-surprise-nasas-curiosity-rover-team/); [photo](https://www.jpl.nasa.gov/news/cracks-in-ancient-martian-mud-surprise-nasas-curiosity-rover-team/).
  - Manganese oxide: [fact](https://www.jpl.nasa.gov/news/nasa-rover-findings-point-to-a-more-earth-like-martian-past/); [photo](https://www.jpl.nasa.gov/images/pia20752-nasas-curiosity-at-site-of-clues-about-ancient-oxygen/).
  - Boron: [fact](https://www.jpl.nasa.gov/news/mars-rock-ingredient-stew-seen-as-plus-for-habitability/); [photo](https://www.jpl.nasa.gov/images/pia21251-boron-in-calcium-sulfate-vein-at-catabola-mars/).
  - John Klein rock: [fact](https://www.jpl.nasa.gov/news/nasa-rover-finds-conditions-once-suited-for-ancient-life-on-mars/); [photo](https://www.jpl.nasa.gov/images/pia16726-curiositys-first-sample-drilling/).
  - Lebanon meteorite: [fact](https://www.jpl.nasa.gov/images/pia18387-curiosity-finds-iron-meteorite-on-mars/); [photo](https://www.jpl.nasa.gov/images/pia18387-curiosity-finds-iron-meteorite-on-mars/).
  - Organic molecules: [fact](https://science.nasa.gov/missions/mars-science-laboratory/nasas-curiosity-rover-detects-largest-organic-molecules-found-on-mars/); [photo](https://science.nasa.gov/resource/cumberland-target-drilled-by-curiosity/).
  - Phobos and Deimos: [fact](https://science.nasa.gov/mars/moons/); [photo](https://science.nasa.gov/photojournal/phobos-from-5800-kilometers-color/).
  - Blue sunset: [fact](https://www.jpl.nasa.gov/images/pia19400-sunset-in-mars-gale-crater/); [photo](https://www.jpl.nasa.gov/images/pia19400-sunset-in-mars-gale-crater/).
  - Earth seen from Mars: [fact](https://www.jpl.nasa.gov/images/pia17935-curiosity-mars-rovers-first-image-of-earth-and-earths-moon/); [photo](https://www.jpl.nasa.gov/images/pia17935-curiosity-mars-rovers-first-image-of-earth-and-earths-moon/).
  - Dwarf tomato: [fact](https://www.nasa.gov/missions/station/nasa-teams-persevere-through-plant-challenges-in-space/); [photo](https://www.nasa.gov/missions/station/nasa-teams-persevere-through-plant-challenges-in-space/).
  - Rocknest 3: [fact](https://science.nasa.gov/resource/a-martian-rock-called-rocknest-3/); [photo](https://science.nasa.gov/resource/a-martian-rock-called-rocknest-3/).

**3. Ingenuity 3D model**
- The official Mars Ingenuity Helicopter 3D model by NASA/JPL-Caltech is the pet that flies behind Mike: https://science.nasa.gov/resource/mars-ingenuity-helicopter-3d-model/

## Space Agency Partner and other data
None. All the data and facts in the game come from NASA.

## Use of AI
- OpenAI Codex: reviewed card science and translations, resolved photo sources, updated this draft and the Portuguese support slides to match the current seed and exploration rules. Gameplay captures are real screenshots, not generated scenes.
We used AI tools and we list every use here. Any image or video made with AI carries a visible "Made with AI" watermark.
- OpenAI ChatGPT/Codex: researched and checked NASA image sources, prepared conventional crops and a documented two-moon photo montage, reviewed credits, and helped draft the pitch scripts and capture plan. The NASA photographs were not generated by AI.
- OpenAI Codex: wrote the scripts that assembled reference videos from existing repository images, captions and credited music. These are reference edits, not recordings of gameplay.
- Microsoft synthetic voices (pt-BR-FranciscaNeural, en-US-AriaNeural and en-US-AndrewMultilingualNeural), accessed through edge-tts, were used in reference narration tests. The team selected en-US-AndrewMultilingualNeural for the English narration after reviewing its sample of approved script 2. Voice-service conditions of use remain under review; final audio timing is pending. No human narration has been recorded.
- Additional AI-assisted work by Claude includes the construction animation, construction information panels, language menu, discovery models and card layouts, exhibition shelf, and app icon. The full itemized record is in [creditos.csv](https://github.com/Out-Of-Space-Exception/mike-on-mars/blob/main/creditos.csv).
- Claude (Anthropic): suggested the 5-color palette and the font, and checked the color contrast.
- Claude (Anthropic): repainted Mike's skin, modeled his 3D hair in Blender and made the Mike render (mike.png).
- Claude (Anthropic): chose the game items with the team and modeled the solar panel, flag and string lights in Blender.
- Claude (Anthropic): repainted the hematite, sulfur, MOXIE and flower pot models, and made the leopard-spot texture and the chile plant in Blender.
- Claude (Anthropic): made the loading screen in Godot (Mars shader, spaceship and constellation effect).
- Claude (Anthropic): built the 7 screen mockups in Godot and rendered Mike and the base in Blender.
- Gemini (Google / Antigravity): selected and organized the sound effects from CC0 packs, and helped review texts and the pitch.
- Claude (Anthropic): modeled the lettuce and the kale in Blender.
- Claude (Anthropic): modeled Mike's house in Blender and repainted the Modular Dungeon Kit walls.
- Claude (Anthropic): modeled the 3 levels of Mike's house, the greenhouse and the solar panel in Blender.
- Claude (Anthropic): combined Mike's idle, run and jump animations, and chose the button icons with the team.
- Claude (Anthropic): made the Mars sky, the ground texture, the cratered terrain and the floating dust.
- Claude (Anthropic): modeled the 3 levels of MOXIE, RTG, antenna, landing pad, flag, string lights and flower pot in Blender.
- Claude (Anthropic): redid the logo title with the Junegull font and removed the space background.
- Claude (Anthropic): drew the 4 card frames from scratch with code (moldura-carta.gd).
- Claude (Anthropic): modeled the Kilopower in Blender.
- Claude (Anthropic): made Mike's astronaut look in Blender (helmet, collar, backpack and suit texture).
- Claude (Anthropic): found and checked the NASA sources of 12 cards and rewrote the facts the source did not support.
- Claude (Anthropic): wrote the text of the 7 slides with the team.
- Claude (Anthropic): translated the game texts into Spanish and French.
- Claude (Anthropic): wrote this project page with the team.

## References
- Complete itemized sources and AI disclosures: [creditos.csv](https://github.com/Out-Of-Space-Exception/mike-on-mars/blob/main/creditos.csv). Reference-video resources are distinguished from the final submission; Andrew is the selected English voice; final audio timing is pending.
- Furniture Kit (exhibition shelf) · Kenney · CC0 · https://kenney.nl/assets/furniture-kit
- Space Station Kit (exhibition shelf base and display) · Kenney · CC0 · https://kenney.nl/assets/space-station-kit
- Flag Pack (language flags) · Kenney · CC0 · https://kenney.nl/assets/flag-pack
- Pillow (reference-video image composition) · Pillow contributors · MIT-CMU · https://github.com/python-pillow/Pillow
- imageio-ffmpeg (reference-video encoding wrapper) · imageio contributors · BSD-2-Clause · https://github.com/imageio/imageio-ffmpeg
- FFmpeg (reference-video encoding) · FFmpeg developers · GPL-3.0-or-later for the build used · https://ffmpeg.org/legal.html
- edge-tts (reference narration tool) · edge-tts contributors · LGPLv3 for the tool; Microsoft voice-output conditions still under review · https://github.com/rany2/edge-tts
- Godot Engine 4.7.2 (game engine) · Godot Engine contributors · MIT · https://godotengine.org/license/
- DONKI (real solar storms) · NASA · NASA public data · https://ccmc.gsfc.nasa.gov/DONKI/
- Rubik (game font) · Hubert and Fischer, Meir Sadan, Cyreal, Daniel Grumer, Omaima Dajani · OFL · https://fonts.google.com/specimen/Rubik
- Animated Characters Protagonists (3D pack, Mike) · Kenney · CC0 · https://kenney.nl/assets/animated-characters-protagonists
- Blender 5.3 (3D modeling) · Blender Foundation · GPL · https://www.blender.org/about/license/
- Food Kit (3D pack, plants) · Kenney · CC0 · https://kenney.nl/assets/food-kit
- Nature Kit (3D pack, zinnia, rock, flower pot) · Kenney · CC0 · https://kenney.nl/assets/nature-kit
- Space Kit (3D pack, machines, rocks, antenna, loading-screen spaceship) · Kenney · CC0 · https://kenney.nl/assets/space-kit
- Skyboxes (base sky) · Kenney · CC0 · https://kenney.nl/assets/skyboxes
- Game Icons (button icons) · Kenney · CC0 · https://kenney.nl/assets/game-icons
- Game Icons Expansion (oxygen icon) · Kenney · CC0 · https://kenney.nl/assets/game-icons-expansion
- Board Game Icons (shield, greenhouse and album icons) · Kenney · CC0 · https://kenney.nl/assets/board-game-icons
- Modular Dungeon Kit (3D pack, ground and walls, repainted) · Kenney · CC0 · https://kenney.nl/assets/modular-dungeon-kit
- Interface Sounds (16 sound effects) · Kenney · CC0 · https://kenney.nl/assets/interface-sounds
- Sci-Fi Sounds (5 sound effects) · Kenney · CC0 · https://kenney.nl/assets/sci-fi-sounds
- Magic Space (aurora sound) · CodeManu · CC0 · https://opengameart.org/content/magic-space
- Happy Lullaby, song17 (background music) · The Cynic Project (cynicmusic) · CC0 · https://opengameart.org/content/happy-lullaby-song17
- Audacity 4.0.2 (audio editing) · Muse Group · GPL · https://www.audacityteam.org/
- Mars Ingenuity Helicopter 3D Model (pet) · NASA/JPL-Caltech · free use with credit (NASA media guidelines) · https://science.nasa.gov/resource/mars-ingenuity-helicopter-3d-model/
- Junegull (logo title font) · Ray Larabie (Larabie Fonts) · Larabie Fonts Freeware EULA (free for personal and commercial use; used only as an image in the logo) · https://www.larabiefonts.com/
- NASA sources of the 36 active card facts and photographs: listed in "NASA data" above.

- Magic Spell SFX (magical_3.ogg, replacement sample-tube sound) · JaggedStone · CC0 · https://opengameart.org/content/magic-spell-sfx

Additional AI disclosures received from Design: Claude converted the replacement tube sound, shortened translated exploration labels, adjusted the album scrolling and event messages, and revised discovery models/materials. The itemized records are in creditos.csv.
