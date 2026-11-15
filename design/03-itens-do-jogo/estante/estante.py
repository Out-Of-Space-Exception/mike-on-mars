# Display shelf (6 slots), built from CC0 Kenney pieces:
# bookcaseClosedWide (Furniture Kit), structure-panel and display-wall (Space Station Kit).
# Usage: blender -b -P estante.py -- KENNEY_FOLDER OUTPUT_FOLDER DESIGN_FOLDER
import bpy, sys, os, glob, math
from mathutils import Vector
K, OUT, DESIGN = [os.path.abspath(a) for a in sys.argv[sys.argv.index("--") + 1:]]
bpy.ops.wm.read_factory_settings(use_empty=True)
HEIGHT = 1.8  # final height in the game (Mike = 2.2)

def lin(h): return tuple(((int(h[i:i+2], 16) / 255 + 0.055) / 1.055) ** 2.4 for i in (1, 3, 5))
MATS = {}
def mat(h, emit=0.0, metal=0.0, rough=0.6):
    k = (h, emit, metal)
    if k not in MATS:
        m = bpy.data.materials.new(h + ("-luz" if emit else "")); m.use_nodes = True
        b = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
        b.inputs["Base Color"].default_value = (*lin(h), 1); b.inputs["Metallic"].default_value = metal; b.inputs["Roughness"].default_value = rough
        if emit:
            b.inputs["Emission Color"].default_value = (*lin(h), 1); b.inputs["Emission Strength"].default_value = emit
        MATS[k] = m
    return MATS[k]

def import_piece(name):
    f = glob.glob(os.path.join(K, "**", name + ".glb"), recursive=True)[0]
    before = set(bpy.data.objects); bpy.ops.import_scene.gltf(filepath=f)
    new_objs = [o for o in bpy.data.objects if o not in before]
    return [o for o in new_objs if o.parent is None][0]

def box(name, x0, x1, y0, y1, z0, z1, m):
    bpy.ops.mesh.primitive_cube_add(size=1, location=((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2))
    o = bpy.context.object; o.name = name; o.scale = (x1 - x0, y1 - y0, z1 - z0); o.data.materials.append(m); return o

def cylinder(name, x, y, z0, z1, r, m, sides=6):
    bpy.ops.mesh.primitive_cylinder_add(vertices=sides, radius=r, depth=z1 - z0, location=(x, y, (z0 + z1) / 2))
    o = bpy.context.object; o.name = name; o.data.materials.append(m); return o

WHITE, GRAY, GRAPHITE, BACK = mat("#EEF0F4"), mat("#C3C8D2"), mat("#5E6575"), mat("#1F2A44")
ORANGE, CYAN, RED = mat("#D96941"), mat("#5FE0FF", emit=3.0), mat("#BF2A2A", emit=4.0)
parts = []

# space base: flattened structure-panel
space_base = import_piece("structure-panel"); space_base.scale = (1.0 / 0.85, 0.36 / 0.85, 0.6); space_base.location = (0.4, 0.125, 0); parts.append(space_base)
H0 = 0.125 * 0.6  # base height

# the Furniture Kit bookcase, repainted: white + gray shelves + orange front + dark blue back
shelf = import_piece("bookcaseClosedWide"); shelf.location = (0, 0, H0)
me = shelf.data; me.materials.clear()
for m in (WHITE, GRAY, ORANGE, BACK): me.materials.append(m)
for p in me.polygons:
    c, n = p.center, p.normal
    if n.z > 0.9: p.material_index = 1
    elif n.y < -0.9 and c.y < 0.03: p.material_index = 2
    elif n.y < -0.9 and c.y > 0.15: p.material_index = 3
    else: p.material_index = 0
parts.append(shelf)

# divider in the middle: 3 levels x 2 columns = 6 slots
parts.append(box("divisoria", 0.39, 0.41, 0.012, 0.235, H0 + 0.04, H0 + 0.76, WHITE))
parts.append(box("divisoria-frente", 0.39, 0.41, 0.0, 0.012, H0 + 0.04, H0 + 0.76, ORANGE))

FLOORS = [0.04, 0.30, 0.55]; CEILINGS = [0.28, 0.53, 0.76]
slots = []
for a, (floor, ceiling) in enumerate(zip(FLOORS, CEILINGS)):
    parts.append(box(f"luz-{a}", 0.04, 0.76, 0.015, 0.03, H0 + ceiling - 0.012, H0 + ceiling, CYAN))  # light strip
    for col, x in enumerate((0.2, 0.6)):
        i = a * 2 + col
        parts.append(cylinder(f"pedestal-{i}", x, 0.12, H0 + floor, H0 + floor + 0.025, 0.075, GRAPHITE))
        parts.append(cylinder(f"pedestal-anel-{i}", x, 0.12, H0 + floor + 0.025, H0 + floor + 0.032, 0.06, CYAN))
        slots.append((x, 0.12, H0 + floor + 0.032))
# slot order as read: 1-2 on top, 3-4 in the middle, 5-6 at the bottom
slots = sorted(slots, key=lambda v: (-v[2], v[0]))

# top: small screen from the Space Station Kit + 2 antennas with red light
screen = import_piece("display-wall"); screen.scale = (0.7, 0.7, 0.7); screen.location = (0.4, 0.14, H0 + 0.79); parts.append(screen)
for k, x in enumerate((0.06, 0.74)):
    parts.append(cylinder(f"antena-{k}", x, 0.12, H0 + 0.79, H0 + 0.95, 0.008, GRAY, 8))
    bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=0.02, location=(x, 0.12, H0 + 0.96))
    s = bpy.context.object; s.name = f"antena-luz-{k}"; s.data.materials.append(RED); parts.append(s)

