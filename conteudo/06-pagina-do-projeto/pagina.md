# Mike on Mars

- **Play:** https://out-of-space-exception.github.io/mike-on-mars/
- **Code:** https://github.com/Out-Of-Space-Exception/mike-on-mars
- **Team:** Out of Space Exception (Brazil)
- **Challenge:** Build a Junior Astronaut Mission Trainer

## High-level project summary
Mike on Mars is a free browser game for kids aged 7 to 12. Players help astronaut Mike run a small base in Gale Crater, where the Curiosity rover works. To keep Mike safe, they must balance energy, oxygen and protection from the Sun. Real NASA data drives the game: solar storms come from NASA's DONKI database, and every card a player collects shows a real NASA fact with its source. Kids feel the hard choices of a real mission, and the science shows up as a prize, not a lesson.

## Detailed project description
**What it does**
- Only 3 bars: Energy, Oxygen and Shield (protection from the Sun's radiation).
- **Build:** tap an item, then tap the ground. Items can be moved, removed and upgraded.
- **Plant:** grow real space crops in the greenhouse, like lettuce, radish and Hatch chile. The greenhouse lights use energy.
- **Explore:** Mike uses oxygen to explore and comes back with a sample tube. The tube shakes, glows in the color of its rarity and opens a card.
- **36 cards** in 4 rarities (common, rare, epic, legendary). Each card has a real name, a NASA photo and a 1-line fact.
- **Events** always have a bad side and a good side. Example: in a solar storm, raising the shield uses energy, but a shielded player may win the legendary "Aurora on Mars" card. Other events: dust storm, dust devil, freezing night and no signal from Earth.
- **Real trade-off:** solar panels give lots of energy but suffer from dust; the nuclear battery (RTG) gives a little energy but never stops.
- **No game over.** A low bar only slows or pauses an action until it recovers. The game pauses when the player has to choose. There is no timer.
- The base is saved on the device and keeps growing while the game is closed.
- Ingenuity, the Mars helicopter, flies behind Mike as a pet.

**Benefits**
- Kids learn real mission names (MOXIE, Ingenuity, Curiosity, Perseverance) and real Mars facts.
- Kids practice real mission choices: power vs. dust, shield vs. energy, plants vs. oxygen.
- Free. It runs in the phone browser, with no download and no login.
- No child data: the game asks for no name, photo or account.
- 4 languages: English, Portuguese, Spanish and French.

**What we want to achieve**
- Kids who feel that space missions are about smart choices, and who want to learn more.
- Next steps: two more places on Mars, Meridiani and Jezero. They show on the map as "coming soon" and are not playable yet.

**Tools**
- Game engine: Godot Engine 4.7.2, exported to the web.
- 3D models: Blender 5.3 and Kenney packs (CC0).
- Audio: Audacity.
- Published on GitHub Pages.

## NASA data
**1. DONKI: real solar storms**
- Source: DONKI, NASA's Space Weather Database Of Notifications, Knowledge, Information: https://ccmc.gsfc.nasa.gov/DONKI/
- What we use: 140 solar storm events (WSA-ENLIL simulations) from 2024 that reached Mars, downloaded from the NASA API (https://api.nasa.gov/).
- How the game uses it: each solar storm in the game is a real 2024 event and shows its real date. The player chooses: raise the shield (uses energy) or keep Mike inside. The first storm is always the one of May 20, 2024, which the Curiosity rover measured in Gale Crater.
- This is archived data, not live. The game says so on its "NASA data" screen.

**2. Facts and photos on the 36 cards**
- Every card fact comes from a NASA page (nasa.gov, science.nasa.gov or jpl.nasa.gov). The game links each card to its source.
- Sources, card by card:
  - Lettuce: https://www.nasa.gov/mission_pages/station/research/news/veggie
  - Radish: https://www.nasa.gov/missions/station/astronauts-harvest-radish-crop-on-international-space-station/
  - Kale: https://www.nasa.gov/exploration-research-and-technology/growing-plants-in-space/
  - Potato: https://www.nasa.gov/science-research/nasa-plant-researchers-explore-question-of-deep-space-food-crops/
  - Zinnia: https://www.nasa.gov/image-article/first-flower-grown-space-stations-veggie-facility/
  - Hatch chile: https://www.nasa.gov/image-article/fresh-chiles-spice-up-taco-night/
  - Hematite ("blueberries"): https://www.jpl.nasa.gov/news/opportunity-rover-finds-strong-evidence-meridiani-planum-was-wet/
  - Jarosite: https://www.jpl.nasa.gov/news/opportunity-rover-finds-strong-evidence-meridiani-planum-was-wet/
  - Sulfur: https://www.nasa.gov/missions/mars-science-laboratory/curiosity-rover/nasas-curiosity-rover-discovers-a-surprise-in-a-martian-rock/
  - Leopard spots: https://www.nasa.gov/news-release/nasa-says-mars-rover-discovered-potential-biosignature-last-year/
  - Solar panel: https://www.nasa.gov/wp-content/uploads/2024/01/mars-surface-power-generation-challenges-and-considerations.pdf
  - Nuclear battery (RTG): https://science.nasa.gov/planetary-science/programs/radioisotope-power-systems/faq/
  - MOXIE: https://www.nasa.gov/missions/mars-2020-perseverance/perseverance-rover/nasas-oxygen-generating-experiment-moxie-completes-mars-mission/
  - Kilopower: https://www.nasa.gov/news-release/demonstration-proves-nuclear-fission-system-can-provide-space-exploration-power/
  - Ingenuity: https://www.nasa.gov/news-release/after-three-years-on-mars-nasas-ingenuity-helicopter-mission-ends/
  - Curiosity: https://www.nasa.gov/solar-system/planets/mars/nasa-watches-mars-light-up-during-epic-solar-storm
  - Opportunity: https://www.jpl.nasa.gov/news/opportunity-hunkers-down-during-dust-storm/
  - Perseverance: https://www.nasa.gov/news-release/nasa-says-mars-rover-discovered-potential-biosignature-last-year/
  - Sol (a Mars day): https://www.nasa.gov/wp-content/uploads/2024/01/mars-surface-power-generation-challenges-and-considerations.pdf
  - Gale cold: https://science.nasa.gov/resource/steady-temperatures-at-mars-gale-crater
  - Dust storm: https://science.nasa.gov/resource/insights-power-generation-after-landing-and-spring-2022/
  - Dust devil: https://www.jpl.nasa.gov/news/spirit-gets-energy-boost-from-cleaner-solar-panels/
  - 2024 solar storm: https://www.nasa.gov/solar-system/planets/mars/nasa-watches-mars-light-up-during-epic-solar-storm
  - Frost on Mars: https://www.jpl.nasa.gov/images/pia00530-frost-on-utopia-planitia/
  - Aurora on Mars: https://science.nasa.gov/solar-system/planets/mars/nasa-observes-first-visible-light-auroras-at-mars/
  - White veins: https://science.nasa.gov/resource/veins-in-sheepbed-outcrop/
  - Olivine: https://www.jpl.nasa.gov/news/nasa-rovers-first-soil-studies-help-fingerprint-martian-minerals/
  - Bagnold Dunes: https://science.nasa.gov/resource/high-dune-is-first-martian-dune-studied-up-close-2
  - Mount Sharp: https://www.jpl.nasa.gov/news/cracks-in-ancient-martian-mud-surprise-nasas-curiosity-rover-team/
  - Ancient lakes: https://www.jpl.nasa.gov/news/nasas-curiosity-rover-team-confirms-ancient-lakes-on-mars/
  - Mud cracks: https://www.jpl.nasa.gov/news/cracks-in-ancient-martian-mud-surprise-nasas-curiosity-rover-team/
  - Manganese oxide: https://www.jpl.nasa.gov/news/nasa-rover-findings-point-to-a-more-earth-like-martian-past/
  - Boron: https://www.jpl.nasa.gov/news/mars-rock-ingredient-stew-seen-as-plus-for-habitability/
  - John Klein rock: https://www.jpl.nasa.gov/news/nasa-rover-finds-conditions-once-suited-for-ancient-life-on-mars/
  - Lebanon meteorite: https://www.jpl.nasa.gov/images/pia18387-curiosity-finds-iron-meteorite-on-mars/
  - Organic molecules: https://science.nasa.gov/missions/mars-science-laboratory/nasas-curiosity-rover-detects-largest-organic-molecules-found-on-mars/
  - Phobos and Deimos: https://science.nasa.gov/mars/moons/
  - Blue sunset: https://www.jpl.nasa.gov/images/pia19400-sunset-in-mars-gale-crater/
  - Earth seen from Mars: https://science.nasa.gov/resource/bright-evening-star-seen-from-mars-is-earth/
  - Dwarf tomato: https://www.nasa.gov/missions/station/nasa-teams-persevere-through-plant-challenges-in-space

**3. Ingenuity 3D model**
- The official Mars Ingenuity Helicopter 3D model by NASA/JPL-Caltech is the pet that flies behind Mike: https://science.nasa.gov/resource/mars-ingenuity-helicopter-3d-model/

## Space Agency Partner and other data
None. All the data and facts in the game come from NASA.

## Use of AI
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
- NASA sources of the 40 card facts: listed in "NASA data" above.

- Magic Spell SFX (magical_3.ogg, replacement sample-tube sound) · JaggedStone · CC0 · https://opengameart.org/content/magic-spell-sfx

Additional AI disclosures received from Design: Claude converted the replacement tube sound, shortened translated exploration labels, adjusted the album scrolling and event messages, and revised discovery models/materials. The itemized records are in creditos.csv.
