## Níveis 2 e 3 (e o 1 da plataforma) de MOXIE, RTG, antena, plataforma de pouso, bandeira, luzinhas e vaso.
## Uso: blender --background --python niveis2.py -- <pasta-do-repo-design> <pasta-de-saida>
import bpy, sys, math, random
from mathutils import Vector

DES, OUT = sys.argv[sys.argv.index("--") + 1:]
BASES = {"moxie": DES + "/04-cores-das-coisas/moxie.glb", "rtg": DES + "/03-itens-do-jogo/kenney/machine-barrel.glb",
         "decoracao-antena": DES + "/03-itens-do-jogo/kenney/satellite-dish.glb", "decoracao-bandeira": DES + "/03-itens-do-jogo/decoracao-bandeira.glb",
         "decoracao-luzinhas": DES + "/03-itens-do-jogo/decoracao-luzinhas.glb", "decoracao-vaso": DES + "/04-cores-das-coisas/decoracao-vaso.glb"}


def srgb(h):
    return tuple(((int(h[i:i + 2], 16) / 255 + 0.055) / 1.055) ** 2.4 for i in (1, 3, 5))


M = {}


def mat(n, h, metal=0.0, rough=0.7, emit=0.0):
    m = bpy.data.materials.new(n); m.use_nodes = True; b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*srgb(h), 1); b.inputs["Metallic"].default_value = metal; b.inputs["Roughness"].default_value = rough
    if emit: b.inputs["Emission Color"].default_value = (*srgb(h), 1); b.inputs["Emission Strength"].default_value = emit
    return m


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    M.update(BRANCO=mat("branco", "#F4F4F8"), CREME=mat("creme", "#F2D091"), OURO=mat("ouro", "#E8B23A", 0.3, 0.4), VINHO=mat("vinho", "#73242A"),
             AZUL=mat("azul", "#3FA7C9", 0.1, 0.2), CINZA=mat("cinza", "#C9CCD6"), ESCURO=mat("escuro", "#3A1418"), LUZ=mat("luz", "#F2D091", 0, .5, 6),
             LUZ2=mat("luz2", "#F2935C", 0, .5, 6), LUZ3=mat("luz3", "#3FA7C9", 0, .5, 5), FOLHA=mat("folha", "#3E8E4A"), FOLHA2=mat("folha2", "#2F6E3A"),
             FLOR=mat("flor", "#D62828"), FLOR2=mat("flor2", "#F7D53C"), TERRA=mat("terra", "#5A3825"), CONCRETO=mat("concreto", "#B9A99A"))


def base(nome):
    if nome not in BASES: return Vector((0, 0, 0)), Vector((1, 1, 1))
    bpy.ops.import_scene.gltf(filepath=BASES[nome]); bpy.context.view_layer.update()
    pts = [o.matrix_world @ Vector(c) for o in bpy.data.objects if o.type == "MESH" for c in o.bound_box]
    mn = Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts))); mx = Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    return mn, mx


def add(kind, loc, scale=(1, 1, 1), rot=(0, 0, 0), m=None, **kw):
    getattr(bpy.ops.mesh, "primitive_%s_add" % kind)(location=loc, rotation=[math.radians(r) for r in rot], **kw)
    o = bpy.context.active_object; o.scale = scale
    if m: o.data.materials.append(M[m])
    return o


def salvar(nome):
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=OUT + "/" + nome + ".glb", export_format="GLB")
    pts = [o.matrix_world @ Vector(c) for o in bpy.data.objects if o.type == "MESH" for c in o.bound_box]
    print("EXPORT", nome, [round(max(p[i] for p in pts) - min(p[i] for p in pts), 2) for i in range(3)])


def faixa(c, r, z, m="OURO", h=.06, v=16): return add("cylinder", (c.x, c.y, z), m=m, vertices=v, radius=r, depth=h)


def tanque(c, r, h, z0=0.0):
    add("cylinder", (c.x, c.y, z0 + h / 2), m="CREME", vertices=14, radius=r, depth=h)
    add("uv_sphere", (c.x, c.y, z0 + h), (1, 1, .6), m="CREME", segments=14, ring_count=8, radius=r)
    for z in (z0 + h * .2, z0 + h * .8): faixa(c, r * 1.04, z)
    add("cylinder", (c.x, c.y, z0 + h * .5), m="LUZ3", vertices=8, radius=r * .18, depth=.02).location.x += 0  # visor


