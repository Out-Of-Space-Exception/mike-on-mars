## Inclina pedras chatas para a frente (o topo bonito fica virado para a câmera da estante) e reapoia no chão.
import bpy, sys, math
from mathutils import Vector, Matrix
a = sys.argv[sys.argv.index("--")+1:]
for i in range(0, len(a), 3):
    src, out, graus = a[i], a[i+1], float(a[i+2])
    bpy.ops.wm.read_factory_settings(use_empty=True); bpy.ops.import_scene.gltf(filepath=src)
    raiz = [o for o in bpy.data.objects if o.parent is None]
    rot = Matrix.Rotation(math.radians(graus), 4, "X")   # +X: o topo (+Z) vai para -Y, que é a frente no glTF (+Z)
    for o in raiz: o.matrix_world = rot @ o.matrix_world
    bpy.context.view_layer.update()
    pts = [o.matrix_world @ Vector(c) for o in bpy.data.objects if o.type == "MESH" for c in o.bound_box]
    mnz = min(p.z for p in pts); cx = (min(p.x for p in pts) + max(p.x for p in pts)) / 2; cy = (min(p.y for p in pts) + max(p.y for p in pts)) / 2
    for o in raiz: o.location -= Vector((cx, cy, mnz))
    bpy.ops.object.select_all(action="SELECT"); bpy.ops.export_scene.gltf(filepath=out, export_format="GLB"); print("EXPORT", out.split("\\")[-1], graus)
