## Hematita ("blueberries"): bolinhas cinza-azuladas, redondas mas irregulares (como a veios brancos),
## sobre um pedacinho de solo marrom. Cores tiradas da foto da carta 7 (NASA/JPL, Opportunity).
## Uso: blender -b --python hematita.py -- <saida.glb> [previa.png]
import bpy, bmesh, sys, random, math, mathutils as M
a=sys.argv[sys.argv.index('--')+1:]; OUT=a[0]; PREV=a[1] if len(a)>1 else None
bpy.ops.wm.read_factory_settings(use_empty=True); random.seed(7)
def mat(n,h,rough=0.85):
    m=bpy.data.materials.new(n); m.use_nodes=True
    p=next(x for x in m.node_tree.nodes if x.type=='BSDF_PRINCIPLED')
    p.inputs['Base Color'].default_value=(*[(int(h[i:i+2],16)/255)**2.2 for i in (1,3,5)],1); p.inputs['Roughness'].default_value=rough; return m
SOLO=mat('hematita-solo','#7A5446'); CORES=[mat('hematita-a','#8E95B6'),mat('hematita-b','#A6AACA'),mat('hematita-c','#9A8FAA')]
def lumpy(loc,r,squash,m,sub=1,j=0.12):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub,radius=r,location=loc); o=bpy.context.object
    bm=bmesh.new(); bm.from_mesh(o.data)
    for v in bm.verts: v.co*=1+random.uniform(-j,j)
    bm.to_mesh(o.data); bm.free(); o.scale=(1,1,squash); o.data.materials.append(m); return o
partes=[lumpy((0,0,0.03),0.55,0.18,SOLO,2,0.08)]          # solo achatado
for x,y,r in [(-0.22,-0.1,0.19),(0.12,-0.2,0.15),(0.26,0.12,0.17),(-0.05,0.22,0.13),(-0.3,0.2,0.1),(0.05,0.02,0.11)]:
    partes.append(lumpy((x,y,0.06+r*0.75),r,0.85,random.choice(CORES),2,0.1))
topo=lambda d: 0.03+0.099*math.sqrt(max(0.0,1-(d/0.55)**2))
# detalhes: bolinhas pequenas meio enterradas, grãos escuros e pontinhos de areia clara no solo
for i in range(14):
    ang=random.uniform(0,6.28); d=random.uniform(0.25,0.48); r=random.uniform(0.035,0.07)
    partes.append(lumpy((math.cos(ang)*d,math.sin(ang)*d,topo(d)+r*0.35),r,0.8,random.choice(CORES),1,0.12))
GRAO=mat("hematita-grao","#4E3630"); AREIA=mat("hematita-areia","#A27A62")
for i in range(22):
    ang=random.uniform(0,6.28); d=random.uniform(0.05,0.5); r=random.uniform(0.015,0.03)
    partes.append(lumpy((math.cos(ang)*d,math.sin(ang)*d,topo(d)+r*0.2),r,0.6,random.choice([GRAO,AREIA]),1,0.2))
bpy.ops.object.select_all(action='DESELECT')
for o in partes: o.select_set(True)
bpy.context.view_layer.objects.active=partes[0]; bpy.ops.object.join(); o=bpy.context.object; o.name='hematita'
bpy.ops.object.transform_apply(scale=True)
bpy.ops.export_scene.gltf(filepath=OUT, export_format='GLB')
if PREV:
    sc=bpy.context.scene; sc.render.engine='CYCLES'; sc.cycles.samples=32; sc.render.resolution_x=sc.render.resolution_y=500
    sc.world=bpy.data.worlds.new('w'); sc.world.use_nodes=True; sc.world.node_tree.nodes['Background'].inputs[0].default_value=(0.45,0.3,0.18,1)
    bpy.ops.object.light_add(type='SUN',rotation=(0.8,0.2,-0.6)); bpy.context.object.data.energy=3.5
    bpy.ops.object.camera_add(location=(-1.3,-1.6,1.1)); c=bpy.context.object; sc.camera=c
    e=bpy.data.objects.new('t',None); e.location=(0,0,0.12); sc.collection.objects.link(e); c.constraints.new('TRACK_TO').target=e
    sc.render.filepath=PREV; bpy.ops.render.render(write_still=True)
print('DONE')
