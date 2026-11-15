# Pedras das descobertas (low-poly, cores chapadas por face, no estilo Kenney).
# Feito pelo time com IA (Claude), a partir de fotos da NASA (links no descobertas.md).
# Uso: blender -b -P descobertas.py -- PASTA_DE_SAIDA
import bpy, bmesh, sys, os, math, random
from mathutils import Vector, noise
out = os.path.abspath(sys.argv[sys.argv.index("--") + 1])
bpy.ops.wm.read_factory_settings(use_empty=True)

def lin(h): return tuple(((int(h[i:i+2], 16) / 255 + 0.055) / 1.055) ** 2.4 for i in (1, 3, 5))
MATS = {}
def mat(h, metal=0.0, rough=0.85):
    k = (h, metal, rough)
    if k not in MATS:
        m = bpy.data.materials.new(h); m.use_nodes = True
        b = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
        b.inputs["Base Color"].default_value = (*lin(h), 1)
        b.inputs["Metallic"].default_value = metal; b.inputs["Roughness"].default_value = rough
        m.diffuse_color = (*lin(h), 1); m.metallic = metal; m.roughness = rough
        MATS[k] = m
    return MATS[k]

def base_mesh(name, box, cuts=6, sub=3):
    me = bpy.data.meshes.new(name); bm = bmesh.new()
    if box:
        bmesh.ops.create_cube(bm, size=2)
        bmesh.ops.subdivide_edges(bm, edges=bm.edges[:], cuts=cuts, use_grid_fill=True)
    else:
        bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=1)
    bm.to_mesh(me); bm.free()
    o = bpy.data.objects.new(name, me); bpy.context.collection.objects.link(o)
    return o

def rock(name, size, seed, amp=0.15, freq=1.6, box=False, cuts=6, sub=3, top=None, taper=0.0):
    o = base_mesh(name, box, cuts, sub); vs = o.data.vertices
    off = Vector((seed * 1.7, seed * 3.1, seed * 5.3))
    for v in vs:
        p = v.co.copy()
        v.co = p * (1 + amp * noise.noise(p * freq + off))
        v.co.x *= size[0] * (1 - taper * (v.co.y + 1) / 2); v.co.y *= size[1]; v.co.z *= size[2]
    zs = [v.co.z for v in vs]; z0, z1 = min(zs), max(zs); cut = z0 + 0.12 * (z1 - z0)
    for v in vs:
        v.co.z = max(v.co.z, cut)
        if top: v.co.z = min(v.co.z, z0 + top * (z1 - z0) + 0.02 * noise.noise(v.co * 6 + off))
        v.co.z -= cut
    o.data.update(); return o

def pits(o, n, r, depth, seed):
    rnd = random.Random(seed); vs = o.data.vertices
    c = sum((v.co for v in vs), Vector()) / len(vs)
    up = [v.co.copy() for v in vs if v.co.z > c.z]
    centers = [rnd.choice(up) for _ in range(n)]
    for v in vs:
        for p in centers:
            d = (v.co - p).length
            if d < r: v.co -= (v.co - c).normalized() * depth * (1 - d / r)
    o.data.update(); return centers

def paint(o, fn):
    me = o.data; me.update(); me.materials.clear(); idx = {}
    for p in me.polygons:
        k = fn(p.center.copy(), p.normal.copy())
        if k not in idx: idx[k] = len(me.materials); me.materials.append(mat(*k))
        p.material_index = idx[k]; p.use_smooth = False

def near_planes(c, planes, w):
    return any(abs((c - Vector(p)).dot(Vector(n).normalized())) < w for p, n in planes)

def fit(o, h):
    zs = [v.co.z for v in o.data.vertices]; s = h / max(o.dimensions)
    for v in o.data.vertices: v.co *= s
    o.data.update()

