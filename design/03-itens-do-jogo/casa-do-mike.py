import bpy, sys, math, bmesh
from mathutils import Vector
out = sys.argv[sys.argv.index("--")+1]
bpy.ops.wm.read_factory_settings(use_empty=True)
def srgb(h): return tuple(((int(h[i:i+2],16)/255+0.055)/1.055)**2.4 for i in (1,3,5))
def mat(n, h, metal=0.0, rough=0.7, emit=0.0):
    m = bpy.data.materials.new(n); m.use_nodes = True; b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*srgb(h),1); b.inputs["Metallic"].default_value = metal; b.inputs["Roughness"].default_value = rough
    if emit: b.inputs["Emission Color"].default_value = (*srgb(h),1); b.inputs["Emission Strength"].default_value = emit
    return m
BRANCO, CREME, OURO, VINHO = mat("branco","#F4F4F8"), mat("creme","#F2D091"), mat("ouro","#E8B23A",0.3,0.4), mat("vinho","#73242A")
VIDRO, CINZA, LUZ, ESCURO = mat("vidro","#3FA7C9",0.1,0.15), mat("cinza","#C9CCD6"), mat("luz","#F2D091",0,0.5,6), mat("escuro","#3A1418")
parts = []
def add(kind, loc, scale=(1,1,1), rot=(0,0,0), m=None, **kw):
    getattr(bpy.ops.mesh, "primitive_%s_add" % kind)(location=loc, rotation=[math.radians(r) for r in rot], **kw)
    o = bpy.context.active_object; o.scale = scale
    if m: o.data.materials.append(m)
    parts.append(o); return o
R = 3.2; H = 3.0; Z0 = 0.6   # raio e altura do módulo principal; altura da plataforma
# plataforma com pés
add("cylinder", (0,0,Z0-0.15), m=VINHO, vertices=8, radius=R+1.0, depth=0.3)
add("cylinder", (0,0,Z0-0.32), m=OURO, vertices=8, radius=R+1.05, depth=0.06)
for i in range(8):
    a = i*math.pi/4 + math.pi/8
    add("cylinder", (math.cos(a)*(R+0.6), math.sin(a)*(R+0.6), Z0*0.5-0.2), m=OURO, vertices=6, radius=0.14, depth=Z0+0.1)
    add("cylinder", (math.cos(a)*(R+0.6), math.sin(a)*(R+0.6), 0.04), m=CINZA, vertices=6, radius=0.3, depth=0.08)
# módulo principal + faixas douradas
add("cylinder", (0,0,Z0+H/2), m=BRANCO, vertices=12, radius=R, depth=H)
for z in (Z0+0.12, Z0+H-0.1): add("cylinder", (0,0,z), m=OURO, vertices=12, radius=R+0.06, depth=0.22)
add("cylinder", (0,0,Z0+H*0.55), m=CREME, vertices=12, radius=R+0.03, depth=0.5)
# cúpula
bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=R*0.98, location=(0,0,Z0+H))
d = bpy.context.active_object; bm = bmesh.new(); bm.from_mesh(d.data)
bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.z < -0.01], context="VERTS"); bm.to_mesh(d.data); bm.free()
d.scale = (1,1,0.55); d.data.materials.append(BRANCO); parts.append(d)
add("cylinder", (0,0,Z0+H+R*0.98*0.55-0.05), m=OURO, vertices=12, radius=0.95, depth=0.16)
add("cylinder", (0,0,Z0+H+R*0.98*0.55+0.02), m=VIDRO, vertices=12, radius=0.8, depth=0.12)
# escotilhas (janelas redondas)
for a_deg in (-35, 35, 150, 210):
    a = math.radians(a_deg - 90); p = Vector((math.cos(a), math.sin(a), 0))
    rot = (90, 0, a_deg)
    o = add("cylinder", (p.x*(R+0.02), p.y*(R+0.02), Z0+H*0.58), m=OURO, vertices=12, radius=0.62, depth=0.16); o.rotation_euler = (math.radians(90), 0, a + math.pi/2)
    o = add("cylinder", (p.x*(R+0.08), p.y*(R+0.08), Z0+H*0.58), m=VIDRO, vertices=12, radius=0.48, depth=0.12); o.rotation_euler = (math.radians(90), 0, a + math.pi/2)
