## Construções do Mike on Mars em 3 níveis (casa do Mike, estufa, painel solar).
## Uso: blender --background --python construcoes.py -- <pasta-de-saida>
import bpy, sys, math, bmesh, random
from mathutils import Vector

OUT = sys.argv[sys.argv.index("--") + 1]


def srgb(h):
    return tuple(((int(h[i:i + 2], 16) / 255 + 0.055) / 1.055) ** 2.4 for i in (1, 3, 5))


M = {}
parts = []


def mat(n, h, metal=0.0, rough=0.7, emit=0.0, alpha=1.0):
    m = bpy.data.materials.new(n); m.use_nodes = True; b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*srgb(h), 1); b.inputs["Metallic"].default_value = metal; b.inputs["Roughness"].default_value = rough
    if emit:
        b.inputs["Emission Color"].default_value = (*srgb(h), 1); b.inputs["Emission Strength"].default_value = emit
    if alpha < 1:
        b.inputs["Alpha"].default_value = alpha
        if hasattr(m, "surface_render_method"): m.surface_render_method = "BLENDED"
        if hasattr(m, "blend_method"): m.blend_method = "BLEND"
    return m


def reset():
    global parts
    bpy.ops.wm.read_factory_settings(use_empty=True); parts = []
    M.update(BRANCO=mat("branco", "#F4F4F8"), CREME=mat("creme", "#F2D091"), OURO=mat("ouro", "#E8B23A", 0.3, 0.4),
             VINHO=mat("vinho", "#73242A"), AZUL=mat("vidro-azul", "#3FA7C9", 0.1, 0.15), CINZA=mat("cinza", "#C9CCD6"),
             LUZ=mat("luz", "#F2D091", 0, 0.5, 6), ESCURO=mat("escuro", "#3A1418"), TERRA=mat("terra", "#5A3825"),
             VIDRO=mat("vidro", "#CFEFFF", 0.0, 0.05, 0, 0.32), FOLHA=mat("folha", "#3E8E4A"), FOLHA2=mat("folha2", "#2F6E3A"),
             FRUTO=mat("fruto", "#D62828", 0, 0.35), FRUTO2=mat("fruto2", "#F7D53C", 0, 0.35), CELULA=mat("celula", "#3A1418", 0.2, 0.3),
             VERDE=mat("luz-cultivo", "#F2935C", 0, 0.5, 4))


def add(kind, loc, scale=(1, 1, 1), rot=(0, 0, 0), m=None, **kw):
    getattr(bpy.ops.mesh, "primitive_%s_add" % kind)(location=loc, rotation=[math.radians(r) for r in rot], **kw)
    o = bpy.context.active_object; o.scale = scale
    if m: o.data.materials.append(M[m])
    parts.append(o); return o


def cil_deitado(c, ang_z, raio, comp, m, v=12):
    o = add("cylinder", c, m=m, vertices=v, radius=raio, depth=comp); o.rotation_euler = (0, math.radians(90), math.radians(ang_z)); return o


def cupula(c, raio, achatar, m, seg=12):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=8, radius=raio, location=c)
    d = bpy.context.active_object; bm = bmesh.new(); bm.from_mesh(d.data)
    bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.z < -0.01], context="VERTS"); bm.to_mesh(d.data); bm.free()
    d.scale = (1, 1, achatar); d.data.materials.append(M[m]); parts.append(d); return d


def texto(t, loc, size, m):
    bpy.ops.object.text_add(location=loc, rotation=(math.radians(90), 0, 0))
    o = bpy.context.active_object; o.data.body = t; o.data.align_x = "CENTER"; o.data.align_y = "CENTER"; o.data.size = size; o.data.extrude = 0.02
    o.data.materials.append(M[m]); bpy.ops.object.convert(target="MESH"); parts.append(bpy.context.active_object)


def arbusto(c, r, fruto=None):
    random.seed(int(c[0] * 100 + c[1] * 10))
    for i in range(4):
        off = Vector((random.uniform(-.5, .5), random.uniform(-.5, .5), random.uniform(0, .4))) * r
        o = add("ico_sphere", Vector(c) + off + Vector((0, 0, r * .6)), m=("FOLHA" if i % 2 else "FOLHA2"), subdivisions=1, radius=r * .6)
        o.scale = (1, 1, .85)
    if fruto:
        for i in range(5):
            a = i * 1.3; add("uv_sphere", Vector(c) + Vector((math.cos(a) * r * .55, math.sin(a) * r * .55, r * (.5 + .25 * (i % 2)))), m=fruto, segments=6, ring_count=4, radius=r * .12)