def arbusto(c, r, flores=None):
    random.seed(int(abs(c.x) * 100 + abs(c.y) * 10 + r * 100))
    for i in range(5):
        off = Vector((random.uniform(-.5, .5), random.uniform(-.5, .5), random.uniform(0, .4))) * r
        o = add("ico_sphere", c + off + Vector((0, 0, r * .55)), m=("FOLHA" if i % 2 else "FOLHA2"), subdivisions=1, radius=r * .55); o.scale = (1, 1, .85)
    if flores:
        for i in range(6):
            a = i * 1.05; p = c + Vector((math.cos(a) * r * .5, math.sin(a) * r * .5, r * (.95 + .2 * (i % 2))))
            add("uv_sphere", p, (1, 1, .6), m=(flores[i % len(flores)]), segments=8, ring_count=4, radius=r * .2)
            add("uv_sphere", p + Vector((0, 0, r * .06)), m="FLOR2", segments=6, ring_count=4, radius=r * .07)


# ------------------------------------------------------------------ MOXIE
def moxie(n):
    reset(); mn, mx = base("moxie"); c = (mn + mx) / 2; H = mx.z - mn.z; L = mx.x - mn.x; P = mx.y - mn.y
    if n >= 2:
        t = Vector((mx.x + L * .22, c.y, 0)); tanque(t, L * .18, H * 1.1)
        o = add("cylinder", (mx.x + L * .02, c.y, H * .55), m="OURO", vertices=8, radius=L * .04, depth=L * .3); o.rotation_euler = (0, math.radians(90), 0)
        add("uv_sphere", (c.x, c.y, mx.z + H * .08), m="LUZ3", segments=8, ring_count=6, radius=H * .08)
    if n == 3:
        add("cube", (c.x + L * .15, c.y, .04), (L * .85, P * .75, .04), m="VINHO")
        add("cube", (c.x + L * .15, c.y, .085), (L * .86, P * .76, .01), m="OURO")
        t2 = Vector((mn.x - L * .22, c.y, 0)); tanque(t2, L * .18, H * 1.1)
        o = add("cylinder", (mn.x - L * .02, c.y, H * .55), m="OURO", vertices=8, radius=L * .04, depth=L * .3); o.rotation_euler = (0, math.radians(90), 0)
        add("cylinder", (c.x - L * .15, c.y + P * .1, mx.z + H * .25), m="OURO", vertices=10, radius=L * .07, depth=H * .5)   # chaminé
        o = add("cone", (c.x + L * .18, c.y, mx.z + H * .22), m="CINZA", vertices=14, radius1=L * .2, radius2=L * .05, depth=H * .25)  # entrada de ar
        o.rotation_euler = (math.radians(180), 0, 0)
    salvar("moxie-n%d" % n)


# ------------------------------------------------------------------ RTG / Kilopower
def rtg(n):
    reset(); mn, mx = base("rtg"); c = (mn + mx) / 2; H = mx.z - mn.z; R = max(mx.x - mn.x, mx.y - mn.y) / 2
    if n >= 2:
        for i in range(8):  # aletas de resfriamento
            a = i * math.pi / 4
            o = add("cube", (c.x + math.cos(a) * R * .95, c.y + math.sin(a) * R * .95, H * .5), (R * .28, .02, H * .32), m="OURO"); o.rotation_euler = (0, 0, a)
        faixa(Vector((c.x, c.y, 0)), R * 1.25, .03, "VINHO", .06, 12)
    if n == 3:
        add("cylinder", (c.x, c.y, mx.z + H * .3), m="CINZA", vertices=8, radius=R * .12, depth=H * .6)
        o = add("cone", (c.x, c.y, mx.z + H * .62), m="OURO", vertices=16, radius1=R * 1.05, radius2=R * .12, depth=H * .3)  # radiador guarda-chuva
        o.rotation_euler = (math.radians(180), 0, 0)
        add("uv_sphere", (c.x, c.y, mx.z + H * .8), m="LUZ2", segments=8, ring_count=6, radius=R * .14)
        faixa(Vector((c.x, c.y, 0)), R * 1.3, .015, "OURO", .03, 16)
    salvar("rtg-n%d" % n)


