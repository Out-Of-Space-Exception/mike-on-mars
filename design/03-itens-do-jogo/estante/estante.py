# Estante de exposição (6 vagas), montada com peças CC0 da Kenney:
# bookcaseClosedWide (Furniture Kit), structure-panel e display-wall (Space Station Kit).
# Uso: blender -b -P estante.py -- PASTA_KENNEY PASTA_SAIDA PASTA_DESIGN
import bpy, sys, os, glob, math
from mathutils import Vector
K, OUT, DESIGN = [os.path.abspath(a) for a in sys.argv[sys.argv.index("--") + 1:]]
bpy.ops.wm.read_factory_settings(use_empty=True)
ALTURA = 1.8  # altura final no jogo (Mike = 2.2)

def lin(h): return tuple(((int(h[i:i+2], 16) / 255 + 0.055) / 1.055) ** 2.4 for i in (1, 3, 5))
MATS = {}
def mat(h, emit=0.0, metal=0.0, rough=0.6):
    k = (h, emit, metal)
    if k not in MATS:
        m = bpy.data.materials.new(h + ("-luz" if emit else "")); m.use_nodes = True
        b = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
        b.inputs["Base Color"].default_value = (*lin(h), 1); b.inputs["Metallic"].default_value = metal; b.inputs["Roughness"].default_value = rough
        if emit:
            b.inputs["Emission Color"].default_value = (*lin(h), 1); b.inputs["Emission Strength"].default_value = emit
        MATS[k] = m
    return MATS[k]

def importar(nome):
    f = glob.glob(os.path.join(K, "**", nome + ".glb"), recursive=True)[0]
    antes = set(bpy.data.objects); bpy.ops.import_scene.gltf(filepath=f)
    novos = [o for o in bpy.data.objects if o not in antes]
    return [o for o in novos if o.parent is None][0]

def caixa(nome, x0, x1, y0, y1, z0, z1, m):
    bpy.ops.mesh.primitive_cube_add(size=1, location=((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2))
    o = bpy.context.object; o.name = nome; o.scale = (x1 - x0, y1 - y0, z1 - z0); o.data.materials.append(m); return o

def cilindro(nome, x, y, z0, z1, r, m, lados=6):
    bpy.ops.mesh.primitive_cylinder_add(vertices=lados, radius=r, depth=z1 - z0, location=(x, y, (z0 + z1) / 2))
    o = bpy.context.object; o.name = nome; o.data.materials.append(m); return o

BRANCO, CINZA, GRAFITE, FUNDO = mat("#EEF0F4"), mat("#C3C8D2"), mat("#5E6575"), mat("#1F2A44")
LARANJA, CIANO, VERMELHO = mat("#D96941"), mat("#5FE0FF", emit=3.0), mat("#BF2A2A", emit=4.0)
partes = []

# base espacial: structure-panel achatado
base = importar("structure-panel"); base.scale = (1.0 / 0.85, 0.36 / 0.85, 0.6); base.location = (0.4, 0.125, 0); partes.append(base)
H0 = 0.125 * 0.6  # altura da base

# a estante da Furniture Kit, repintada: branco + prateleiras cinza + frente laranja + fundo azul-escuro
est = importar("bookcaseClosedWide"); est.location = (0, 0, H0)
me = est.data; me.materials.clear()
for m in (BRANCO, CINZA, LARANJA, FUNDO): me.materials.append(m)
for p in me.polygons:
    c, n = p.center, p.normal
    if n.z > 0.9: p.material_index = 1
    elif n.y < -0.9 and c.y < 0.03: p.material_index = 2
    elif n.y < -0.9 and c.y > 0.15: p.material_index = 3
    else: p.material_index = 0
partes.append(est)

# divisória no meio: 3 andares x 2 colunas = 6 vagas
partes.append(caixa("divisoria", 0.39, 0.41, 0.012, 0.235, H0 + 0.04, H0 + 0.76, BRANCO))
partes.append(caixa("divisoria-frente", 0.39, 0.41, 0.0, 0.012, H0 + 0.04, H0 + 0.76, LARANJA))

PISOS = [0.04, 0.30, 0.55]; TETOS = [0.28, 0.53, 0.76]
vagas = []
for a, (piso, teto) in enumerate(zip(PISOS, TETOS)):
    partes.append(caixa(f"luz-{a}", 0.04, 0.76, 0.015, 0.03, H0 + teto - 0.012, H0 + teto, CIANO))  # fita de luz
    for col, x in enumerate((0.2, 0.6)):
        i = a * 2 + col
        partes.append(cilindro(f"pedestal-{i}", x, 0.12, H0 + piso, H0 + piso + 0.025, 0.075, GRAFITE))
        partes.append(cilindro(f"pedestal-anel-{i}", x, 0.12, H0 + piso + 0.025, H0 + piso + 0.032, 0.06, CIANO))
        vagas.append((x, 0.12, H0 + piso + 0.032))
# ordem das vagas como se lê: 1-2 em cima, 3-4 no meio, 5-6 embaixo
vagas = sorted(vagas, key=lambda v: (-v[2], v[0]))

# topo: telinha do Space Station Kit + 2 antenas com luz vermelha
tela = importar("display-wall"); tela.scale = (0.7, 0.7, 0.7); tela.location = (0.4, 0.14, H0 + 0.79); partes.append(tela)
for k, x in enumerate((0.06, 0.74)):
    partes.append(cilindro(f"antena-{k}", x, 0.12, H0 + 0.79, H0 + 0.95, 0.008, CINZA, 8))
    bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=0.02, location=(x, 0.12, H0 + 0.96))
    s = bpy.context.object; s.name = f"antena-luz-{k}"; s.data.materials.append(VERMELHO); partes.append(s)