def prism(name, pts, z0, z1, jitter=0.0, seed=0):
    rnd = random.Random(seed); bm = bmesh.new()
    bot = [bm.verts.new((x, y, z0)) for x, y in pts]
    top = [bm.verts.new((x, y, z1 + rnd.uniform(-jitter, jitter))) for x, y in pts]
    bm.faces.new(bot[::-1]); bm.faces.new(top)
    for i in range(len(pts)):
        j = (i + 1) % len(pts); bm.faces.new((bot[i], bot[j], top[j], top[i]))
    bmesh.ops.triangulate(bm, faces=bm.faces[:])
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    o = bpy.data.objects.new(name, me); bpy.context.collection.objects.link(o); return o

def blob(n, rx, ry, seed, rough=0.15, cx=0.0, cy=0.0, rot=0.0):
    rnd = random.Random(seed); out = []
    for i in range(n):
        a = 2 * math.pi * i / n; r = 1 + rnd.uniform(-rough, rough)
        x, y = rx * r * math.cos(a), ry * r * math.sin(a)
        out.append((cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot)))
    return out

def strip(name, cx, cy, ang, ln, w, z0, z1):
    dx, dy = math.cos(ang), math.sin(ang); px, py = -dy * w / 2, dx * w / 2
    a, b = (cx - dx * ln / 2, cy - dy * ln / 2), (cx + dx * ln / 2, cy + dy * ln / 2)
    return prism(name, [(a[0] + px, a[1] + py), (a[0] - px, a[1] - py), (b[0] - px, b[1] - py), (b[0] + px, b[1] + py)], z0, z1)

def two_tone(o, top, side, metal=0.0, rough=0.85):
    paint(o, lambda c, n: (top, metal, rough) if n.z > 0.5 else (side, metal, rough))

def join(name, objs):
    bpy.ops.object.select_all(action="DESELECT")
    for x in objs: x.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]; bpy.ops.object.join(); objs[0].name = name; return objs[0]

models = []

# 1. Veios brancos (Sheepbed, PIA16705): pilha de lajes claras, com veios brancos em cima e entre as camadas
parts = []; z = 0.0
LAJES = [(0.75, 0.55, 0.22, 0, 0, 0.0), (0.62, 0.46, 0.18, 0.05, -0.03, 0.25), (0.48, 0.36, 0.16, -0.04, 0.04, -0.2)]
for k, (rx, ry, h, cx, cy, rot) in enumerate(LAJES):
    pts = blob(9, rx, ry, 40 + k, 0.12, cx, cy, rot)
    s = prism(f"laje{k}", pts, z, z + h, 0.015, k); two_tone(s, "#C4A27E", "#9E7F60"); parts.append(s)
    if k < 2:  # veio branco entre as camadas (aparece como uma linha branca na lateral)
        v = prism(f"veio-camada{k}", blob(9, LAJES[k + 1][0] * 1.06, LAJES[k + 1][1] * 1.06, 41 + k, 0.12, *LAJES[k + 1][3:]), z + h - 0.02, z + h + 0.004); two_tone(v, "#F7F4EC", "#F7F4EC"); parts.append(v)
    for j, (ang, off) in enumerate([((0.35, 0.12), (2.3, -0.2), (1.1, 0.05))[k]]):
        v = strip(f"veio{k}{j}", cx + off * math.cos(ang + 1.57), cy + off * math.sin(ang + 1.57), ang + rot, 1.7 * min(rx, ry), 0.045, z + h - 0.01, z + h + 0.02); two_tone(v, "#F7F4EC", "#F7F4EC"); parts.append(v)
    z += h
models.append(join("veios-brancos", parts))

# 2. Rocknest 3 (PIA16452): rocha comprida e chata, em camadas cinza-azuladas, ponta fina à direita, pó em cima e frestas escuras na frente
contorno = [(-0.85, -0.22), (-0.3, -0.3), (0.4, -0.28), (0.95, -0.05), (0.6, 0.15), (0.0, 0.25), (-0.7, 0.22), (-0.92, 0.0)]
parts = []; z = 0.0
for k, (sc, dx, h) in enumerate([(1.0, 0.0, 0.17), (0.94, -0.05, 0.16), (0.86, -0.11, 0.15), (0.74, -0.2, 0.13)]):
    pts = [(x * sc + dx, y * sc) for x, y in contorno]
    s = prism(f"camada{k}", pts, z, z + h, 0.006, k)
    paint(s, (lambda kk: lambda c, n: ("#A3A7AE",) if n.z > 0.5 and kk == 3 else (("#6F7683",) if n.z > 0.5 else (("#5E6571",) if kk % 2 else ("#757C89",))))(k))
    parts.append(s); z += h
