import bpy, sys, math, random
from mathutils import Vector
from mathutils.bvhtree import BVHTree
a = sys.argv[sys.argv.index("--")+1:]
outdir = a[0]; jobs = a[1:]
def srgb(h): return tuple(((int(h[i:i+2],16)/255+0.055)/1.055)**2.4 for i in (1,3,5))
def setc(m, h, metal=0.0, rough=0.8, emit=0.0):
    b = m.node_tree.nodes["Principled BSDF"]; b.inputs["Base Color"].default_value = (*srgb(h),1)
    b.inputs["Metallic"].default_value = metal; b.inputs["Roughness"].default_value = rough
    if emit: b.inputs["Emission Color"].default_value = (*srgb(h),1); b.inputs["Emission Strength"].default_value = emit
def newmat(n, h, **k):
    m = bpy.data.materials.new(n); m.use_nodes = True; setc(m, h, **k); return m
GOLD = "#E8B23A"
for job in jobs:
    name, src = job.split("|", 1)
    bpy.ops.wm.read_factory_settings(use_empty=True); bpy.ops.import_scene.gltf(filepath=src)
    M = bpy.data.materials
    if name == "decoracao-vaso":
        setc(M["wood"], "#F2D091"); setc(M["woodBarkDark"], GOLD, metal=0.6, rough=0.45)
    elif name == "hematita":
        setc(M["rock"], "#3E3B44", metal=0.55, rough=0.35)
    elif name == "enxofre":
        setc(M["rock"], "#5A4642"); setc(M["rockTrack"], "#6E5650"); setc(M["crystal"], "#F7D53C", rough=0.3, emit=0.4)
    elif name == "leopardo":
        setc(M["dirt"], "#EADBB8"); setc(M["grass"], "#EADBB8")
        ob = [o for o in bpy.data.objects if o.type == "MESH"][0]
        dg = bpy.context.evaluated_depsgraph_get(); bvh = BVHTree.FromObject(ob, dg)
        spot = newmat("spot", "#3A1418"); random.seed(4); mw = ob.matrix_world
        bb = [mw @ Vector(c) for c in ob.bound_box]; ctr = sum(bb, Vector()) / 8; r = max((p - ctr).length for p in bb) * 1.5
        placed = 0
        for i in range(400):
            if placed >= 9: break
            d = Vector((random.uniform(-1,1), random.uniform(-1,1), random.uniform(0.15,1))).normalized()
            org = mw.inverted() @ (ctr + d * r); hit = bvh.ray_cast(org, (mw.inverted() @ ctr) - org)
            if hit[0] is None: continue
            loc, nor = mw @ hit[0], (mw.to_3x3() @ hit[1]).normalized()
            bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=r*0.07*random.uniform(0.7,1.2), depth=r*0.01, location=loc + nor*r*0.004)
            s = bpy.context.active_object; s.rotation_mode = "QUATERNION"; s.rotation_quaternion = nor.to_track_quat("Z","Y"); s.data.materials.append(spot); placed += 1
    elif name == "decoracao-bandeira":
        setc(M["pedra"], GOLD, metal=0.6, rough=0.45)
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=outdir + "/" + name + ".glb", export_format="GLB"); print("EXPORT", name)
