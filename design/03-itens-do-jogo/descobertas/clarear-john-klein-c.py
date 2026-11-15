## Deixa a John Klein: pedra C cinza (antes saía quase preta). Uso: blender -b --python clarear-john-klein-c.py -- <entrada.glb> <saida.glb>
import bpy, sys
a=sys.argv[sys.argv.index('--')+1:]
bpy.ops.wm.read_factory_settings(use_empty=True); bpy.ops.import_scene.gltf(filepath=a[0])
CORES={'#3B3F47':'#6B6870','#4E525B':'#85828A'}
lin=lambda h: [(int(h[i:i+2],16)/255)**2.2 for i in (1,3,5)]
for m in bpy.data.materials:
    p=next((n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED'),None)
    if p and m.name in CORES: p.inputs['Base Color'].default_value=(*lin(CORES[m.name]),1); p.inputs['Metallic'].default_value=0.0
bpy.ops.object.select_all(action='SELECT'); bpy.ops.export_scene.gltf(filepath=a[1], export_format='GLB'); print('DONE')