def salvar(nome, escala=1.0):
    bpy.ops.object.select_all(action="DESELECT")
    for o in parts: o.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True); bpy.ops.object.shade_flat(); bpy.ops.object.join()
    o = bpy.context.active_object; o.name = nome; o.scale = (escala,) * 3; bpy.ops.object.transform_apply(scale=True)
    bpy.ops.export_scene.gltf(filepath=OUT + "/" + nome + ".glb", export_format="GLB")
    print("EXPORT", nome, [round(x, 1) for x in o.dimensions])


# ------------------------------------------------------------------ casa do Mike
def casa(n):
    reset()
    R, H, Z0 = (2.6, 2.6, 0.5) if n == 1 else (3.2, 3.0, 0.6)
    add("cylinder", (0, 0, Z0 - .15), m="VINHO", vertices=8, radius=R + 1.0, depth=.3)
    add("cylinder", (0, 0, Z0 - .32), m="OURO", vertices=8, radius=R + 1.05, depth=.06)
    for i in range(8):
        a = i * math.pi / 4 + math.pi / 8
        add("cylinder", (math.cos(a) * (R + .6), math.sin(a) * (R + .6), Z0 * .5 - .2), m="OURO", vertices=6, radius=.14, depth=Z0 + .1)
    add("cylinder", (0, 0, Z0 + H / 2), m="BRANCO", vertices=12, radius=R, depth=H)
    for z in (Z0 + .12, Z0 + H - .1): add("cylinder", (0, 0, z), m="OURO", vertices=12, radius=R + .06, depth=.22)
    if n >= 2: add("cylinder", (0, 0, Z0 + H * .55), m="CREME", vertices=12, radius=R + .03, depth=.5)
    cupula((0, 0, Z0 + H), R * .98, .55, "BRANCO")
    topo = Z0 + H + R * .98 * .55
    if n >= 2:
        add("cylinder", (0, 0, topo - .05), m="OURO", vertices=12, radius=.95, depth=.16)
        add("cylinder", (0, 0, topo + .02), m="AZUL", vertices=12, radius=.8, depth=.12)
    if n == 3:  # anel de observação de vidro em volta da cúpula
        add("cylinder", (0, 0, Z0 + H + .45), m="AZUL", vertices=12, radius=R * .93, depth=.6)
        add("cylinder", (0, 0, Z0 + H + .8), m="OURO", vertices=12, radius=R * .95, depth=.12)
        add("cylinder", (0, 0, Z0 + H + .1), m="OURO", vertices=12, radius=R * .97, depth=.12)
    janelas = {1: (-35, 35), 2: (-35, 35, 150, 210), 3: (-35, 35, 90, 150, 210, 270)}[n]
    for a_deg in janelas:
        a = math.radians(a_deg - 90); p = Vector((math.cos(a), math.sin(a), 0))
        for m, rr, dd, off in (("OURO", .62, .16, .02), ("AZUL", .48, .12, .08)):
            o = add("cylinder", (p.x * (R + off), p.y * (R + off), Z0 + H * .58), m=m, vertices=12, radius=rr * (.85 if n == 1 else 1), depth=dd)
            o.rotation_euler = (math.radians(90), 0, a + math.pi / 2)
    ay = -(R + .9)
    add("cube", (0, ay, Z0 + 1.15), (1.15, 1.0, 1.15), m="BRANCO")
    o = add("cylinder", (0, ay, Z0 + 2.3), (1.15, 1.0, 1.0), m="BRANCO", vertices=12, radius=1, depth=2.0); o.rotation_euler = (math.radians(90), 0, 0)
    o = add("cylinder", (0, ay - 1.0, Z0 + 2.3), m="OURO", vertices=12, radius=1.2, depth=.14); o.rotation_euler = (math.radians(90), 0, 0)
    add("cube", (0, ay - 1.02, Z0 + 1.15), (1.22, .07, 1.15), m="OURO")
    add("cube", (0, ay - 1.08, Z0 + 1.25), (.72, .06, 1.2), m="VINHO")
    add("cube", (0, ay - 1.13, Z0 + 1.25), (.05, .03, 1.05), m="OURO")
    add("cube", (.5, ay - 1.14, Z0 + 1.3), (.06, .04, .25), m="OURO")
    add("cube", (0, ay - 1.1, Z0 + 2.85), (.62, .05, .22), m="VINHO")
    texto("MIKE", (0, ay - 1.17, Z0 + 2.85), .3, "CREME")
    add("cube", (0, ay - 1.9, Z0 * .5), (1.0, .95, Z0 * .5), m="CINZA")
    add("cube", (0, ay - 2.6, Z0 * .25), (1.0, .5, Z0 * .25), m="CINZA")
    if n >= 2:
        for x in (-.9, .9): add("cylinder", (x, ay - 1.25, Z0 + 2.45), m="LUZ", vertices=8, radius=.1, depth=.1)
    laterais = [] if n == 1 else ([(1, 20)] if n == 2 else [(1, 20), (-1, -20)])
    for lado, ang in laterais:
        c = Vector((lado * (R + 1.7), .8, Z0 + 1.1)); d = Vector((math.cos(math.radians(ang)), math.sin(math.radians(ang)), 0)) * lado
        cil_deitado(c, ang, 1.1, 3.2, "BRANCO")
        for dx in (-1.3, 1.3): cil_deitado(c + d * dx, ang, 1.17, .18, "OURO")
        cil_deitado(c + d * 1.65, ang, .9, .1, "CREME")
        if n == 3:  # asas solares no módulo lateral
            for s in (-1, 1):
                p = add("cube", c + Vector((0, 0, 1.25)) + Vector((-d.y, d.x, 0)) * s * 1.6, (1.4, .9, .05), m="OURO"); p.rotation_euler = (0, 0, math.radians(ang))
                q = add("cube", c + Vector((0, 0, 1.31)) + Vector((-d.y, d.x, 0)) * s * 1.6, (1.3, .8, .03), m="CELULA"); q.rotation_euler = (0, 0, math.radians(ang))
            add("cylinder", c + Vector((0, 0, .9)), m="OURO", vertices=6, radius=.08, depth=.6)
    add("cylinder", (1.3, 1.0, topo + (0 if n == 1 else 0)), m="CINZA", vertices=6, radius=.06, depth=1.8 if n < 3 else 2.6)
    add("uv_sphere", (1.3, 1.0, topo + (.95 if n < 3 else 1.35)), m="LUZ", segments=8, ring_count=6, radius=.16 if n < 3 else .24)
    if n >= 2:
        o = add("cone", (-1.4, .9, topo + .05), m="CINZA", vertices=10, radius1=.6 if n == 2 else 1.0, radius2=.1, depth=.35 if n == 2 else .5)
        o.rotation_euler = (math.radians(-30), 0, 0)
    if n == 3:
        for i in range(4):  # luzes de pouso em volta da plataforma
            a = i * math.pi / 2 + math.pi / 4
            add("cylinder", (math.cos(a) * (R + .95), math.sin(a) * (R + .95), Z0 + .05), m="LUZ", vertices=8, radius=.14, depth=.12)
    salvar("casa-do-mike-n%d" % n, 1.5)


