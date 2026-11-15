## Mars terrain with relief: flat center for the base, hills, dunes, 3 craters and plateaus on the horizon.
import bpy, sys, math
from mathutils import Vector, noise
tex, out = sys.argv[sys.argv.index("--")+1:]
bpy.ops.wm.read_factory_settings(use_empty=True)
SIZE = 90.0; FLAT = 13.0
bpy.ops.mesh.primitive_grid_add(x_subdivisions=120, y_subdivisions=120, size=SIZE)
o = bpy.context.active_object; me = o.data
craters = [(Vector((-17, 14, 0)), 5.5), (Vector((19, 20, 0)), 4.0), (Vector((24, -15, 0)), 6.5)]
def height(x, y):
    p = Vector((x, y, 0)); d = p.length
    weight = min(max((d - FLAT) / 10.0, 0.0), 1.0)          # 0 at the center (flat), 1 far away
    h = noise.noise(Vector((x * .045, y * .045, 0))) * 2.2 + noise.noise(Vector((x * .12, y * .12, 3))) * .5
    h += math.sin(x * .18 + y * .07) * .6                    # dunes
    h *= weight
    if d > 30: h += (d - 30) * .9 * (0.6 + 0.4 * noise.noise(Vector((x * .03, y * .03, 7))))   # plateaus on the horizon
    for c, r in craters:
        dc = (p - c).length
        if dc < r: h -= (1 - (dc / r) ** 2) * r * .28          # crater floor
        elif dc < r * 1.45: h += math.sin((dc - r) / (r * .45) * math.pi) * r * .12   # raised rim
    return h
for v in me.vertices: v.co.z = height(v.co.x, v.co.y)
# top-down UV (tiled texture)
bpy.ops.object.mode_set(mode="EDIT"); bpy.ops.mesh.select_all(action="SELECT"); bpy.ops.uv.cube_project(cube_size=SIZE / 9); bpy.ops.object.mode_set(mode="OBJECT")
m = bpy.data.materials.new("chao-marte"); m.use_nodes = True; nt = m.node_tree; b = nt.nodes["Principled BSDF"]; b.inputs["Roughness"].default_value = 1
t = nt.nodes.new("ShaderNodeTexImage"); t.image = bpy.data.images.load(tex); nt.links.new(t.outputs["Color"], b.inputs["Base Color"])
me.materials.append(m); bpy.ops.object.shade_flat(); o.name = "terreno-marte"
bpy.ops.export_scene.gltf(filepath=out, export_format="GLB"); print("EXPORT", [round(x, 1) for x in o.dimensions])