# ------------------------------------------------------------------ antena
def antena(n):
    reset(); mn, mx = base("decoracao-antena"); c = (mn + mx) / 2; H = mx.z - mn.z; L = max(mx.x - mn.x, mx.y - mn.y)
    if n >= 2:
        add("cylinder", (mx.x + L * .08, c.y, H * .8), m="CINZA", vertices=6, radius=L * .025, depth=H * 1.6)
        o = add("cone", (mx.x + L * .08, c.y, H * 1.55), m="BRANCO", vertices=14, radius1=L * .18, radius2=L * .02, depth=L * .07); o.rotation_euler = (math.radians(-35), 0, 0)
        add("uv_sphere", (mx.x + L * .08, c.y, H * 1.65), m="LUZ", segments=8, ring_count=6, radius=L * .04)
    if n == 3:
        tx = mn.x - L * .2
        for dx in (-1, 1):
            for dy in (-1, 1):
                o = add("cylinder", (tx + dx * L * .06, c.y + dy * L * .06, H * .9), m="OURO", vertices=6, radius=L * .015, depth=H * 1.8)
        for z in (H * .5, H * 1.1, H * 1.7): add("cube", (tx, c.y, z), (L * .07, L * .07, .015), m="OURO")
        add("cube", (tx, c.y, H * 1.82), (L * .1, L * .1, .03), m="OURO")
        o = add("cone", (tx, c.y - L * .05, H * 1.95), m="BRANCO", vertices=18, radius1=L * .3, radius2=L * .04, depth=L * .12); o.rotation_euler = (math.radians(-50), 0, 0)
        add("cylinder", (tx, c.y - L * .02, H * 1.88), m="CINZA", vertices=6, radius=L * .02, depth=L * .15)
        add("uv_sphere", (tx, c.y + L * .08, H * 1.95), m="LUZ2", segments=8, ring_count=6, radius=L * .04)
    salvar("decoracao-antena-n%d" % n)


# ------------------------------------------------------------------ plataforma de pouso (nova)
def plataforma(n):
    reset(); R = {1: 1.0, 2: 1.15, 3: 1.3}[n]
    add("cylinder", (0, 0, .05), m="CONCRETO", vertices=8, radius=R, depth=.1)
    add("cylinder", (0, 0, .102), m="VINHO", vertices=24, radius=R * .62, depth=.01)
    add("cylinder", (0, 0, .106), m="CONCRETO", vertices=24, radius=R * .52, depth=.01)
    for a in (0, 90): add("cube", (0, 0, .11), (R * .42, .045, .006), (0, 0, a), "OURO")   # marca de pouso (cruz)
    if n >= 2:
        for i in range(4 if n == 2 else 8):
            a = i * math.tau / (4 if n == 2 else 8) + math.pi / 8
            add("cylinder", (math.cos(a) * R * .9, math.sin(a) * R * .9, .14), m="LUZ" if i % 2 == 0 else "LUZ2", vertices=8, radius=.05, depth=.07)
    if n == 3:
        add("torus", (0, 0, .1), m="OURO", major_radius=R * 1.0, minor_radius=.03, major_segments=24, minor_segments=6)
        for a in (math.pi * .25, math.pi * 1.25):
            p = Vector((math.cos(a) * R * 1.12, math.sin(a) * R * 1.12, 0))
            add("cylinder", (p.x, p.y, .35), m="OURO", vertices=6, radius=.015, depth=.7)
            add("cube", (p.x + .1, p.y, .6), (.1, .01, .06), m="VINHO")
    salvar("plataforma-pouso-n%d" % n)


# ------------------------------------------------------------------ bandeira
def bandeira(n):
    reset(); mn, mx = base("decoracao-bandeira"); c = (mn + mx) / 2; H = mx.z - mn.z
    if n >= 2:
        add("cylinder", (0, 0, H * .62), m="OURO", vertices=8, radius=.028, depth=H * 1.24)   # mastro mais alto (no lugar do antigo)
        o = add("cone", (.25, 0, H * 1.08), (1.4, 1, 1), (90, 0, 0), "OURO", vertices=3, radius1=.2, depth=.02)  # 2ª flâmula dourada
        for i in range(3): add("ico_sphere", (c.x + (i - 1) * .12, c.y + .1, .05), m="CINZA", subdivisions=1, radius=.07)
    if n == 3:
        add("cube", (-.3, 0, H * 1.2), (.3, .01, .02), m="OURO")   # travessa do outro lado
        add("cube", (-.3, 0, H * 1.02), (.26, .012, .17), m="VINHO")  # estandarte
        add("cube", (-.3, -.014, H * 1.02), (.2, .005, .015), m="OURO")
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=.08, radius2=0, depth=.01, location=(0, 0, H * 1.3)); s = bpy.context.active_object
        s.rotation_euler = (math.radians(90), 0, 0); s.data.materials.append(M["OURO"])   # estrelinha no topo
        for dx in (-.15, .15): add("uv_sphere", (c.x + dx, c.y - .15, .04), m="LUZ", segments=8, ring_count=6, radius=.04)
    salvar("decoracao-bandeira-n%d" % n)


