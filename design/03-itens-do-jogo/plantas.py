## Red lettuce ("Outredgeous" type) and curly kale, low-poly, for Mike on Mars.
import bpy, sys, math, random
from mathutils import Vector
OUT = sys.argv[sys.argv.index("--")+1]
def srgb(h): return tuple(((int(h[i:i+2],16)/255+0.055)/1.055)**2.4 for i in (1,3,5))
def mat(n, h, rough=0.7):
    m = bpy.data.materials.new(n); m.use_nodes = True; b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*srgb(h),1); b.inputs["Roughness"].default_value = rough; return m
def leaf(base, length, width, angle_z, tilt, m, waves=0.0, seg=10):
    # leaf = flattened ellipse; base at the origin, grows along +Y; then tilts and rotates
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=6, radius=1)
    o = bpy.context.active_object; o.scale = (width, length, 0.05 + waves * 0.4)
    bpy.ops.object.transform_apply(scale=True)
    for v in o.data.vertices:
        v.co.y += length
        v.co.z += (v.co.y / length) ** 2 * length * 0.18      # curves up at the tip
        if waves: v.co.z += math.sin(v.co.x * 22 + v.co.y * 9) * waves  # curly edge
    o.rotation_euler = (math.radians(tilt), 0, angle_z); o.location = base
    o.data.materials.append(m); return o
def ground(r):
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=r, depth=0.12, location=(0,0,0.06))
    o = bpy.context.active_object; o.data.materials.append(mat("terra", "#5A3825", 1.0)); return o
def save(name):
    bpy.ops.object.select_all(action="SELECT"); bpy.context.view_layer.objects.active = bpy.data.objects[0]
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True); bpy.ops.object.shade_flat(); bpy.ops.object.join()
    bpy.context.active_object.name = name
    bpy.ops.export_scene.gltf(filepath=OUT + "/" + name + ".glb", export_format="GLB"); print("EXPORT", name, [round(x,2) for x in bpy.context.active_object.dimensions])
# ---------------- red lettuce
bpy.ops.wm.read_factory_settings(use_empty=True); random.seed(3)
heart, middle, outer, tip = mat("alface-miolo","#9BD15A"), mat("alface-meio","#6FAE3E"), mat("alface-fora","#8E2A3A"), mat("alface-ponta","#B0384A")
ground(0.55)
for i in range(9):   # outer leaves, open and reddish
    a = i * 2*math.pi/9 + random.uniform(-.1,.1)
    leaf((0,0,0.12), random.uniform(.72,.82), .2, a, random.uniform(38,48), outer if i % 2 else tip)
for i in range(7):   # middle leaves, more upright
    a = i * 2*math.pi/7 + .3
    leaf((0,0,0.12), random.uniform(.62,.7), .17, a, random.uniform(58,64), middle)
for i in range(5):   # light heart
    a = i * 2*math.pi/5 + .6
    leaf((0,0,0.12), .5, .14, a, 76, heart)
save("alface")
# ---------------- curly kale
bpy.ops.wm.read_factory_settings(use_empty=True); random.seed(5)
dark, medium, stalk = mat("couve-escura","#2F6E4A"), mat("couve-media","#3F8A5A"), mat("couve-talo","#A8C98A")
ground(0.5)
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=.08, depth=.95, location=(0,0,.58)); bpy.context.active_object.data.materials.append(stalk)
heights = [.3, .48, .66, .84, 1.0]
for k, z in enumerate(heights):
    n = 4 if k < 4 else 3
    for i in range(n):
        a = i * 2*math.pi/n + k * .7
        comp = .78 - k*.07
        o = leaf((0,0,z), comp, .26, a, 28 + k*9, dark if (i+k) % 2 else medium, waves=.045, seg=16)
        bpy.ops.mesh.primitive_cylinder_add(vertices=5, radius=.02, depth=comp*.8, location=(math.cos(a+math.pi/2)*0 , 0, z))
        p = bpy.context.active_object; p.data.materials.append(stalk)
        d = Vector((-math.sin(a), math.cos(a), 0)).normalized()
        p.location = Vector((0,0,z)) + d*comp*.4 + Vector((0,0,-comp*.15)); p.rotation_euler = (math.radians(60), 0, a)
save("couve")
