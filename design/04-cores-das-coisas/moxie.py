import bpy, sys
src, out = sys.argv[sys.argv.index("--")+1:]
bpy.ops.wm.read_factory_settings(use_empty=True); bpy.ops.import_scene.gltf(filepath=src)
def srgb(h): return tuple(((int(h[i:i+2],16)/255+0.055)/1.055)**2.4 for i in (1,3,5))
def setc(n, h, metal, rough):
    b = bpy.data.materials[n].node_tree.nodes["Principled BSDF"]; b.inputs["Base Color"].default_value = (*srgb(h),1); b.inputs["Metallic"].default_value = metal; b.inputs["Roughness"].default_value = rough
setc("metalRed", "#E8B23A", 0.15, 0.4)
setc("metal", "#F2D091", 0.1, 0.5)
bpy.ops.object.select_all(action="SELECT"); bpy.ops.export_scene.gltf(filepath=out, export_format="GLB"); print("EXPORT")
