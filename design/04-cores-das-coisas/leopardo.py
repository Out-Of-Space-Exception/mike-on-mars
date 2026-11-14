import bpy, sys, math
from mathutils import Vector, noise
src, out, texout = sys.argv[sys.argv.index("--")+1:]
bpy.ops.wm.read_factory_settings(use_empty=True)
def hexc(h, a=1): return (*tuple(((int(h[i:i+2],16)/255+0.055)/1.055)**2.4 for i in (1,3,5)), a)
bpy.ops.import_scene.gltf(filepath=src)
ms=[x for x in bpy.data.objects if x.type=="MESH"]; bpy.ops.object.select_all(action="DESELECT")
for x in ms: x.select_set(True)
bpy.context.view_layer.objects.active=ms[0]
if len(ms)>1: bpy.ops.object.join()
o=bpy.context.active_object; bpy.ops.object.parent_clear(type="CLEAR_KEEP_TRANSFORM"); bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
dims=max(o.dimensions); o.scale=(1.1/dims,)*3; bpy.ops.object.transform_apply(scale=True)
me=o.data; me.materials.clear()
bpy.ops.object.mode_set(mode="EDIT"); bpy.ops.mesh.select_all(action="SELECT"); bpy.ops.uv.smart_project(angle_limit=1.15, island_margin=0.04); bpy.ops.object.mode_set(mode="OBJECT")
# procedural leopard jasper
m = bpy.data.materials.new("leo_proc"); m.use_nodes = True; nt = m.node_tree; N = nt.nodes; Lk = nt.links.new
bsdf = N["Principled BSDF"]; tc = N.new("ShaderNodeTexCoord")
wave = N.new("ShaderNodeTexNoise"); wave.inputs["Scale"].default_value = 3.2; wave.inputs["Detail"].default_value = 9; wave.inputs["Roughness"].default_value = 0.6; wave.inputs["Distortion"].default_value = 2.5; Lk(tc.outputs["Object"], wave.inputs["Vector"])
bgr = N.new("ShaderNodeValToRGB"); e = bgr.color_ramp.elements
e[0].position = 0.40; e[0].color = hexc("#EFE2C8"); e[1].position = 0.62; e[1].color = hexc("#9E3A2A")
mid = e.new(0.50); mid.color = hexc("#C4583A"); m2 = e.new(0.45); m2.color = hexc("#D9B79A"); Lk(wave.outputs["Fac"], bgr.inputs["Fac"])
vor = N.new("ShaderNodeTexVoronoi"); vor.inputs["Scale"].default_value = 6.0; Lk(tc.outputs["Object"], vor.inputs["Vector"])
# distort spot outlines slightly with noise
nz = N.new("ShaderNodeTexNoise"); nz.inputs["Scale"].default_value = 18; Lk(tc.outputs["Object"], nz.inputs["Vector"])
add = N.new("ShaderNodeMath"); add.operation = "MULTIPLY_ADD"; add.inputs[1].default_value = 0.08; add.inputs[2].default_value = -0.04
Lk(nz.outputs["Fac"], add.inputs[0]); dsum = N.new("ShaderNodeMath"); dsum.operation = "ADD"; Lk(vor.outputs["Distance"], dsum.inputs[0]); Lk(add.outputs[0], dsum.inputs[1])
spot = N.new("ShaderNodeValToRGB"); s = spot.color_ramp.elements; spot.color_ramp.interpolation = "CONSTANT"
s[0].position = 0.0; s[0].color = hexc("#D96941"); s[1].position = 0.31; s[1].color = hexc("#000000", 0)
r0 = s.new(0.09); r0.color = hexc("#B8452F"); r1 = s.new(0.17); r1.color = hexc("#2E1A16"); r2 = s.new(0.25); r2.color = hexc("#6E5A3E")
Lk(dsum.outputs[0], spot.inputs["Fac"])
# only ~60% of cells get a spot
sep = N.new("ShaderNodeSeparateColor"); Lk(vor.outputs["Color"], sep.inputs["Color"])
gt = N.new("ShaderNodeMath"); gt.operation = "GREATER_THAN"; gt.inputs[1].default_value = 0.08; Lk(sep.outputs["Green"], gt.inputs[0])
fac = N.new("ShaderNodeMath"); fac.operation = "MULTIPLY"; Lk(spot.outputs["Alpha"], fac.inputs[0]); Lk(gt.outputs[0], fac.inputs[1])
mix = N.new("ShaderNodeMix"); mix.data_type = "RGBA"; Lk(fac.outputs[0], mix.inputs["Factor"]); Lk(bgr.outputs["Color"], mix.inputs["A"]); Lk(spot.outputs["Color"], mix.inputs["B"])
Lk(mix.outputs["Result"], bsdf.inputs["Base Color"]); bsdf.inputs["Roughness"].default_value = 0.8
me.materials.append(m)
# bake to image
img = bpy.data.images.new("leopardo_tex", 2048, 2048); it = N.new("ShaderNodeTexImage"); it.image = img; N.active = it
sc = bpy.context.scene; sc.render.engine = "CYCLES"; sc.cycles.samples = 4; sc.cycles.device = "CPU"
bpy.ops.object.select_all(action="DESELECT"); o.select_set(True); bpy.context.view_layer.objects.active = o
bpy.ops.object.bake(type="DIFFUSE", pass_filter={"COLOR"}, margin=24)
img.filepath_raw = texout; img.file_format = "PNG"; img.save()
# final material: baked texture only
fm = bpy.data.materials.new("leopardo"); fm.use_nodes = True; fb = fm.node_tree.nodes["Principled BSDF"]
ft = fm.node_tree.nodes.new("ShaderNodeTexImage"); ft.image = img; fm.node_tree.links.new(ft.outputs["Color"], fb.inputs["Base Color"]); fb.inputs["Roughness"].default_value = 0.8
me.materials.clear(); me.materials.append(fm); bpy.ops.object.shade_flat(); o.name = "leopardo"
bpy.ops.export_scene.gltf(filepath=out, export_format="GLB"); print("EXPORT")