# ------------------------------------------------------------------ estufa
def estufa(n):
    reset()
    if n == 1:
        add("cylinder", (0, 0, .15), m="VINHO", vertices=10, radius=2.6, depth=.3)
        add("cylinder", (0, 0, .32), m="OURO", vertices=10, radius=2.45, depth=.06)
        add("cylinder", (0, 0, .6), m="CREME", vertices=12, radius=2.2, depth=.6)
        add("cylinder", (0, 0, .92), m="OURO", vertices=12, radius=2.26, depth=.1)
        add("cylinder", (0, 0, .92), m="TERRA", vertices=12, radius=2.05, depth=.12)
        for i, a in enumerate((0, 2.1, 4.2)): arbusto((math.cos(a) * 1.0, math.sin(a) * 1.0, .95), .7, "FRUTO" if i == 0 else None)
        cupula((0, 0, .95), 2.15, .9, "VIDRO")
        add("cylinder", (0, 0, .95 + 2.15 * .9), m="OURO", vertices=8, radius=.25, depth=.12)
        o = add("cube", (0, -2.2, 1.0), (.55, .12, .65), m="OURO")
        salvar("estufa-n1", 1.5); return
    comp = 7.0 if n == 2 else 10.0; R = 2.2 if n == 2 else 2.5
    add("cube", (0, 0, .15), (comp / 2 + .6, R + .6, .15), m="VINHO")
    add("cube", (0, 0, .32), (comp / 2 + .45, R + .45, .03), m="OURO")
    for s in (-1, 1): add("cube", (0, s * R, .65), (comp / 2, .12, .35), m="CREME")
    for s in (-1, 1): add("cube", (s * comp / 2, 0, .65), (.12, R, .35), m="CREME")
    o = add("cylinder", (0, 0, 1.0), (1, 1, 1), m="VIDRO", vertices=16, radius=R, depth=comp); o.rotation_euler = (0, math.radians(90), 0)
    bm_cut = o  # metade de baixo do túnel fica escondida pela mureta; tudo bem no low-poly
    arcos = 5 if n == 2 else 7
    for i in range(arcos):
        x = -comp / 2 + i * comp / (arcos - 1)
        a = add("torus", (x, 0, 1.0), (1, 1, 1), m="OURO", major_radius=R + .02, minor_radius=.07, major_segments=16, minor_segments=6); a.rotation_euler = (0, math.radians(90), 0)
    for s in (-1, 1):  # canteiros
        add("cube", (0, s * R * .5, .55), (comp / 2 - .4, R * .32, .25), m="TERRA")
        add("cube", (0, s * R * .5, .32), (comp / 2 - .3, R * .36, .05), m="OURO")
        k = 4 if n == 2 else 6
        for j in range(k):
            x = -comp / 2 + .9 + j * (comp - 1.8) / (k - 1)
            arbusto((x, s * R * .5, .8), .55, ("FRUTO" if (j + (s > 0)) % 2 else "FRUTO2") if n == 3 else (("FRUTO" if j % 2 else None)))
    add("cube", (0, 0, 1.0 + R * .82), (comp / 2 - .5, .08, .04), m="VERDE")  # luz de cultivo
    for s in (-1, 1):  # portas nas pontas
        add("cube", (s * (comp / 2 + .05), 0, 1.0), (.08, .7, .9), m="OURO")
        add("cube", (s * (comp / 2 + .1), 0, 1.0), (.05, .55, .8), m="VINHO")
    if n == 3:
        add("cylinder", (0, 0, .9), m="CREME", vertices=12, radius=R + .3, depth=.5)
        cupula((0, 0, 1.15), R + .4, 1.0, "VIDRO", 14)
        add("torus", (0, 0, 1.15), m="OURO", major_radius=R + .42, minor_radius=.09, major_segments=16, minor_segments=6)
        add("cylinder", (0, 0, 1.15 + R + .4), m="OURO", vertices=8, radius=.35, depth=.18)
        arbusto((0, 0, 1.2), 1.1, "FRUTO2")
        for y in (R + 1.6,):  # caixa d'água
            add("cylinder", (comp / 2 - 1.2, y, 1.3), m="AZUL", vertices=12, radius=.8, depth=2.2)
            for z in (.5, 2.1): add("cylinder", (comp / 2 - 1.2, y, z), m="OURO", vertices=12, radius=.84, depth=.12)
            o = add("cylinder", (comp / 2 - 1.2, y - .9, .9), m="CINZA", vertices=6, radius=.08, depth=1.4); o.rotation_euler = (math.radians(90), 0, 0)
    salvar("estufa-n%d" % n, 1.5)