# raiz: centraliza, escala para ALTURA e marca as vagas (viram Node3D "vaga-1".."vaga-6" no Godot)
alto = H0 + 0.98; esc = ALTURA / alto
raiz = bpy.data.objects.new("estante", None); bpy.context.collection.objects.link(raiz)
for o in partes:
    o.parent = raiz; o.location -= Vector((0.4, 0.125, 0))
for i, (x, y, z) in enumerate(vagas, 1):
    e = bpy.data.objects.new(f"vaga-{i}", None); e.empty_display_size = 0.05; bpy.context.collection.objects.link(e)
    e.parent = raiz; e.location = (x - 0.4, y - 0.125, z)
raiz.scale = (esc,) * 3
bpy.context.view_layer.update()
bpy.ops.object.select_all(action="DESELECT")
for o in [raiz] + list(raiz.children_recursive): o.select_set(True)
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, "estante.glb"), export_format="GLB", use_selection=True)
with open(os.path.join(OUT, "vagas.csv"), "w", encoding="utf-8") as f:
    f.write("vaga,x,y,z,tamanho_max\n")  # em metros do jogo, eixos do Godot (y para cima; a frente da estante olha para +z)
    for i, (x, y, z) in enumerate(vagas, 1):
        f.write(f"{i},{(x - 0.4) * esc:.3f},{z * esc:.3f},{(y - 0.125) * esc:.3f},{0.17 * esc:.2f}\n")

# prévia com coisas expostas (só na imagem: não vão no estante.glb)
amostras = ["03-itens-do-jogo/descobertas/meteorito-lebanon.glb", "04-cores-das-coisas/enxofre.glb", "03-itens-do-jogo/alface.glb",
            "03-itens-do-jogo/descobertas/veios-brancos.glb", "03-itens-do-jogo/pimenta.glb", "04-cores-das-coisas/hematita.glb"]
for (x, y, z), a in zip(vagas, amostras):
    antes = set(bpy.data.objects); bpy.ops.import_scene.gltf(filepath=os.path.join(DESIGN, a))
    novos = [o for o in bpy.data.objects if o not in antes]; bpy.context.view_layer.update()
    pts = [o.matrix_world @ Vector(c) for o in novos if o.type == "MESH" for c in o.bound_box]
    lo = Vector([min(p[k] for p in pts) for k in range(3)]); hi = Vector([max(p[k] for p in pts) for k in range(3)])
    s = 0.17 * esc / max(hi - lo); alvo = raiz.matrix_world @ Vector((x - 0.4, y - 0.125, z))
    piv = Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
    for o in novos:
        if o.parent is None:
            o.scale = o.scale * s; o.location = alvo + (o.location - piv) * s
sc = bpy.context.scene
cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam")); sc.collection.objects.link(cam); sc.camera = cam
cam.data.type = "ORTHO"; cam.data.ortho_scale = 2.3; cam.location = (0.75, -4.0, 1.6); cam.rotation_euler = (math.radians(82), 0, math.radians(11))
sol = bpy.data.objects.new("sol", bpy.data.lights.new("sol", "SUN")); sc.collection.objects.link(sol); sol.data.energy = 3.5; sol.rotation_euler = (math.radians(50), 0, math.radians(-25))
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True
bg = next(n for n in sc.world.node_tree.nodes if n.type == "BACKGROUND"); bg.inputs["Color"].default_value = (*lin("#D9A066"), 1); bg.inputs["Strength"].default_value = 0.7
sc.render.engine = "CYCLES"; sc.cycles.device = "CPU"; sc.cycles.samples = 48; sc.render.resolution_x, sc.render.resolution_y = 1000, 1100
sc.render.filepath = os.path.join(OUT, "estante-previa.png"); bpy.ops.render.render(write_still=True); print("OK")