for j, x in enumerate((-0.45, -0.2, 0.05, 0.22, 0.38)):
    sl = strip(f"fresta{j}", x, -0.285, 0.0, 0.035, 0.05, 0.08 + 0.05 * (j % 2), 0.36); two_tone(sl, "#2E3238", "#2E3238"); parts.append(sl)
models.append(join("rocknest-3", parts))

# 3. Óxido de manganês (Windjana, PIA20752): lasca chata e angulosa, clara, com a mancha escura azulada em degradê
plate = [(-0.5, -0.35), (0.0, -0.42), (0.5, -0.3), (0.35, 0.05), (0.1, 0.45), (-0.15, 0.4), (-0.45, 0.05)]
p = prism("lasca", plate, 0.0, 0.2, 0.03, 3)
# textura com degradê: escuro azulado no meio -> azul -> bege da pedra (sem buraco)
S = 256; img = bpy.data.images.new("oxido-de-manganes-cor", S, S)
def srgb(h): return [int(h[i:i+2], 16) / 255 for i in (1, 3, 5)]
def mix(a, b, t): return [a[i] + (b[i] - a[i]) * t for i in range(3)]
CA, CB, CC, LADO = srgb("#2A3150"), srgb("#5A6990"), srgb("#D0AC84"), srgb("#A88160")
MX, MY, UV0, UVS = -0.02, -0.06, -0.6, 1.2
px = []
for j in range(S):
    for i in range(S):
        if i >= S - 16 and j >= S - 16: col = LADO
        else:
            x = UV0 + UVS * i / (S - 17); y = UV0 + UVS * j / (S - 17)
            xr = (x - MX) * math.cos(0.4) + (y - MY) * math.sin(0.4); yr = -(x - MX) * math.sin(0.4) + (y - MY) * math.cos(0.4)
            d = math.hypot(xr / 1.25, yr) + 0.05 * noise.noise(Vector((x * 6, y * 6, 0.5)))
            t = min(max((d - 0.04) / 0.30, 0), 1); t = t * t * (3 - 2 * t)
            col = mix(CA, CB, t * 2) if t < 0.5 else mix(CB, CC, (t - 0.5) * 2)
        px += [*col, 1.0]
img.pixels = px
img.filepath_raw = os.path.join(out, "oxido-de-manganes-cor.png"); img.file_format = "PNG"; img.save()
me = p.data; uv = me.uv_layers.new(name="UVMap")
for poly in me.polygons:
    for li in poly.loop_indices:
        co = me.vertices[me.loops[li].vertex_index].co
        uv.data[li].uv = (((co.x - UV0) / UVS) * (S - 17) / S, ((co.y - UV0) / UVS) * (S - 17) / S) if poly.normal.z > 0.5 else ((S - 8) / S, (S - 8) / S)
m = bpy.data.materials.new("oxido-de-manganes"); m.use_nodes = True
bs = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED"); tx = m.node_tree.nodes.new("ShaderNodeTexImage"); tx.image = img
m.node_tree.links.new(tx.outputs["Color"], bs.inputs["Base Color"]); bs.inputs["Roughness"].default_value = 0.8
me.materials.clear(); me.materials.append(m)
for poly in me.polygons: poly.use_smooth = False
c1 = rock("lasca-pedrinha1", (0.12, 0.1, 0.08), 51, amp=0.3, sub=1); two_tone(c1, "#C9A47E", "#A9825F")
for v in c1.data.vertices: v.co += Vector((0.62, 0.25, 0))
c2 = rock("lasca-pedrinha2", (0.09, 0.08, 0.06), 53, amp=0.3, sub=1); two_tone(c2, "#C9A47E", "#A9825F")
for v in c2.data.vertices: v.co += Vector((-0.6, -0.45, 0))
models.append(join("oxido-de-manganes", [p, c1, c2]))