# ------------------------------------------------------------------ painel solar
def painel_um(x, y, z, larg, prof, incl=25):
    add("cube", (x, y, z), (larg, prof, .03), (incl, 0, 0), "OURO")
    add("cube", (x, y - .012, z + .015), (larg - .04, prof - .04, .02), (incl, 0, 0), "CELULA")
    for i in range(1, 4):
        xi = x - larg + i * 2 * larg / 4
        add("cube", (xi, y - .02, z + .03), (.012, prof - .04, .012), (incl, 0, 0), "VINHO")


def painel(n):
    reset()
    if n == 1:
        add("cube", (0, 0, .12), (.12, .12, .12), m="CINZA")
        add("cylinder", (0, 0, .45), m="OURO", vertices=8, radius=.04, depth=.7)
        painel_um(0, 0, .85, .62, .42)
        salvar("painel-solar-n1", 1.6); return
    if n == 2:
        add("cube", (0, 0, .1), (.8, .25, .1), m="CINZA")
        for x in (-.6, .6): add("cylinder", (x, 0, .55), m="OURO", vertices=8, radius=.05, depth=.9)
        add("cube", (0, 0, 1.0), (1.35, .05, .05), m="OURO")
        for x in (-.66, .66): painel_um(x, 0, 1.1, .62, .45)
        add("cube", (0, -.05, 1.32), (1.3, .03, .03), (25, 0, 0), "CREME")  # escovinha de limpar poeira
        salvar("painel-solar-n2", 1.6); return
    add("cube", (0, 0, .1), (1.5, .45, .1), m="CINZA")
    for x in (-1.0, 1.0):
        add("cylinder", (x, 0, .7), m="OURO", vertices=8, radius=.07, depth=1.2)
        add("uv_sphere", (x, 0, 1.3), m="OURO", segments=8, ring_count=6, radius=.13)  # junta que segue o Sol
    add("cube", (0, 0, 1.35), (2.1, .06, .06), m="OURO")
    for x in (-1.32, 0, 1.32):
        for dy, dz in ((-.42, 1.32), (.42, 1.7)): painel_um(x, dy, dz, .64, .44)
    add("cube", (0, .9, .45), (.6, .35, .35), m="CREME")  # bateria
    add("cube", (0, .9, .62), (.62, .37, .05), m="OURO")
    add("cube", (0, .54, .45), (.3, .02, .08), m="LUZ")
    salvar("painel-solar-n3", 1.6)


for n in (1, 2, 3):
    casa(n); estufa(n); painel(n)
print("DONE")
