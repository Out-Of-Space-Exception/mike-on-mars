import bpy, bmesh, sys, math
from mathutils import Vector
a = sys.argv[sys.argv.index("--")+1:]
fbx, skin, out, glb = a
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=fbx)
body = bpy.data.objects["characterMedium"]; arm = bpy.data.objects["Root"]
def mat(name, rgb, tex=None):
    m = bpy.data.materials.new(name); m.use_nodes = True; b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Roughness"].default_value = 0.85
    if tex:
        t = m.node_tree.nodes.new("ShaderNodeTexImage"); t.image = bpy.data.images.load(tex); m.node_tree.links.new(t.outputs["Color"], b.inputs["Base Color"])
    else: b.inputs["Base Color"].default_value = (*rgb, 1)
    return m
def srgb(h): return tuple(((int(h[i:i+2],16)/255+0.055)/1.055)**2.4 for i in (1,3,5))
body.data.materials.clear(); body.data.materials.append(mat("MikeSkin", None, skin))
HAIR = mat("MikeHair", srgb("#E9BE62")); HAIRD = mat("MikeHairShade", srgb("#D4A24A")); BAND = mat("MikeBand", srgb("#3FA7C9"))
sc = bpy.context.scene
# --- 1. hair cap from the head shell
bm = bmesh.new(); bm.from_mesh(body.data); dl = bm.verts.layers.deform.active
hg = body.vertex_groups["Head"].index
def keep(v):
    w = v[dl].get(hg, 0); c = v.co
    return w > 0.5 and (c.z > 3.36 or (c.y > 0.02 and c.z > 2.82) or (abs(c.x) > 0.30 and c.z > 3.12 and c.y > -0.30))
bmesh.ops.delete(bm, geom=[f for f in bm.faces if not all(keep(v) for v in f.verts)], context="FACES")
bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context="VERTS")
ctr = Vector((0, 0.01, 3.19))
for v in bm.verts: v.co = ctr + (v.co - ctr) * 1.07
cap_me = bpy.data.meshes.new("cap"); bm.to_mesh(cap_me); bm.free()
cap = bpy.data.objects.new("cap", cap_me); sc.collection.objects.link(cap)
cap.data.materials.append(HAIR)
sol = cap.modifiers.new("sol", "SOLIDIFY"); sol.thickness = 0.07; sol.offset = 1
bpy.context.view_layer.objects.active = cap; cap.select_set(True); bpy.ops.object.modifier_apply(modifier="sol")
parts = [cap]
def block(loc, size, rot, m=HAIR):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=[math.radians(r) for r in rot])
    o = bpy.context.active_object; o.scale = size; o.data.materials.append(m); parts.append(o); return o
def cone(loc, direction, r1, r2, depth, m=HAIR, verts=6):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.active_object; o.rotation_mode = "QUATERNION"; o.rotation_quaternion = Vector(direction).normalized().to_track_quat("-Z", "Y")
    o.data.materials.append(m); parts.append(o); return o
# --- 2. side-swept fringe: 3 chunky locks sweeping to the character's left
block((-0.24, -0.515, 3.60), (0.17, 0.07, 0.13), (-6, -18, 0))
block(( 0.02, -0.52, 3.56), (0.17, 0.07, 0.15), (-6, -24, 0))
block(( 0.27, -0.515, 3.49), (0.13, 0.07, 0.15), (-6, -32, 0), HAIRD)
# side locks over the temples
block((-0.47, -0.22, 3.33), (0.05, 0.14, 0.17), (8, 0, 0))
block(( 0.47, -0.22, 3.33), (0.05, 0.14, 0.17), (8, 0, 0))
# a small tuft on top for character
cone((0.10, -0.10, 3.86), (0.25, 0.1, 1), 0.10, 0.0, 0.22, HAIRD, 4)
# --- 3. short low ponytail with blue band
band = cone((0, 0.60, 3.00), (0, 1, -0.55), 0.10, 0.10, 0.09, BAND, 8)
cone((0, 0.68, 2.76), (0, 0.4, -1), 0.12, 0.035, 0.46, HAIR, 6)
# --- join, flat shade, skin to Head bone
bpy.ops.object.select_all(action="DESELECT")
for o in parts: o.select_set(True)
bpy.context.view_layer.objects.active = cap; bpy.ops.object.transform_apply(location=False, rotation=True, scale=True); bpy.ops.object.join()
hair = bpy.context.active_object; hair.name = "MikeHair"
bpy.ops.object.shade_flat()
vg = hair.vertex_groups.new(name="Head"); vg.add(list(range(len(hair.data.vertices))), 1.0, "REPLACE")
hair.parent = arm; md = hair.modifiers.new("Armature", "ARMATURE"); md.object = arm
# --- render
sc.render.engine = "BLENDER_EEVEE"; sc.render.resolution_x = 512; sc.render.resolution_y = 512
w = bpy.data.worlds.new("w"); sc.world = w; w.use_nodes = True; bg = w.node_tree.nodes["Background"]; bg.inputs[0].default_value = (1,1,1,1); bg.inputs[1].default_value = 0.55; sc.render.film_transparent = True; sc.view_settings.view_transform = "Standard"
sun = bpy.data.objects.new("sun", bpy.data.lights.new("sun","SUN")); sun.data.energy = 2.6; sun.rotation_euler = (math.radians(50),0,math.radians(-25)); sc.collection.objects.link(sun)
fill = bpy.data.objects.new("fill", bpy.data.lights.new("fill","SUN")); fill.data.energy = 1.2; fill.rotation_euler = (math.radians(-60),0,math.radians(160)); sc.collection.objects.link(fill)
cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam")); sc.collection.objects.link(cam); sc.camera = cam; cam.data.lens = 50
def shot(name, ang, dist, z, tz):
    r = math.radians(ang); cam.location = (dist*math.sin(r), -dist*math.cos(r), z)
    d = Vector((0,0,tz)) - cam.location; cam.rotation_euler = d.to_track_quat("-Z","Y").to_euler()
    sc.render.filepath = out + "_" + name + ".png"; bpy.ops.render.render(write_still=True)
for n, ang in (("front",0),("side",90),("back",180),("34",35)): shot(n, ang, 3.6, 3.5, 3.2)
shot("body", 25, 9.5, 3.0, 2.0)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.export_scene.gltf(filepath=glb, export_format="GLB")
print("DONE")
