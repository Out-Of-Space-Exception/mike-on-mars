import bpy, sys, math, random
from mathutils import Vector
out = sys.argv[sys.argv.index("--")+1]
bpy.ops.wm.read_factory_settings(use_empty=True)
def srgb(h): return tuple(((int(h[i:i+2],16)/255+0.055)/1.055)**2.4 for i in (1,3,5))
def mat(n, h, metal=0, rough=0.8):
    m = bpy.data.materials.new(n); m.use_nodes = True; b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*srgb(h),1); b.inputs["Metallic"].default_value = metal; b.inputs["Roughness"].default_value = rough; return m
CREAM, GOLD, SOIL = mat("creme","#F2D091"), mat("ouro","#E8B23A",0.6,0.45), mat("terra","#3A1418")
LEAF, LEAF2, RED, STEM = mat("folha","#3E8E4A"), mat("folha2","#2F6E3A"), mat("pimenta","#D62828",0,0.35), mat("cabo","#4F9A3A")
objs = []
def keep(o, m): o.data.materials.append(m); objs.append(o); return o
# pot: tapered cylinder + gold rim + saucer
bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.30, radius2=0.40, depth=0.55, location=(0,0,0.315)); keep(bpy.context.active_object, CREAM)
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.44, depth=0.09, location=(0,0,0.60)); keep(bpy.context.active_object, GOLD)
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.38, depth=0.03, location=(0,0,0.64)); keep(bpy.context.active_object, SOIL)
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.42, depth=0.04, location=(0,0,0.02)); keep(bpy.context.active_object, GOLD)
# bush: clumps of low-poly leaves
random.seed(7)
clumps = [(0,0,1.05,0.42),(0.25,0.1,0.92,0.30),(-0.24,0.08,0.95,0.30),(0.05,-0.25,0.93,0.30),(-0.05,0.27,0.98,0.28),(0.12,0.05,1.32,0.26)]
for i,(x,y,z,r) in enumerate(clumps):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=r, location=(x,y,z)); o = keep(bpy.context.active_object, LEAF if i%2 else LEAF2)
    o.scale = (1,1,0.8); o.rotation_euler = (random.random(), random.random(), random.random())
# chilies hanging from the bush edge
def chili(base, yaw, length=0.50):
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.0, radius2=0.048, depth=length, location=(0,0,0))
    c = bpy.context.active_object; c.data.materials.append(RED)
    for v in c.data.vertices:  # curve the tip
        t = (0.5 - v.co.z / length); v.co.x += 0.12 * t*t
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.06, depth=0.04, location=(0,0,length/2+0.02)); cap = bpy.context.active_object; cap.data.materials.append(STEM)
    bpy.ops.mesh.primitive_cylinder_add(vertices=4, radius=0.015, depth=0.07, location=(0,0,length/2+0.07)); st = bpy.context.active_object; st.data.materials.append(STEM)
    e = bpy.data.objects.new("chili", None); bpy.context.scene.collection.objects.link(e)
    for p in (c, cap, st): p.parent = e; objs.append(p)
    e.location = base; e.rotation_euler = (math.radians(random.uniform(-12,12)), 0, yaw)
    return e
R = 0.48
for k in range(9):
    a = k * 2*math.pi/9 + random.uniform(-0.15,0.15); z = random.uniform(0.80, 1.05)
    chili((R*math.cos(a)*random.uniform(0.85,1.0), R*math.sin(a)*random.uniform(0.85,1.0), z - 0.12), a)
for k in range(3):
    a = k*2*math.pi/3 + 0.5; chili((0.34*math.cos(a), 0.34*math.sin(a), 1.12), a)
bpy.context.view_layer.update()
bpy.ops.object.select_all(action="SELECT"); bpy.ops.object.parent_clear(type="CLEAR_KEEP_TRANSFORM")
for o in [o for o in bpy.data.objects if o.type == "EMPTY"]: bpy.data.objects.remove(o)
bpy.ops.object.select_all(action="SELECT"); bpy.context.view_layer.objects.active = [o for o in bpy.data.objects if o.type=="MESH"][0]
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True); bpy.ops.object.shade_flat()
bpy.ops.object.join(); bpy.context.active_object.name = "pimenta"
bpy.ops.export_scene.gltf(filepath=out, export_format="GLB"); print("EXPORT")
