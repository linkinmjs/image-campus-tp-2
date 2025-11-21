## Files/Folders struct

res://
├─ addons/                  # Plugins
├─ autoload/                # Singletons (AutoLoads)
├─ assets/                  # Arte crudo (fuentes externas)
│  ├─ audio/                # WAV/OGG/MP3
│  │  ├─ sfx/
│  │  └─ music/
│  ├─ fonts/
│  ├─ textures/             # PNG/JPG (2D)
│  ├─ models/               # GLB/FBX (3D)
│  └─ video/
├─ art/                     # Exportados/procesados (si separas de assets crudos)
├─ scenes/                  # Escenas jugables y prefabs
│  ├─ levels/
│  ├─ characters/
│  ├─ props/
│  ├─ ui/
│  └─ effects/
├─ scripts/                 # Código compartido (si no lo dejas junto a la escena)
│  ├─ components/           # Composición (Health, Interactable, etc.)
│  ├─ systems/              # Lógica de alto nivel
│  ├─ utils/                # Helpers
│  └─ data/                 # Resources .tres / configuración
├─ shaders/
├─ materials/
└─ tests/