# root: centers, scales to HEIGHT and marks the slots (they become Node3D "vaga-1".."vaga-6" in Godot)
total_h = H0 + 0.98; scale_f = HEIGHT / total_h
root = bpy.data.objects.new("estante", None); bpy.context.collection.objects.link(root)
for o in parts:
    o.parent = root; o.location -= Vector((0.4, 0.125, 0))
for i, (x, y, z) in enumerate(slots, 1):
    e = bpy.data.objects.new(f"vaga-{i}", None); e.empty_display_size = 0.05; bpy.context.collection.objects.link(e)
    e.parent = root; e.location = (x - 0.4, y - 0.125, z)
root.scale = (scale_f,) * 3
bpy.context.view_layer.update()
bpy.ops.object.select_all(action="DESELECT")
for o in [root] + list(root.children_recursive): o.select_set(True)
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, "estante.glb"), export_format="GLB", use_selection=True)
with open(os.path.join(OUT, "vagas.csv"), "w", encoding="utf-8") as f:
    f.write("vaga,x,y,z,tamanho_max\n")  # in game meters, Godot axes (y up; the shelf front faces +z)
    for i, (x, y, z) in enumerate(slots, 1):
        f.write(f"{i},{(x - 0.4) * scale_f:.3f},{z * scale_f:.3f},{(y - 0.125) * scale_f:.3f},{0.17 * scale_f:.2f}\n")

# preview with displayed items (image only: not in estante.glb)
samples = ["03-itens-do-jogo/descobertas/meteorito-lebanon.glb", "04-cores-das-coisas/enxofre.glb", "03-itens-do-jogo/alface.glb",
            "03-itens-do-jogo/descobertas/veios-brancos.glb", "03-itens-do-jogo/pimenta.glb", "04-cores-das-coisas/hematita.glb"]
for (x, y, z), a in zip(slots, samples):
    before = set(bpy.data.objects); bpy.ops.import_scene.gltf(filepath=os.path.join(DESIGN, a))
    new_objs = [o for o in bpy.data.objects if o not in before]; bpy.context.view_layer.update()
    pts = [o.matrix_world @ Vector(c) for o in new_objs if o.type == "MESH" for c in o.bound_box]
    lo = Vector([min(p[k] for p in pts) for k in range(3)]); hi = Vector([max(p[k] for p in pts) for k in range(3)])
    s = 0.17 * scale_f / max(hi - lo); target = root.matrix_world @ Vector((x - 0.4, y - 0.125, z))
    pivot = Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
    for o in new_objs:
        if o.parent is None:
            o.scale = o.scale * s; o.location = target + (o.location - pivot) * s
sc = bpy.context.scene
cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam")); sc.collection.objects.link(cam); sc.camera = cam
cam.data.type = "ORTHO"; cam.data.ortho_scale = 2.3; cam.location = (0.75, -4.0, 1.6); cam.rotation_euler = (math.radians(82), 0, math.radians(11))
sun = bpy.data.objects.new("sol", bpy.data.lights.new("sol", "SUN")); sc.collection.objects.link(sun); sun.data.energy = 3.5; sun.rotation_euler = (math.radians(50), 0, math.radians(-25))
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True
bg = next(n for n in sc.world.node_tree.nodes if n.type == "BACKGROUND"); bg.inputs["Color"].default_value = (*lin("#D9A066"), 1); bg.inputs["Strength"].default_value = 0.7
sc.render.engine = "CYCLES"; sc.cycles.device = "CPU"; sc.cycles.samples = 48; sc.render.resolution_x, sc.render.resolution_y = 1000, 1100
sc.render.filepath = os.path.join(OUT, "estante-previa.png"); bpy.ops.render.render(write_still=True); print("OK")
