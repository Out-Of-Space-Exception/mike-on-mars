## Animações "construir" (martelada, loop) e "colocar" (abaixar e pôr no chão, 0,6 s), somadas às que o .glb já tem. Uso: blender -b --python mike-construir.py -- <entrada.glb> <saida.glb> [previa_prefixo]
import bpy, sys, math, mathutils as M
a=sys.argv[sys.argv.index('--')+1:]; IN,OUT=a[0],a[1]; PREV=a[2] if len(a)>2 else None
bpy.ops.wm.read_factory_settings(use_empty=True); bpy.ops.import_scene.gltf(filepath=IN)
arm=[o for o in bpy.data.objects if o.type=='ARMATURE'][0]
if 'Icosphere' in bpy.data.objects: bpy.data.objects.remove(bpy.data.objects['Icosphere'])
# ---- martelo low-poly na mão direita (a Dev mostra o nó "Martelo" só durante "construir") ----
def _mat(n,c):
    m=bpy.data.materials.new(n); m.use_nodes=True; m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(*c,1); m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=0.7; return m
hb=arm.data.bones['RightHand']; hp=arm.matrix_world@hb.head_local; hd=(arm.matrix_world.to_3x3()@(hb.tail_local-hb.head_local)).normalized()
c0=hp+hd*0.12
bpy.ops.mesh.primitive_cylinder_add(vertices=8,radius=0.045,depth=0.85,location=c0+M.Vector((0,-0.3,0)),rotation=(math.radians(90),0,0)); cabo=bpy.context.object; cabo.data.materials.append(_mat('martelo-cabo',(0.36,0.17,0.07)))
bpy.ops.mesh.primitive_cube_add(size=1,location=c0+M.Vector((0,-0.72,0))); cab=bpy.context.object; cab.scale=(0.13,0.13,0.36); cab.data.materials.append(_mat('martelo-cabeca',(0.55,0.56,0.6)))
bpy.ops.object.select_all(action='DESELECT'); cabo.select_set(True); cab.select_set(True); bpy.context.view_layer.objects.active=cabo; bpy.ops.object.join(); cabo.name='Martelo'
bpy.context.view_layer.update(); _mw=cabo.matrix_world.copy(); cabo.parent=arm; cabo.parent_type='BONE'; cabo.parent_bone='RightHand'; cabo.matrix_world=_mw
bpy.context.view_layer.objects.active=arm; bpy.ops.object.mode_set(mode='POSE')
arm.animation_data_create()
for t in arm.animation_data.nla_tracks: t.mute=True
arm.animation_data.action=None
for pb in arm.pose.bones: pb.rotation_mode='QUATERNION'; pb.rotation_quaternion=(1,0,0,0); pb.location=(0,0,0)
def glob(bone, R):          # world-axis rotation -> bone-local quaternion
    b=arm.data.bones[bone]; rest=b.matrix_local.to_quaternion()
    par=b.parent.matrix_local.to_quaternion() if b.parent else M.Quaternion()
    return (rest.inverted() @ R @ rest)
def aim(bone, d):
    pb=arm.pose.bones[bone]; bpy.context.view_layer.update()
    cur=pb.matrix.copy(); cd=cur.col[1].xyz.normalized(); R=cd.rotation_difference(M.Vector(d).normalized())
    m=R.to_matrix().to_4x4() @ cur; m.translation=cur.translation; pb.matrix=m
def key(f, poses):
    for pb in arm.pose.bones: pb.rotation_quaternion=(1,0,0,0)
    for bone,d in poses: aim(bone,d)
    bpy.context.view_layer.update()
    for bone,_ in poses: arm.pose.bones[bone].keyframe_insert("rotation_quaternion", frame=f)
# frente do Mike = -Y, cima = +Z
up  =[("Spine",(0,0.12,1)),("RightArm",(-0.3,0.1,1)),("RightForeArm",(-0.2,0.35,0.9)),("LeftArm",(0.3,-0.15,-1)),("LeftForeArm",(0.15,-0.7,-0.7))]
down=[("Spine",(0,-0.28,1)),("RightArm",(-0.2,-0.9,-0.4)),("RightForeArm",(-0.15,-1,-0.05)),("LeftArm",(0.3,-0.15,-1)),("LeftForeArm",(0.15,-0.7,-0.7))]
mid =[("Spine",(0,-0.05,1)),("RightArm",(-0.75,-0.5,0.45)),("RightForeArm",(-0.55,-0.8,0.2)),("LeftArm",(0.3,-0.15,-1)),("LeftForeArm",(0.15,-0.7,-0.7))]
FR=24
for f,p in ((1,up),(4,mid),(8,down),(11,down),(18,mid),(24,up)): key(f,p)
act=arm.animation_data.action; act.name='construir'
bpy.context.scene.frame_set(1); q1=arm.pose.bones['RightArm'].matrix.to_quaternion(); bpy.context.scene.frame_set(9); print('CHK', round(q1.rotation_difference(arm.pose.bones['RightArm'].matrix.to_quaternion()).angle,2))
for fc in act.fcurves if hasattr(act,'fcurves') else []:
    for k in fc.keyframe_points: k.interpolation='BEZIER'
bpy.context.scene.frame_start, bpy.context.scene.frame_end = 1, FR
track=arm.animation_data.nla_tracks.new(); track.name='construir'; track.strips.new('construir',1,act); track.mute=True
# ---- animação "colocar" (0,6 s, não repete): Mike se abaixa e põe a bandeira ou o vaso no chão ----
arm.animation_data.action=None
pe  =[('Spine',(0,0.02,1)),('RightArm',(-0.3,-0.15,-1)),('RightForeArm',(-0.2,-0.4,-1)),('LeftArm',(0.3,-0.15,-1)),('LeftForeArm',(0.2,-0.4,-1))]
abaixa=[('Spine',(0,-0.6,1)),('Head',(0,-0.35,1)),('RightArm',(-0.2,-0.85,-0.8)),('RightForeArm',(-0.1,-0.55,-1)),('LeftArm',(0.2,-0.85,-0.8)),('LeftForeArm',(0.1,-0.55,-1))]
for f,p in ((1,pe),(7,abaixa),(10,abaixa),(15,pe)): key(f,p)
act2=arm.animation_data.action; act2.name='colocar'
t2=arm.animation_data.nla_tracks.new(); t2.name='colocar'; t2.strips.new('colocar',1,act2); t2.mute=True
arm.animation_data.action=act
bpy.ops.object.mode_set(mode='OBJECT')
print("ACTIONS",[a.name for a in bpy.data.actions])
bpy.ops.export_scene.gltf(filepath=OUT, export_format='GLB', export_animation_mode='ACTIONS')
if PREV:
    sc=bpy.context.scene; sc.render.engine='BLENDER_EEVEE'; sc.render.resolution_x=sc.render.resolution_y=500
    sc.world=bpy.data.worlds.new('w'); sc.world.color=(0.69,0.36,0.15)
    bpy.ops.object.light_add(type='SUN',rotation=(0.8,0.2,-0.6)); bpy.context.object.data.energy=4
    bpy.ops.object.camera_add(location=(-6,-8,3.2)); cam=bpy.context.object; sc.camera=cam
    e=bpy.data.objects.new('t',None); e.location=(0,0,1.9); sc.collection.objects.link(e); cam.constraints.new('TRACK_TO').target=e
    print('ACT', arm.animation_data.action, getattr(arm.animation_data,'action_slot',None))
    for f in (1,9): sc.frame_set(f); sc.render.filepath=f'{PREV}{f}.png'; bpy.ops.render.render(write_still=True)
print('DONE')
