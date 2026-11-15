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
- **Resource trade-off:** solar panels give lots of energy but suffer from dust; the nuclear battery (RTG) gives a little energy but never stops.
- **No game over.** A low bar only slows or pauses an action until it recovers. The game pauses when the player has to choose. Choices have no countdown.
- The base is saved on the device and keeps growing while the game is closed.
- Ingenuity, the Mars helicopter, flies behind Mike as a pet.

**Learning goals**
- Kids discover real mission names (MOXIE, Ingenuity, Curiosity, Perseverance) and real Mars facts.
- Kids practice simplified resource choices: power sources, shielding and growing food. We have not measured learning outcomes in a study.
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
**1. DONKI: archived space weather**
- Source: DONKI, NASA's Space Weather Database Of Notifications, Knowledge, Information: https://ccmc.gsfc.nasa.gov/DONKI/
- What we use: 139 dates from archived 2024 DONKI WSA-ENLIL simulations with predicted arrivals at Mars, downloaded from the NASA API (https://api.nasa.gov/), plus the May 20, 2024 event documented by Curiosity. The bundled list has 140 entries. The importer keeps one entry per arrival date; this is not a count of 140 independently observed storms.
- How the game uses it: later solar storms use dates from the archived records. Simulation outputs are not direct measurements of conditions at the base; resource costs and shielding are simplified game rules. The player chooses: raise the shield (uses energy) or keep Mike inside. The first storm is always the one of May 20, 2024, which the Curiosity rover measured in Gale Crater.
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

The Phobos and Deimos card combines two real NASA photographs. The separate [Deimos source](https://science.nasa.gov/photojournal/martian-moon-deimos-in-high-resolution/) is also credited; the composition is not a single observation.

**3. Ingenuity 3D model**
- The official Mars Ingenuity Helicopter 3D model by NASA/JPL-Caltech is the pet that flies behind Mike: https://science.nasa.gov/resource/mars-ingenuity-helicopter-3d-model/

## Space Agency Partner and other data
No separate partner-agency dataset was added. NASA provides the space weather records, card facts and photographs, and the Ingenuity model. Non-NASA resources include Kenney models and icons, fonts, sound effects, music and software tools, listed in References.

## Use of AI

We used Claude (Anthropic), Gemini (Google), OpenAI ChatGPT/Codex and Microsoft synthetic voices as itemized below. NASA photographs are real photographs; crops and the two-moon composition are documented. AI-generated visuals carry a visible "Made with AI" label.

The team selected the Andrew English voice. Francisca and Aria appear only in reference tests. Voice-output terms and final video timing remain to be checked before final publication. No human narration was recorded. Reference videos are concept edits and do not replace the final gameplay recording.

- Credit 001: OpenAI Codex: organized the Redmi Note 11S reports and checklist; no independent reproduction. Provider: OpenAI. [Tool/source](https://openai.com/codex).
- Credit 005: Claude: proposed the palette and font and checked contrast. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 007: Claude: repainted Mike, modeled his hair and prepared his render. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 013: Claude: helped choose items and modeled the solar panel, flag and string lights. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 014: Claude: repainted hematite, sulfur, MOXIE and the flower pot and made the leopard-spot texture and chile plant. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 016: Claude: created the loading screen, Mars shader and spaceship trail. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 018: Claude: built seven screen mockups and rendered Mike and the base. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 025: Gemini: selected and organized CC0 sound effects and assisted text and pitch review. Provider: Google. [Tool/source](https://gemini.google.com).
- Credit 029: Claude: modeled lettuce and kale. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 031: Claude: modeled Mike's house and repainted the walls. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 032: Claude: modeled three levels of Mike's house, greenhouse and solar panel. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 033: Claude: combined Mike's animations and helped choose button icons. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 034: Claude: made the Mars sky, ground texture, cratered terrain and dust effect. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 035: Claude: modeled three levels of MOXIE, RTG, antenna, landing pad and decorations. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 037: Claude: revised the logo title with Junegull and removed the space background. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 038: Claude: created four card frames with code. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 039: Claude: modeled Kilopower. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 040: Claude: created Mike's astronaut helmet, collar, backpack and suit texture. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 041: Claude: checked NASA sources for twelve cards and revised unsupported facts. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 042: ChatGPT: researched sources and photos, prepared downloads and crops, composed real moon photos and made previews. Provider: OpenAI. [Tool/source](https://chatgpt.com).
- Credit 084: Claude: drafted the seven slide texts with the team. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 085: Claude: translated the interface texts into Spanish and French. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 086: Claude: drafted the project page with the team. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 087: Claude: created Mike's construction animation and block-building effect. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 088: Claude: created the building information panels, scripts and texts. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 090: Claude: created the language menu with flags. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 096: Claude: modeled discovery rocks and assembled five card layouts. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 099: Claude: modeled the exhibition shelf, implemented its zoom and capacity and wrote four-language text; tested in a game copy. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 100: Claude: made the app icon with a Mike render and a Mars illustration. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 101: Claude: revised sulfur and oriented discovery rocks for the shelf. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 102: OpenAI Codex: checked photo sources and credits for cards 1–40 and documented isolated-material and event searches. Provider: OpenAI. [Tool/source](https://openai.com/codex).
- Credit 104: OpenAI Codex: drafted a 29-second pitch with English captions and capture directions. Provider: OpenAI. [Tool/source](https://openai.com/codex).
- Credit 105: OpenAI Codex: assembled a reference video from repository images and captions; no simulated interface. Provider: OpenAI. [Tool/source](https://openai.com/codex).
- Credit 107: Microsoft pt-BR-FranciscaNeural via edge-tts: Portuguese reference voice; OpenAI Codex: script and timing. Provider: Microsoft; OpenAI. [Tool/source](https://github.com/rany2/edge-tts).
- Credit 108: OpenAI Codex: prepared an adult human-narration guide and translated captions; no human voice recorded. Provider: OpenAI. [Tool/source](https://openai.com/codex).
- Credit 109: OpenAI Codex: revised the English pitch; Microsoft en-US-AriaNeural via edge-tts: reference narration. Provider: OpenAI; Microsoft. [Tool/source](https://github.com/rany2/edge-tts).
- Credit 110: OpenAI Codex: drafted pitch script 2 with team introduction, gameplay, data, choice and benefit. Provider: OpenAI. [Tool/source](https://openai.com/codex).
- Credit 112: Claude: converted and replaced the sample-tube sound. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 113: Claude: shortened exploration labels in four languages and implemented album scrolling. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 114: Claude: adapted event messages to available buildings and tested in a game copy. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 115: Claude: revised hematite, John Klein rock, manganese oxide and meteorite models. Provider: Anthropic. [Tool/source](https://claude.ai).
- Credit 120: Microsoft en-US-AndrewMultilingualNeural via edge-tts: selected English voice, tested with approved script 2. Provider: Microsoft. [Tool/source](https://www.microsoft.com/servicesagreement).
- Credit 121: OpenAI Codex: prepared the script-2 capture plan and reviewed credits and AI disclosures. Provider: OpenAI. [Tool/source](https://openai.com/codex).
- Credit 122: OpenAI Codex: drafted and laid out seven support slides with real captures and NASA sources; translated to Portuguese and exported PDF/PPTX. Provider: OpenAI. [Tool/source](https://openai.com/codex).
- Credit 124: OpenAI Codex: reviewed science and wording across 41 card rows in four languages and recorded visual issues. Provider: OpenAI. [Tool/source](https://openai.com/codex).
- Credit 125: OpenAI Codex: resolved photos 21 and 22, cropped the detail in 32, selected option 39 and clarified NASA mosaic 29; no synthesized photo pixels. Provider: OpenAI. [Tool/source](https://openai.com/codex).
- Credit 126: OpenAI Codex: aligned cards, support slides, project page and capture plan with current seed and exploration rules. Provider: OpenAI. [Tool/source](https://openai.com/codex).
- Credit 127: OpenAI Codex: reviewed 187 interface texts in four languages and completed this English page, references and AI disclosures. Provider: OpenAI. [Tool/source](https://openai.com/codex).

## References

The following entries correspond one by one to [creditos.csv](https://github.com/Out-Of-Space-Exception/mike-on-mars/blob/main/creditos.csv). Historical assets, five reserve cards and narration tests remain disclosed; their inclusion does not mean they appear in the current playable game. License/status labels reflect the register supplied by the team.

- Credit 001: OpenAI Codex: organized the Redmi Note 11S reports and checklist; no independent reproduction. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
- Credit 002: Godot Engine 4.7.2: game engine. Author/provider: Godot Engine contributors. License/status: MIT. [Source](https://godotengine.org/license/).
- Credit 003: DONKI: archived space weather data used for solar events. Author/provider: NASA. License/status: NASA public data. [Source](https://ccmc.gsfc.nasa.gov/DONKI/).
- Credit 004: Rubik: interface font. Author/provider: Hubert and Fischer, Meir Sadan, Cyreal, Daniel Grumer, Omaima Dajani. License/status: OFL. [Source](https://fonts.google.com/specimen/Rubik).
- Credit 005: Claude: proposed the palette and font and checked contrast. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 006: Animated Characters Protagonists: Mike model, with team modifications. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/animated-characters-protagonists).
- Credit 007: Claude: repainted Mike, modeled his hair and prepared his render. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 008: Blender 5.3: 3D modeling. Author/provider: Blender Foundation. License/status: GPL. [Source](https://www.blender.org/about/license/).
- Credit 009: Food Kit: plant models. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/food-kit).
- Credit 010: Nature Kit: plant, rock and flower-pot models. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/nature-kit).
- Credit 011: Space Kit: machines, rocks and antenna models. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/space-kit).
- Credit 012: Skyboxes: base sky. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/skyboxes).
- Credit 013: Claude: helped choose items and modeled the solar panel, flag and string lights. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 014: Claude: repainted hematite, sulfur, MOXIE and the flower pot and made the leopard-spot texture and chile plant. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 015: Space Kit craft_speederA: loading-screen spaceship. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/space-kit).
- Credit 016: Claude: created the loading screen, Mars shader and spaceship trail. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 017: Game Icons: wrench, target, menu and home icons. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/game-icons).
- Credit 018: Claude: built seven screen mockups and rendered Mike and the base. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 019: Kenney Interface Sounds: interface and gameplay sound effects. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/interface-sounds).
- Credit 020: Kenney Sci-Fi Sounds: construction, alert, shield and helicopter effects. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/sci-fi-sounds).
- Credit 021: Magic Space: aurora sound. Author/provider: CodeManu. License/status: CC0. [Source](https://opengameart.org/content/magic-space).
- Credit 022: Mars Ingenuity Helicopter 3D Model: companion helicopter. Author/provider: NASA/JPL-Caltech. License/status: free use with credit under NASA media guidelines. [Source](https://science.nasa.gov/resource/mars-ingenuity-helicopter-3d-model/).
- Credit 023: Happy Lullaby (song17): background music. Author/provider: The Cynic Project (cynicmusic). License/status: CC0. [Source](https://opengameart.org/content/happy-lullaby-song17).
- Credit 024: Audacity 4.0.2: audio editing and conversion. Author/provider: Muse Group. License/status: GPL. [Source](https://www.audacityteam.org/).
- Credit 025: Gemini: selected and organized CC0 sound effects and assisted text and pitch review. Author/provider: Google. License/status: not applicable (AI assistance). [Source](https://gemini.google.com).
- Credit 026: Game Icons Expansion: oxygen icon. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/game-icons-expansion).
- Credit 027: Board Game Icons: shield, greenhouse and album icons. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/board-game-icons).
- Credit 028: Game Icons: energy, exploration, construction and photo icons. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/game-icons).
- Credit 029: Claude: modeled lettuce and kale. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 030: Modular Dungeon Kit: repainted terrain and walls. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/modular-dungeon-kit).
- Credit 031: Claude: modeled Mike's house and repainted the walls. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 032: Claude: modeled three levels of Mike's house, greenhouse and solar panel. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 033: Claude: combined Mike's animations and helped choose button icons. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 034: Claude: made the Mars sky, ground texture, cratered terrain and dust effect. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 035: Claude: modeled three levels of MOXIE, RTG, antenna, landing pad and decorations. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 036: Junegull: logo font, used as a rendered image. Author/provider: Ray Larabie (Larabie Fonts). License/status: Larabie Fonts Freeware EULA; rendered logo only; Design approved the project-rule exception. [Source](https://www.larabiefonts.com/).
- Credit 037: Claude: revised the logo title with Junegull and removed the space background. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 038: Claude: created four card frames with code. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 039: Claude: modeled Kilopower. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 040: Claude: created Mike's astronaut helmet, collar, backpack and suit texture. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 041: Claude: checked NASA sources for twelve cards and revised unsupported facts. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 042: ChatGPT: researched sources and photos, prepared downloads and crops, composed real moon photos and made previews. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://chatgpt.com).
- Credit 043: Kale: NASA photograph. Author/provider: NASA/Anil Menon. License/status: NASA public imagery, with credit. [Source](https://images.nasa.gov/details/iss075e0250227).
- Credit 044: Potato: NASA photograph. Author/provider: NASA/KSC (centro de origem; fotografo nao informado). License/status: NASA public imagery, with credit. [Source](https://images.nasa.gov/details/KSC-95pc1197).
- Credit 045: Lettuce: NASA photograph. Author/provider: NASA - Expedition 53 crew. License/status: NASA public imagery, with credit. [Source](https://www.nasa.gov/image-article/tending-your-garden-space/).
- Credit 046: Radish: NASA photograph. Author/provider: NASA. License/status: NASA public imagery, with credit. [Source](https://www.nasa.gov/image-article/radish-bulbs-are-pictured-inside-stations-advanced-plant-habitat/).
- Credit 047: Zinnia: NASA photograph. Author/provider: NASA/Scott Kelly. License/status: NASA public imagery, with credit. [Source](https://www.nasa.gov/image-article/a-bloom-in-space/).
- Credit 048: Hatch chile: NASA photograph. Author/provider: NASA. License/status: NASA public imagery, with credit. [Source](https://www.nasa.gov/missions/station/nasas-second-pepper-harvest-sets-record-on-space-station/).
- Credit 049: Hematite ("blueberries"): NASA photograph. Author/provider: NASA/JPL-Caltech/Cornell/USGS. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia19113-martian-concretions-near-fram-crater/).
- Credit 050: Jarosite: NASA photograph. Author/provider: NASA/JPL-Caltech/Univ. of Arizona. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia20371-jarosite-in-noctis-labyrinthus/).
- Credit 051: Sulfur: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/resource/curiosity-views-sulfur-crystals-within-a-crushed-rock/).
- Credit 052: Leopard spots: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia26368-perseverance-finds-a-rock-with-leopard-spots/).
- Credit 053: Solar panel: NASA photograph. Author/provider: NASA/JPL-Caltech. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/resource/insights-dusty-solar-panel/).
- Credit 054: Nuclear battery (RTG): NASA photograph. Author/provider: NASA. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/resource/installing-the-mmrtg-power-source/).
- Credit 055: MOXIE: NASA photograph. Author/provider: NASA/JPL-Caltech. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/photojournal/moxie-all-tucked-in/).
- Credit 056: Kilopower: NASA photograph. Author/provider: NASA. License/status: NASA public imagery, with credit. [Source](https://www.nasa.gov/image-article/kilopower-13/).
- Credit 057: Ingenuity: NASA photograph. Author/provider: NASA/JPL-Caltech. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/photojournal/ingenuity-deployed-on-mars/).
- Credit 058: Curiosity: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/photojournal/curiositys-selfie-at-mont-mercou/).
- Credit 059: Opportunity: NASA photograph. Author/provider: NASA/JPL-Caltech. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/photojournal/opportunitys-first-selfie/).
- Credit 060: Perseverance: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/photojournal/perseverances-three-forks-sample-depot-selfie/).
- Credit 061: Sol (a Mars day): NASA photograph. Author/provider: NASA/JPL/LaRC. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/resource/sunrise-on-mars-viking-2/).
- Credit 062: Gale cold: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/photojournal/curiosity-looks-downslope-from-the-sulfate-unit/).
- Credit 063: Dust storm: NASA photograph. Author/provider: NASA/JPL-Caltech. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/resource/insights-dusty-solar-panel/).
- Credit 064: Dust devil: NASA photograph. Author/provider: NASA/JPL-Caltech. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/photojournal/spirit-solar-panel-on-sol-1813-still-very-dusty/).
- Credit 065: 2024 solar storm: NASA photograph. Author/provider: NASA/JPL-Caltech. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/resource/curiosity-sees-streaks-and-specks-during-2024-solar-storm/).
- Credit 066: Frost on Mars: NASA photograph. Author/provider: NASA/JPL. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/photojournal/ice-on-mars/).
- Credit 067: Aurora on Mars: NASA photograph. Author/provider: NASA/JPL-Caltech/ASU/MSSS/SSI. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/solar-system/planets/mars/nasa-observes-first-visible-light-auroras-at-mars/).
- Credit 068: White veins: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/resource/veins-in-sheepbed-outcrop/).
- Credit 069: Olivine: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia16174-wind-blown-martian-sand/).
- Credit 070: Bagnold Dunes: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/resource/high-dune-is-first-martian-dune-studied-up-close-2/).
- Credit 071: Mount Sharp: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia16769-mount-sharp-panorama-in-raw-colors/).
- Credit 072: Ancient lakes: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/photojournal/strata-at-base-of-mount-sharp/).
- Credit 073: Mud cracks: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS/IRAP. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/news/cracks-in-ancient-martian-mud-surprise-nasas-curiosity-rover-team/).
- Credit 074: Manganese oxide: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia20752-nasas-curiosity-at-site-of-clues-about-ancient-oxygen/).
- Credit 075: Boron: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS/LANL/CNES/IRAP/LPGNantes/CNRS/IAS. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia21251-boron-in-calcium-sulfate-vein-at-catabola-mars/).
- Credit 076: John Klein rock: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia16726-curiositys-first-sample-drilling/).
- Credit 077: Lebanon meteorite: NASA photograph. Author/provider: NASA/JPL-Caltech/LANL/CNES/IRAP/LPGNantes/CNRS/IAS/MSSS. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia18387-curiosity-finds-iron-meteorite-on-mars/).
- Credit 078: Organic molecules: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/resource/cumberland-target-drilled-by-curiosity/).
- Credit 079: Phobos and Deimos: NASA photograph (Phobos source for the two-moon composition). Author/provider: NASA/JPL-Caltech/University of Arizona. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/photojournal/phobos-from-5800-kilometers-color/).
- Credit 080: Blue sunset: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS/Texas A&M Univ.. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia19400-sunset-in-mars-gale-crater/).
- Credit 081: Earth seen from Mars: NASA photograph. Author/provider: NASA/JPL-Caltech/MSSS/TAMU. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia17935-curiosity-mars-rovers-first-image-of-earth-and-earths-moon/).
- Credit 082: Dwarf tomato: NASA photograph. Author/provider: NASA. License/status: NASA public imagery, with credit. [Source](https://www.nasa.gov/missions/station/nasa-teams-persevere-through-plant-challenges-in-space/).
- Credit 083: Deimos source for the two-moon composition. Author/provider: NASA/JPL-Caltech/University of Arizona. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/photojournal/martian-moon-deimos-in-high-resolution/).
- Credit 084: Claude: drafted the seven slide texts with the team. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 085: Claude: translated the interface texts into Spanish and French. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 086: Claude: drafted the project page with the team. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 087: Claude: created Mike's construction animation and block-building effect. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 088: Claude: created the building information panels, scripts and texts. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 089: Kenney Flag Pack: language flags. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/flag-pack).
- Credit 090: Claude: created the language menu with flags. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 091: White veins: Design source image. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://images.nasa.gov/details/PIA16705).
- Credit 092: Rocknest 3: Design source image. Author/provider: NASA/JPL-Caltech/Malin Space Science Systems. License/status: NASA public imagery, with credit. [Source](https://images.nasa.gov/details/PIA16452).
- Credit 093: Manganese oxide: Design source image. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://images.nasa.gov/details/PIA20752).
- Credit 094: John Klein rock: Design source image. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://images.nasa.gov/details/PIA16568).
- Credit 095: Lebanon meteorite: Design source image. Author/provider: NASA/JPL-Caltech/LANL/CNES/IRAP/LPGNantes/CNRS/IAS/MSSS. License/status: NASA public imagery, with credit. [Source](https://images.nasa.gov/details/PIA18387).
- Credit 096: Claude: modeled discovery rocks and assembled five card layouts. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 097: Furniture Kit: modified exhibition shelf. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/furniture-kit).
- Credit 098: Space Station Kit: exhibition shelf base and display. Author/provider: Kenney. License/status: CC0. [Source](https://kenney.nl/assets/space-station-kit).
- Credit 099: Claude: modeled the exhibition shelf, implemented its zoom and capacity and wrote four-language text; tested in a game copy. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 100: Claude: made the app icon with a Mike render and a Mars illustration. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 101: Claude: revised sulfur and oriented discovery rocks for the shelf. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 102: OpenAI Codex: checked photo sources and credits for cards 1–40 and documented isolated-material and event searches. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
- Credit 103: Earth seen from Mars: alternative crop, PIA17935. Author/provider: NASA/JPL-Caltech/MSSS/TAMU. License/status: NASA public imagery, with credit. [Source](https://www.jpl.nasa.gov/images/pia17935-curiosity-mars-rovers-first-image-of-earth-and-earths-moon/).
- Credit 104: OpenAI Codex: drafted a 29-second pitch with English captions and capture directions. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
- Credit 105: OpenAI Codex: assembled a reference video from repository images and captions; no simulated interface. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
- Credit 106: Sulfur PIA26309: reference-video storyboard. Author/provider: NASA/JPL-Caltech/MSSS. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/resource/curiosity-views-sulfur-crystals-within-a-crushed-rock/).
- Credit 107: Microsoft pt-BR-FranciscaNeural via edge-tts: Portuguese reference voice; OpenAI Codex: script and timing. Author/provider: Microsoft; OpenAI. License/status: TO CHECK: voice-output terms; tool or team approval does not establish these terms. [Source](https://github.com/rany2/edge-tts).
- Credit 108: OpenAI Codex: prepared an adult human-narration guide and translated captions; no human voice recorded. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
- Credit 109: OpenAI Codex: revised the English pitch; Microsoft en-US-AriaNeural via edge-tts: reference narration. Author/provider: OpenAI; Microsoft. License/status: TO CHECK: voice-output terms; tool or team approval does not establish these terms. [Source](https://github.com/rany2/edge-tts).
- Credit 110: OpenAI Codex: drafted pitch script 2 with team introduction, gameplay, data, choice and benefit. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
- Credit 111: Magic Spell SFX: magical_3.ogg converted to WAV for opening sample tubes. Author/provider: JaggedStone. License/status: CC0. [Source](https://opengameart.org/content/magic-spell-sfx).
- Credit 112: Claude: converted and replaced the sample-tube sound. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 113: Claude: shortened exploration labels in four languages and implemented album scrolling. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 114: Claude: adapted event messages to available buildings and tested in a game copy. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 115: Claude: revised hematite, John Klein rock, manganese oxide and meteorite models. Author/provider: Anthropic. License/status: not applicable (AI assistance). [Source](https://claude.ai).
- Credit 116: Pillow: reference-video image composition. Author/provider: Pillow contributors. License/status: MIT-CMU. [Source](https://github.com/python-pillow/Pillow).
- Credit 117: imageio-ffmpeg: reference-video encoding wrapper. Author/provider: imageio contributors. License/status: BSD-2-Clause. [Source](https://github.com/imageio/imageio-ffmpeg).
- Credit 118: FFmpeg: H.264 and AAC encoding for reference videos. Author/provider: FFmpeg developers. License/status: GPL-3.0-or-later (encoding build used). [Source](https://ffmpeg.org/legal.html).
- Credit 119: edge-tts: reference narration tool; its code license does not establish voice-output terms. Author/provider: edge-tts contributors. License/status: LGPLv3 (tool code). [Source](https://github.com/rany2/edge-tts).
- Credit 120: Microsoft en-US-AndrewMultilingualNeural via edge-tts: selected English voice, tested with approved script 2. Author/provider: Microsoft. License/status: TO CHECK: voice-output terms; tool or team approval does not establish these terms. [Source](https://www.microsoft.com/servicesagreement).
- Credit 121: OpenAI Codex: prepared the script-2 capture plan and reviewed credits and AI disclosures. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
- Credit 122: OpenAI Codex: drafted and laid out seven support slides with real captures and NASA sources; translated to Portuguese and exported PDF/PPTX. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
- Credit 123: Rocknest 3: Content delivery photograph. Author/provider: NASA/JPL-Caltech/Malin Space Science Systems. License/status: NASA public imagery, with credit. [Source](https://science.nasa.gov/resource/a-martian-rock-called-rocknest-3/).
- Credit 124: OpenAI Codex: reviewed science and wording across 41 card rows in four languages and recorded visual issues. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
- Credit 125: OpenAI Codex: resolved photos 21 and 22, cropped the detail in 32, selected option 39 and clarified NASA mosaic 29; no synthesized photo pixels. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
- Credit 126: OpenAI Codex: aligned cards, support slides, project page and capture plan with current seed and exploration rules. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
- Credit 127: OpenAI Codex: reviewed 187 interface texts in four languages and completed this English page, references and AI disclosures. Author/provider: OpenAI. License/status: not applicable (AI assistance). [Source](https://openai.com/codex).
