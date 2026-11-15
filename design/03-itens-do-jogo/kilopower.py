## Mike on Mars Kilopower (level 3 RTG): core, converter ring, mast and umbrella radiator. Low-poly, palette colors.
import bpy, sys, math
from mathutils import Vector
out = sys.argv[sys.argv.index("--")+1]
bpy.ops.wm.read_factory_settings(use_empty=True)
def srgb(h): return tuple(((int(h[i:i+2],16)/255+0.055)/1.055)**2.4 for i in (1,3,5))
def mat(n, h, metal=0.0, rough=0.7, emit=0.0):
    m = bpy.data.materials.new(n); m.use_nodes = True; b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*srgb(h),1); b.inputs["Metallic"].default_value = metal; b.inputs["Roughness"].default_value = rough
    if emit: b.inputs["Emission Color"].default_value = (*srgb(h),1); b.inputs["Emission Strength"].default_value = emit
    return m
M = dict(WHITE=mat("branco","#F4F4F8"), CREAM=mat("creme","#F2D091"), GOLD=mat("ouro","#E8B23A",0.3,0.4), GOLD2=mat("ouro-escuro","#A87C2A",0.3,0.5),
         WINE=mat("vinho","#73242A"), GRAY=mat("cinza","#C9CCD6"), DARK=mat("escuro","#3A1418"), LIGHT=mat("luz","#F2935C",0,.5,6), LIGHT2=mat("luz2","#F2D091",0,.5,5))
parts = []
def add(kind, loc, scale=(1,1,1), rot=(0,0,0), m=None, **kw):
    getattr(bpy.ops.mesh, "primitive_%s_add" % kind)(location=loc, rotation=[math.radians(r) for r in rot], **kw)
    o = bpy.context.active_object; o.scale = scale
    if m: o.data.materials.append(M[m])
    parts.append(o); return o
def rod(a, b, r, m):
    d = Vector(b) - Vector(a); o = add("cylinder", (Vector(a) + Vector(b)) / 2, m=m, vertices=6, radius=r, depth=d.length)
    o.rotation_mode = "QUATERNION"; o.rotation_quaternion = d.to_track_quat("Z", "Y"); return o
# platform
add("cylinder", (0,0,.08), m="WINE", vertices=8, radius=1.15, depth=.16)
add("cylinder", (0,0,.17), m="GOLD", vertices=8, radius=1.1, depth=.03)
for i in range(4):
    a = i*math.pi/2 + math.pi/4; add("cube", (math.cos(a)*1.05, math.sin(a)*1.05, .05), (.12,.12,.06), m="GRAY")
# reactor core (bottom) with bands and shielding
add("cylinder", (0,0,.55), m="WHITE", vertices=12, radius=.38, depth=.75)
for z in (.25, .55, .85): add("cylinder", (0,0,z), m="GOLD", vertices=12, radius=.4, depth=.06)
add("cylinder", (0,0,.55), m="LIGHT", vertices=12, radius=.405, depth=.12)                       # little heat window (glow)
add("cone", (0,0,1.05), m="DARK", vertices=12, radius1=.42, radius2=.28, depth=.3)           # shielding
# heat pipes rising to the converters
for i in range(8):
    a = i*math.tau/8
    rod((math.cos(a)*.2, math.sin(a)*.2, 1.15), (math.cos(a)*.42, math.sin(a)*.42, 1.65), .025, "GOLD")
# ring of 8 converters (turn heat into electricity)
add("cylinder", (0,0,1.7), m="GRAY", vertices=12, radius=.2, depth=.5)
for i in range(8):
    a = i*math.tau/8; p = (math.cos(a)*.46, math.sin(a)*.46, 1.72)
    add("cylinder", p, m="CREAM", vertices=8, radius=.09, depth=.34)
    add("cylinder", (p[0], p[1], 1.91), m="GOLD", vertices=8, radius=.095, depth=.05)
add("torus", (0,0,1.72), m="GOLD2", major_radius=.46, minor_radius=.025, major_segments=24, minor_segments=6)
# mast
add("cylinder", (0,0,2.45), m="WHITE", vertices=8, radius=.09, depth=1.1)
add("cylinder", (0,0,2.15), m="GOLD", vertices=8, radius=.11, depth=.06)
# umbrella radiator: 12 gold segments opening downward, with ribs
TOP = 3.2; R = 1.35; N = 12
for i in range(N):
    a0 = i*math.tau/N + .02; a1 = (i+1)*math.tau/N - .02
    pts = [Vector((0,0,TOP)), Vector((math.cos(a0)*R, math.sin(a0)*R, TOP-.55)), Vector((math.cos(a1)*R, math.sin(a1)*R, TOP-.55))]
    me = bpy.data.meshes.new("gomo"); me.from_pydata([tuple(p) for p in pts] + [tuple(p - Vector((0,0,.04))) for p in pts], [], [(0,1,2),(5,4,3),(0,3,4,1),(1,4,5,2),(2,5,3,0)])
    o = bpy.data.objects.new("gomo", me); bpy.context.scene.collection.objects.link(o); o.data.materials.append(M["GOLD" if i % 2 else "CREAM"]); parts.append(o)
    rod((0,0,TOP+.02), (math.cos(a0-.02)*R*1.02, math.sin(a0-.02)*R*1.02, TOP-.57), .018, "GOLD2")
for i in range(6):  # arms that hold the umbrella
    a = i*math.tau/6; rod((0,0,2.7), (math.cos(a)*R*.55, math.sin(a)*R*.55, TOP-.29), .02, "GRAY")
add("cylinder", (0,0,TOP+.05), m="GOLD", vertices=10, radius=.13, depth=.1)
add("uv_sphere", (0,0,TOP+.2), m="LIGHT2", segments=10, ring_count=6, radius=.1)
# join and export
bpy.ops.object.select_all(action="DESELECT")
for o in parts: o.select_set(True)
bpy.context.view_layer.objects.active = parts[0]
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True); bpy.ops.object.shade_flat(); bpy.ops.object.join()
o = bpy.context.active_object; o.name = "kilopower"
bpy.ops.export_scene.gltf(filepath=out, export_format="GLB"); print("EXPORT", [round(x,2) for x in o.dimensions])