# câmara de entrada (airlock) na frente (-Y)
ay = -(R + 0.9)
add("cube", (0, ay, Z0+1.15), (1.15, 1.0, 1.15), m=BRANCO)
o = add("cylinder", (0, ay, Z0+2.3), (1.15, 1.0, 1.0), m=BRANCO, vertices=12, radius=1, depth=2.0); o.rotation_euler = (math.radians(90), 0, 0)
o = add("cylinder", (0, ay-1.0, Z0+2.3), m=OURO, vertices=12, radius=1.2, depth=0.14); o.rotation_euler = (math.radians(90), 0, 0); o.scale = (1.0, 1.0, 1.0)
add("cube", (0, ay-1.02, Z0+1.15), (1.22, 0.07, 1.15), m=OURO)
add("cube", (0, ay-1.08, Z0+1.25), (0.72, 0.06, 1.2), m=VINHO)            # porta
add("cube", (0, ay-1.13, Z0+1.25), (0.05, 0.03, 1.05), m=OURO)            # fresta da porta
add("cube", (0.5, ay-1.14, Z0+1.3), (0.06, 0.04, 0.25), m=OURO)           # puxador
add("cube", (0, ay-1.1, Z0+2.85), (0.62, 0.05, 0.22), m=VINHO)            # placa
bpy.ops.object.text_add(location=(0, ay-1.17, Z0+2.85), rotation=(math.radians(90), 0, 0))
t = bpy.context.active_object; t.data.body = "MIKE"; t.data.align_x = "CENTER"; t.data.align_y = "CENTER"; t.data.size = 0.3; t.data.extrude = 0.02
t.data.materials.append(CREME); bpy.ops.object.convert(target="MESH"); parts.append(bpy.context.active_object)
add("cube", (0, ay-1.9, Z0*0.5), (1.0, 0.95, Z0*0.5), m=CINZA)            # rampa (degrau)
o = add("cube", (0, ay-2.6, Z0*0.25), (1.0, 0.5, Z0*0.25), m=CINZA)
for x in (-0.9, 0.9): add("cylinder", (x, ay-1.25, Z0+2.45), m=LUZ, vertices=8, radius=0.1, depth=0.1)  # luzinhas da porta
# módulo lateral deitado (laboratório/depósito) à direita
o = add("cylinder", (R+1.7, 0.8, Z0+1.1), m=BRANCO, vertices=12, radius=1.1, depth=3.2); o.rotation_euler = (0, math.radians(90), math.radians(20))
for dx in (-1.3, 1.3):
    c = Vector((R+1.7, 0.8, Z0+1.1)) + Vector((math.cos(math.radians(20)), math.sin(math.radians(20)), 0))*dx
    o = add("cylinder", c, m=OURO, vertices=12, radius=1.17, depth=0.18); o.rotation_euler = (0, math.radians(90), math.radians(20))
c = Vector((R+1.7, 0.8, Z0+1.1)) + Vector((math.cos(math.radians(20)), math.sin(math.radians(20)), 0))*1.65
o = add("cylinder", c, m=CREME, vertices=12, radius=0.9, depth=0.1); o.rotation_euler = (0, math.radians(90), math.radians(20))
# antena e luz no topo
top = Z0 + H + R*0.98*0.55
add("cylinder", (1.3, 1.0, top), m=CINZA, vertices=6, radius=0.06, depth=1.8)
add("uv_sphere", (1.3, 1.0, top+0.95), m=LUZ, segments=8, ring_count=6, radius=0.16)
o = add("cone", (-1.4, 0.9, top+0.05), m=CINZA, vertices=10, radius1=0.6, radius2=0.1, depth=0.35); o.rotation_euler = (math.radians(-30), 0, 0)
# junta tudo
bpy.ops.object.select_all(action="DESELECT")
for o in parts: o.select_set(True)
bpy.context.view_layer.objects.active = parts[0]
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True); bpy.ops.object.shade_flat(); bpy.ops.object.join()
o = bpy.context.active_object; o.name = "casa-do-mike"; o.scale = (1.5, 1.5, 1.5); bpy.ops.object.transform_apply(scale=True)
bpy.ops.export_scene.gltf(filepath=out, export_format="GLB"); print("EXPORT", [round(x,2) for x in bpy.context.active_object.dimensions])
