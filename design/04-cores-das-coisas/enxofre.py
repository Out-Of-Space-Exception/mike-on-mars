## Enxofre: pedra clara rachada ao meio, com um cacho de cristais amarelo-limão dentro (como o que o Curiosity achou ao quebrar uma pedra).
## A abertura fica virada para a frente (glTF +Z), para a câmera da estante.
import bpy, sys, math, random
from mathutils import Vector, noise
out = sys.argv[sys.argv.index("--")+1]
bpy.ops.wm.read_factory_settings(use_empty=True); random.seed(8)
def srgb(h): return tuple(((int(h[i:i+2],16)/255+0.055)/1.055)**2.4 for i in (1,3,5))
def mat(n, h, rough=0.8, emit=0.0):
    m = bpy.data.materials.new(n); m.use_nodes = True; b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*srgb(h),1); b.inputs["Roughness"].default_value = rough
    if emit: b.inputs["Emission Color"].default_value = (*srgb(h),1); b.inputs["Emission Strength"].default_value = emit
    return m
PEDRA, PEDRA2, DENTRO = mat("pedra", "#CDBFA6"), mat("pedra-escura", "#A8987C"), mat("dentro", "#E9D9A6")
CRIS1, CRIS2, CRIS3 = mat("cristal", "#F7D53C", .3, .6), mat("cristal-claro", "#FFF09A", .25, .8), mat("cristal-ouro", "#E8B23A", .3, .4)
parts = []
def metade(lado):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=.5)
    o = bpy.context.active_object
    for v in o.data.vertices:
        v.co *= 1 + noise.noise(v.co * 3.1 + Vector((lado, 0, 0))) * .18
        v.co.z *= .75; v.co.x *= 1.1
        if lado * v.co.x < 0: v.co.x *= .15          # corta ao meio (face plana da rachadura)
        if v.co.z < -.2: v.co.z = -.2 + (v.co.z + .2) * .3
    o.data.materials.append(PEDRA); o.data.materials.append(PEDRA2); o.data.materials.append(DENTRO)
    for f in o.data.polygons:
        if abs(f.normal.x) > .8 and lado * f.normal.x < 0: f.material_index = 2   # face de dentro, clara
        elif f.index % 4 == 0: f.material_index = 1
    o.location = (lado * .3, .08, .2); o.rotation_euler = (0, 0, math.radians(lado * 28))
    parts.append(o)
metade(-1); metade(1)
# cacho de cristais (prismas de 6 lados) saindo da rachadura, inclinados para a frente
for i in range(16):
    h = random.uniform(.35, .7); r = random.uniform(.06, .11)
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=r, radius2=r * .25, depth=h)
    c = bpy.context.active_object
    for v in c.data.vertices:
        if v.co.z > h / 2 - .001: v.co.z += r * .8              # ponta
    ang_z = random.uniform(-.9, .9); incl = random.uniform(.25, .75)
    d = Vector((math.sin(ang_z) * incl, -math.cos(ang_z) * incl * .9 - .25, 1)).normalized()   # para cima e para a frente (-Y)
    c.rotation_mode = "QUATERNION"; c.rotation_quaternion = d.to_track_quat("Z", "Y")
    c.location = Vector((random.uniform(-.16, .16), random.uniform(-.14, .04), .18)) + d * h * .45
    c.data.materials.append((CRIS1, CRIS2, CRIS3)[i % 3]); parts.append(c)
bpy.ops.object.select_all(action="DESELECT")
for o in parts: o.select_set(True)
bpy.context.view_layer.objects.active = parts[0]
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True); bpy.ops.object.shade_flat(); bpy.ops.object.join()
o = bpy.context.active_object; o.name = "enxofre"
mnz = min((o.matrix_world @ v.co).z for v in o.data.vertices); o.location.z -= mnz; bpy.ops.object.transform_apply(location=True)
bpy.ops.export_scene.gltf(filepath=out, export_format="GLB"); print("EXPORT", [round(x, 2) for x in o.dimensions])
