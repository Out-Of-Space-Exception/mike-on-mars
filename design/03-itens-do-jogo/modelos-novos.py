import bpy, sys, math
from mathutils import Vector
outdir = sys.argv[sys.argv.index("--")+1]
def srgb(h): return tuple(((int(h[i:i+2],16)/255+0.055)/1.055)**2.4 for i in (1,3,5))
def mat(n, h, emit=0, metal=0):
    m = bpy.data.materials.new(n); m.use_nodes = True; b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*srgb(h),1); b.inputs["Roughness"].default_value = 0.45 if metal else 0.8; b.inputs["Metallic"].default_value = metal
    if emit: b.inputs["Emission Color"].default_value = (*srgb(h),1); b.inputs["Emission Strength"].default_value = emit
    return m
def clear():
    bpy.ops.wm.read_factory_settings(use_empty=True)
def add(kind, loc, scale=(1,1,1), rot=(0,0,0), m=None, **kw):
    getattr(bpy.ops.mesh, "primitive_%s_add" % kind)(location=loc, rotation=[math.radians(r) for r in rot], **kw)
    o = bpy.context.active_object; o.scale = scale
    if m: o.data.materials.append(m)
    return o
def export(name):
    bpy.ops.object.select_all(action="SELECT"); bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    for o in bpy.context.selected_objects:
        if o.type == "MESH": bpy.context.view_layer.objects.active = o; bpy.ops.object.shade_flat()
    bpy.ops.export_scene.gltf(filepath=outdir + "/" + name + ".glb", export_format="GLB"); print("EXPORT", name)
GOLD = "#E8B23A"
# --- painel solar: frame dourado, celulas escuras, pe
clear(); g = mat("ouro", GOLD, metal=0.6); cell = mat("celula", "#3A1418"); line = mat("linha", "#73242A"); grey = mat("base", "#8A8F99")
add("cube", (0,0,0.12), (0.12,0.12,0.12), m=grey)
add("cylinder", (0,0,0.45), (0.04,0.04,0.35), m=g, vertices=8)
add("cube", (0,0,0.85), (0.62,0.42,0.03), (25,0,0), g)
add("cube", (0,-0.012,0.865), (0.58,0.38,0.02), (25,0,0), cell)
for x in (-0.29, 0, 0.29): add("cube", (x,-0.02,0.875), (0.012,0.38,0.012), (25,0,0), line)
for y in (-0.19, 0.19): add("cube", (0, y*math.cos(math.radians(25))-0.02, 0.875+y*math.sin(math.radians(25))), (0.58,0.012,0.012), (25,0,0), line)
export("painel-solar")
# --- bandeira: mastro dourado, flamula do time (sem bandeira de pais ou da NASA)
clear(); g = mat("ouro", GOLD, metal=0.6); red = mat("vermelho", "#BF2A2A"); cream = mat("creme", "#F2D091"); stone = mat("pedra", "#D96941")
add("cylinder", (0,0,0.05), (0.14,0.14,0.05), m=stone, vertices=8)
add("cylinder", (0,0,0.75), (0.025,0.025,0.7), m=g, vertices=8)
add("uv_sphere", (0,0,1.48), (0.05,0.05,0.05), m=g, segments=8, ring_count=6)
bpy.ops.mesh.primitive_cone_add(vertices=3, radius1=0.25, depth=0.02, location=(0.27,0,1.25), rotation=(math.radians(90),0,math.radians(0)))
f = bpy.context.active_object; f.scale = (1.4,1,1); f.data.materials.append(red)
add("cube", (0.14,0,1.25), (0.11,0.012,0.035), m=cream)
export("decoracao-bandeira")
# --- luzinhas: 2 postes dourados, fio e lampadas que brilham
clear(); g = mat("ouro", GOLD, metal=0.6); wire = mat("fio", "#3A1418"); bulb = mat("lampada", "#F2D091", emit=4); bulb2 = mat("lampada2", "#F2935C", emit=4)
for x in (-0.9, 0.9): add("cylinder", (x,0,0.55), (0.025,0.025,0.55), m=g, vertices=8); add("uv_sphere", (x,0,1.12), (0.04,0.04,0.04), m=g, segments=8, ring_count=6)
pts = [Vector((-0.9 + 1.8*i/40, 0, 1.08 - 0.22*math.sin(math.pi*i/40))) for i in range(41)]
for a, b in zip(pts, pts[1:]):
    c = (a+b)/2; d = b-a
    o = add("cylinder", c, (0.008,0.008,d.length/2), m=wire, vertices=6); o.rotation_mode = "QUATERNION"; o.rotation_quaternion = d.to_track_quat("Z","Y")
for i in range(1, 8):
    p = pts[i*5]; add("uv_sphere", p - Vector((0,0,0.06)), (0.04,0.04,0.055), m=(bulb if i % 2 else bulb2), segments=8, ring_count=6)
export("decoracao-luzinhas")