# 4. Pedras perto da John Klein (PIA16568): A, B e C da foto
o = rock("john-klein-a", (0.9, 0.75, 0.7), 17, amp=0.22, box=True, cuts=3)
pa = [((0, 0, 0.3), (0.2, 0.1, 1)), ((0.1, 0, 0), (1, 0.4, 0.2))]
paint(o, lambda c, n: ("#50545D",) if near_planes(c, pa, 0.05) else (("#A9ADB5",) if n.z > 0.6 else ("#8B9099",)))
models.append(o)
o = rock("john-klein-b", (1.0, 0.85, 0.6), 23, amp=0.25, freq=3.0, sub=3)
paint(o, lambda c, n: ("#BDB6A0",) if n.z > 0.5 else (("#9C9A86",) if noise.noise(c * 4) > 0 else ("#8E8E7C",)))
models.append(o)
o = rock("john-klein-c", (0.6, 0.5, 0.45), 29, amp=0.3, box=True, cuts=2, taper=0.4)
paint(o, lambda c, n: ("#4E525B", 0.2, 0.6) if n.z > 0.6 else ("#3B3F47", 0.2, 0.6))
models.append(o)

# 5. Meteorito Lebanon (PIA18387): ferro cinza brilhante, cheio de buracos, com um pedaço do lado
o = rock("meteorito-lebanon", (1.5, 1.0, 0.55), 31, amp=0.12, sub=4)
cs = pits(o, 16, 0.22, 0.10, 1)
paint(o, lambda c, n: ("#4A4E57", 0.8, 0.45) if min((c - p).length for p in cs) < 0.14 else (("#9A9EA6", 0.8, 0.35) if n.z > 0.5 else ("#7E828B", 0.8, 0.4)))
f = rock("lebanon-pedaco", (0.55, 0.3, 0.25), 37, amp=0.2, sub=2)
paint(f, lambda c, n: ("#9A9EA6", 0.8, 0.35) if n.z > 0.5 else ("#5E626B", 0.8, 0.45))
for v in f.data.vertices: v.co += Vector((0.5, -1.15, 0))
bpy.ops.object.select_all(action="DESELECT"); o.select_set(True); f.select_set(True)
bpy.context.view_layer.objects.active = o; bpy.ops.object.join()
models.append(o)

for o in models:
    fit(o, 1.1)
    bpy.ops.object.select_all(action="DESELECT"); o.select_set(True); bpy.context.view_layer.objects.active = o
    bpy.ops.export_scene.gltf(filepath=os.path.join(out, o.name + ".glb"), export_format="GLB", use_selection=True)

# prévia
for i, o in enumerate(models): o.location.x = i * 1.5
sc = bpy.context.scene
cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam")); sc.collection.objects.link(cam); sc.camera = cam
cam.data.type = "ORTHO"; cam.data.ortho_scale = 11; cam.location = (4.5, -8, 8.5); cam.rotation_euler = (math.radians(45), 0, 0)
sc.render.engine = "CYCLES"; sc.cycles.device = "CPU"; sc.cycles.samples = 24
sun = bpy.data.objects.new("sol", bpy.data.lights.new("sol", "SUN")); sc.collection.objects.link(sun); sun.data.energy = 4; sun.rotation_euler = (math.radians(45), 0, math.radians(30))
sc.world = bpy.data.worlds.new("w"); sc.world.color = lin("#D9A066")
sc.world.use_nodes = True; bg = next(n for n in sc.world.node_tree.nodes if n.type == "BACKGROUND"); bg.inputs["Color"].default_value = (*lin("#D9A066"), 1); bg.inputs["Strength"].default_value = 0.8
sc.render.resolution_x, sc.render.resolution_y = 1800, 520; sc.render.film_transparent = False
sc.render.filepath = os.path.join(out, "descobertas-previa.png"); bpy.ops.render.render(write_still=True)
# close das 3 primeiras
cam.data.ortho_scale = 5.2; cam.location = (1.5, -4.2, 4.6); sc.render.resolution_x, sc.render.resolution_y = 1500, 560
sc.render.filepath = os.path.join(out, "descobertas-previa-1a3.png"); bpy.ops.render.render(write_still=True)

print("OK")