# ------------------------------------------------------------------ luzinhas
def luzinhas(n):
    reset(); mn, mx = base("decoracao-luzinhas"); c = (mn + mx) / 2; H = mx.z - mn.z; L = mx.x - mn.x
    def varal(x0, x1, y, z, flecha, k):
        pts = [Vector((x0 + (x1 - x0) * i / 24, y, z - flecha * math.sin(math.pi * i / 24))) for i in range(25)]
        for a, b in zip(pts, pts[1:]):
            d = b - a; o = add("cylinder", (a + b) / 2, (1, 1, 1), m="ESCURO", vertices=5, radius=.007, depth=d.length)
            o.rotation_mode = "QUATERNION"; o.rotation_quaternion = d.to_track_quat("Z", "Y")
        for i in range(1, k):
            p = pts[int(i * 24 / k)]; add("uv_sphere", p - Vector((0, 0, .05)), (1, 1, 1.3), m=("LUZ", "LUZ2", "LUZ3")[i % 3], segments=8, ring_count=6, radius=.035)
    if n >= 2:
        add("cylinder", (c.x, c.y + .45, H * .5), m="OURO", vertices=8, radius=.025, depth=H)
        add("uv_sphere", (c.x, c.y + .45, H * 1.02), m="OURO", segments=8, ring_count=6, radius=.04)
        varal(mn.x + .02, c.x, c.y + .22, H * .95, H * .18, 6); varal(c.x, mx.x - .02, c.y + .22, H * .95, H * .18, 6)
    if n == 3:
        for i in range(13):   # arco de luzes
            a = math.pi * i / 12; p = Vector((c.x + math.cos(a) * L * .45, c.y - .35, H * .2 + math.sin(a) * H * .9))
            add("uv_sphere", p, m=("LUZ", "LUZ2", "LUZ3")[i % 3], segments=8, ring_count=6, radius=.04)
            if i < 12:
                a2 = math.pi * (i + 1) / 12; q = Vector((c.x + math.cos(a2) * L * .45, c.y - .35, H * .2 + math.sin(a2) * H * .9)); d = q - p
                o = add("cylinder", (p + q) / 2, m="OURO", vertices=5, radius=.012, depth=d.length); o.rotation_mode = "QUATERNION"; o.rotation_quaternion = d.to_track_quat("Z", "Y")
        for x in (mn.x - .12, mx.x + .12):   # lanternas
            add("cylinder", (x, c.y, .35), m="OURO", vertices=6, radius=.02, depth=.7)
            add("cylinder", (x, c.y, .78), m="LUZ", vertices=6, radius=.07, depth=.14)
            add("cone", (x, c.y, .89), m="OURO", vertices=6, radius1=.09, radius2=.01, depth=.08)
    salvar("decoracao-luzinhas-n%d" % n)


# ------------------------------------------------------------------ vaso
def vaso(n):
    reset(); mn, mx = base("decoracao-vaso"); c = (mn + mx) / 2; H = mx.z - mn.z; R = (mx.x - mn.x) / 2
    if n >= 2:
        faixa(Vector((c.x, c.y, 0)), R * 1.02, H * .55, "OURO", H * .08, 16)
        arbusto(Vector((c.x, c.y, mx.z - H * .1)), R * .9)
    if n == 3:
        add("cube", (c.x, c.y, .05), (R * 1.25, R * 1.25, .05), m="VINHO")       # pedestal
        add("cube", (c.x, c.y, .102), (R * 1.27, R * 1.27, .008), m="OURO")
        arbusto(Vector((c.x, c.y, mx.z - H * .1)), R * 1.0, ["FLOR", "FLOR", "FLOR2"])
        for dx in (-1, 1):
            p = Vector((c.x + dx * R * 1.6, c.y, 0)); add("cylinder", (p.x, p.y, H * .25), m="CREME", vertices=10, radius=R * .45, depth=H * .5)
            faixa(p, R * .47, H * .48, "OURO", H * .05, 10); arbusto(Vector((p.x, p.y, H * .45)), R * .45, ["FLOR"])
    salvar("decoracao-vaso-n%d" % n)


for n in (1, 2, 3):
    moxie(n); rtg(n); antena(n); plataforma(n); bandeira(n); luzinhas(n); vaso(n)
print("DONE")
