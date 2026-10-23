"""Original reference-led compact delivery van, authored in Blender.

Axes: X width, -Y front, Z up. Side paint is UV mapped on the actual body
mesh. New scene only: the user's existing scene/objects are preserved.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "blender" / "export"
OUT.mkdir(parents=True, exist_ok=True)
assert (OUT / "body_left.png").exists(), "Run make_livery.py first"
assert not bpy.data.scenes.get("KFC_Reference_Van_v3"), "Reference scene already exists; inspect before rebuilding"
scene = bpy.data.scenes.new("KFC_Reference_Van_v3")
bpy.context.window.scene = scene
collection = bpy.data.collections.new("RFC_Reference_Van_v3")
scene.collection.children.link(collection)
vehicle = []


def material(name, color, metallic=0, rough=.4, image=None):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    m.use_backface_culling = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Coat Weight"].default_value = .35 if "Paint" in name else 0
    if image:
        tex = m.node_tree.nodes.new("ShaderNodeTexImage")
        tex.image = bpy.data.images.load(str(OUT / image), check_existing=True)
        tex.image.pack()
        m.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    return m


paint = material("Paint_Red", (.53,.005,.012), .38,.24)
left = material("Paint_Left", (.53,.005,.012), .38,.24,"body_left.png")
right = material("Paint_Right", (.53,.005,.012), .38,.24,"body_right.png")
front = material("Paint_Front", (.53,.005,.012), .38,.24,"body_front.png")
roofmat = material("Paint_Roof", (.53,.005,.012), .38,.24,"body_roof.png")
rubber = material("Rubber", (.012,.015,.019), 0,.82)
trim = material("Trim", (.018,.022,.027), .1,.4)
glass = material("Glass", (.025,.055,.075), .45,.12)
chrome = material("Chrome", (.55,.6,.66), .92,.22)
white = material("White_Steel", (.83,.85,.83), .35,.32)
lamp = material("Headlamp", (.78,.84,.85), .65,.13)
amber = material("Amber", (.95,.29,.015), .2,.22)
tail = material("Taillight", (.5,.003,.008), .3,.2)


def register(obj, mat, name):
    obj.name = name
    for c in list(obj.users_collection):
        c.objects.unlink(obj)
    collection.objects.link(obj)
    obj.data.materials.append(mat)
    vehicle.append(obj)
    return obj


def bevel(obj, width=.03, segments=3):
    mod = obj.modifiers.new("Manufactured radii", "BEVEL")
    mod.width, mod.segments = width, segments
    mod.limit_method = "ANGLE"
    normal = obj.modifiers.new("Weighted panel normals", "WEIGHTED_NORMAL")
    normal.keep_sharp = True


def box(name, at, size, mat, radius=.02):
    bpy.ops.mesh.primitive_cube_add(size=1, location=at)
    o = register(bpy.context.object, mat, name)
    o.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if radius:
        bevel(o,radius)
    return o


def mesh(name, vertices, faces, mat, uv=None):
    data = bpy.data.meshes.new(name)
    data.from_pydata(vertices,[],faces)
    data.update()
    assert not data.validate(), name + " invalid topology"
    o=bpy.data.objects.new(name,data)
    collection.objects.link(o)
    data.materials.append(mat)
    vehicle.append(o)
    if uv:
        layer=data.uv_layers.new(name="PaintUV")
        for face in data.polygons:
            for loop in face.loop_indices:
                layer.data[loop].uv=uv[data.loops[loop].vertex_index]
    return o


def line(name, points, mat, radius=.004):
    data=bpy.data.curves.new(name,"CURVE")
    data.dimensions="3D"
    data.bevel_depth, data.bevel_resolution=radius,2
    spline=data.splines.new("POLY")
    spline.points.add(len(points)-1)
    for p,co in zip(spline.points,points): p.co=(*co,1)
    o=bpy.data.objects.new(name,data)
    collection.objects.link(o)
    data.materials.append(mat)
    vehicle.append(o)
    return o


def cylinder(name, at, radius, depth, mat, segments=24):
    bpy.ops.mesh.primitive_cylinder_add(vertices=segments,radius=radius,depth=depth,location=at,rotation=(0,math.pi/2,0))
    o=register(bpy.context.object,mat,name)
    bevel(o,.008,2)
    for p in o.data.polygons: p.use_smooth=True
    return o


# Continuous side skins with actual wheel-arch cutouts, not branding boards.
wheel_y=(-1.45,1.48)
bottom=[]
for i in range(141):
    y=-2.32+i*4.64/140
    z=.48
    for center in wheel_y:
        distance=abs(y-center)
        if distance<.435:
            z=max(z,.375+math.sqrt(.435**2-distance**2))
    bottom.append((y,z))
outline=bottom+[(2.32,1.86),(2.28,1.98),(2.17,2.075),(-1.44,2.075),(-1.61,2.0),(-2.10,1.27),(-2.29,1.12)]
for side,mat in ((-1,left),(1,right)):
    vertices=[(side*.98,y,z) for y,z in outline]
    order=list(range(len(vertices)))
    if side<0: order.reverse()
    uv=[(((2.4-y) if side<0 else (y+2.4))/4.8,z/2.4) for y,z in outline]
    o=mesh("Body_Left" if side<0 else "Body_Right",vertices,[order],mat,uv)
    solid=o.modifiers.new("Sheet metal", "SOLIDIFY")
    solid.thickness,solid.offset=.035,-1
    bevel(o,.012,3)
    for center in wheel_y:
        points=[]
        for i in range(41):
            a=i*math.pi/40
            points.append((side*.987,center-.438*math.cos(a),.375+.438*math.sin(a)))
        line("Wheel arch lip",points,trim,.012)

# Sloped cab front follows reference silhouette rather than a protruding hood.
profile=[(-2.32,.48),(-2.365,.73),(-2.32,1.10),(-2.10,1.27),(-1.59,2.01),(-1.44,2.075)]
verts=[(x,y,z) for x in (-.98,.98) for y,z in profile]
faces=[]
for i in (0,1,2,4): faces.append((i,len(profile)+i,len(profile)+i+1,i+1))
uv=[((x+.98)/1.96,(z-.48)/.84) for x,y,z in verts]
nose=mesh("Front pressed metal",verts,faces,front,uv)
solid=nose.modifiers.new("Front sheet thickness","SOLIDIFY"); solid.thickness=.035
bevel(nose,.025,3)

# Roof crown, rounded edge rails and rear doors.
roof=box("Rounded roof",(0,.31,2.035),(1.94,3.83,.19),roofmat,.14)
layer=roof.data.uv_layers.active
for polygon in roof.data.polygons:
    for index in polygon.loop_indices:
        co=roof.data.vertices[roof.data.loops[index].vertex_index].co+roof.location
        layer.data[index].uv=((co.x+.98)/1.96,(co.y+1.6)/3.83)
box("Rear corner closure",(0,2.28,1.22),(1.9,.16,1.51),paint,.09)
for side in (-1,1):
    box("Rear door",(side*.455,2.367,1.25),(.89,.025,1.42),paint,.035)
    box("Rear door handle",(side*.12,2.39,1.13),(.035,.026,.14),trim,.012)
    box("Rear lamp",(side*.86,2.374,.9),(.105,.035,.38),tail,.025)
box("Cargo floor",(0,.2,.49),(1.7,3.85,.1),trim,.015)
box("Rear bumper",(0,2.4,.46),(1.94,.16,.18),paint,.06)
box("Front bumper",(0,-2.35,.48),(1.97,.19,.22),paint,.055)
box("Lower intake",(0,-2.452,.53),(1.15,.018,.085),trim,.02)
box("Front plate",(0,-2.46,.42),(.45,.017,.105),white,.008)

# Windshield and its rubber surround are mounted on the sloping cab surface.
for name,scale,offset,mat in (("Windshield seal",1,.009,trim),("Windshield",.955,.016,glass)):
    corners=[(-.895,-2.104-offset,1.295),(.895,-2.104-offset,1.295),(.83,-1.655-offset,1.952),(-.83,-1.655-offset,1.952)]
    center=sum((Vector(v) for v in corners),Vector())/4
    corners=[tuple(center+(Vector(v)-center)*scale) for v in corners]
    mesh(name,corners,[(0,1,2,3)],mat)
line("Windshield central divider",[(0,-2.125,1.3),(0,-1.673,1.95)],trim,.008)
for side in (-1,1):
    window=[(side*.989,-1.99,1.29),(side*.989,-.77,1.29),(side*.989,-.77,1.96),(side*.989,-1.56,1.96)]
    indices=[3,2,1,0] if side<0 else [0,1,2,3]
    mesh("Cab side glass",window,[indices],glass)
    line("Window rubber seal",window+[window[0]],trim,.017)
    line("Cab door seam",[(side*.997,-.7,1.98),(side*.997,-.7,.55),(side*.997,-1.04,.5)],trim,.004)
    line("Sliding door seam",[(side*.997,-.55,1.98),(side*.997,1.9,1.98),(side*.997,1.9,.56)],trim,.003)
    box("Front door handle",(side*1.003,-.87,1.15),(.025,.17,.038),trim,.012)
    box("Sliding door handle",(side*1.003,-.42,1.13),(.025,.19,.038),trim,.012)
    box("Mirror arm",(side*1.055,-1.82,1.29),(.19,.035,.035),trim,.01)
    mirror=box("Mirror housing",(side*1.16,-1.8,1.39),(.12,.17,.26),trim,.055)
    box("Mirror glass",(side*1.16,-1.707,1.4),(.09,.013,.20),chrome,.025)
    box("Lamp black housing",(side*.715,-2.36,.98),(.42,.055,.21),trim,.025)
    box("Headlamp lens",(side*.685,-2.395,.99),(.30,.025,.15),lamp,.02)
    box("Amber indicator",(side*.895,-2.386,.99),(.095,.028,.15),amber,.018)
    for rib in range(7):
        box("Headlamp optics",(side*.685-.12+rib*.04,-2.411,.99),(.009,.008,.13),chrome,.001)
box("Grille",(0,-2.36,.99),(.94,.04,.17),trim,.012)
for row in range(3): box("Grille slat",(0,-2.385,.935+row*.05),(.89,.008,.009),chrome,.001)
for side in (-1,1):
    line("Wiper",[(side*.26,-2.14,1.32),(side*.60,-2.06,1.44)],trim,.009)
    box("Cab seat",(side*.45,-1.00,1.05),(.43,.38,.58),trim,.06)
box("Dashboard",(0,-1.91,1.18),(1.7,.32,.15),trim,.035)

# Lathed tires and white steel wheels, with rim vents and five lug nuts.
for side in (-1,1):
    for center in wheel_y:
        profile=[(-.14,.24),(-.135,.31),(-.10,.372),(.10,.372),(.135,.31),(.14,.24)]
        vertices=[]; faces=[]
        for axial,radius in profile:
            for i in range(48):
                a=i*2*math.pi/48
                vertices.append((side*.985+axial,center+radius*math.cos(a),.375+radius*math.sin(a)))
        for row in range(len(profile)-1):
            for i in range(48):
                j=(i+1)%48
                faces.append((row*48+i,row*48+j,(row+1)*48+j,(row+1)*48+i))
        tire=mesh("Tire",vertices,faces,rubber)
        for polygon in tire.data.polygons: polygon.use_smooth=True
        cylinder("White steel wheel",(side*1.128,center,.375),.24,.025,white)
        cylinder("Wheel center",(side*1.145,center,.375),.092,.025,white)
        for index in range(8):
            a=index*math.pi/4
            cylinder("Rim ventilation",(side*1.146,center+math.cos(a)*.167,.375+math.sin(a)*.167),.027,.006,trim,16)
        for index in range(5):
            a=index*math.pi/2.5
            cylinder("Lug nut",(side*1.16,center+math.cos(a)*.057,.375+math.sin(a)*.057),.012,.012,chrome,12)

# Reference-only empty: a visible copy of the supplied picture, not a texture cheat.
reference=bpy.data.objects.new("Owner reference — kfc_racer_van.png",None)
reference.empty_display_type="IMAGE"
reference.data=bpy.data.images.load(str(ROOT.parents[1]/"kfc_racer_van.png"),check_existing=True)
reference.empty_display_size=4
reference.location=(5,3,2)
reference.hide_render=True
scene.collection.objects.link(reference)

# Ground and studio lighting are separate from exported vehicle geometry.
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.012))
ground=bpy.context.object; ground.name="Review ground"
ground.data.materials.append(material("Review asphalt",(.07,.085,.1),0,.86))
world=bpy.data.worlds.new("Reference daylight")
world.use_nodes=True
world.node_tree.nodes["Background"].inputs["Color"].default_value=(.16,.2,.27,1)
world.node_tree.nodes["Background"].inputs["Strength"].default_value=.5
scene.world=world
for name,at,power,size in (("Key",(4,-4,7),1500,5),("Fill",(-4,-1,4),900,5),("Rim",(0,5,5),1800,4)):
    data=bpy.data.lights.new(name,"AREA"); data.energy=power; data.shape="DISK"; data.size=size
    o=bpy.data.objects.new(name,data); scene.collection.objects.link(o); o.location=at
    o.rotation_euler=(Vector((0,0,1))-o.location).to_track_quat("-Z","Y").to_euler()
camera_data=bpy.data.cameras.new("Reference review camera")
camera=bpy.data.objects.new("Reference review camera",camera_data)
scene.collection.objects.link(camera); scene.camera=camera
camera_data.type="ORTHO"; camera_data.ortho_scale=6.4
scene.render.engine="BLENDER_EEVEE"
scene.render.resolution_x,scene.render.resolution_y,scene.render.resolution_percentage=1440,960,100
scene.render.image_settings.file_format="PNG"
scene.view_settings.view_transform="AgX"
scene.render.film_transparent=False

# Export evaluated, material-separated geometry with real UVs and corner normals.
deps=bpy.context.evaluated_depsgraph_get()
groups={}
for o in vehicle:
    evaluated=o.evaluated_get(deps)
    data=evaluated.to_mesh()
    data.calc_loop_triangles()
    normal_matrix=o.matrix_world.to_3x3().inverted().transposed()
    for triangle in data.loop_triangles:
        mat=data.materials[triangle.material_index]
        g=groups.setdefault(mat.name,{"name":mat.name,"vertices":[],"normals":[],"uv":[],"faces":[],"color":list(mat.diffuse_color[:3]),"metallic":mat.node_tree.nodes.get("Principled BSDF").inputs["Metallic"].default_value,"roughness":mat.node_tree.nodes.get("Principled BSDF").inputs["Roughness"].default_value})
        image_nodes=[n for n in mat.node_tree.nodes if n.type=="TEX_IMAGE"]
        if image_nodes: g["texture"]=image_nodes[0].image.name
        first=len(g["vertices"])
        for loop_index in triangle.loops:
            vertex=data.vertices[data.loops[loop_index].vertex_index]
            co=o.matrix_world@vertex.co
            n=(normal_matrix@data.corner_normals[loop_index].vector).normalized()
            g["vertices"].append([round(-co.x*2.7,6),round(co.z*2.7,6),round(co.y*2.7,6)])
            g["normals"].append([round(-n.x,6),round(n.z,6),round(n.y,6)])
            uv=data.uv_layers.active.data[loop_index].uv if data.uv_layers.active else (0,0)
            g["uv"].append([round(uv[0],6),round(1-uv[1],6)])
        g["faces"].append([first,first+1,first+2])
    evaluated.to_mesh_clear()
payload={"reference":"kfc_racer_van.png","units":"studs","front":"-Z","groups":list(groups.values())}
(OUT/"reference_van.mesh.json").write_text(json.dumps(payload,separators=(",",":")))
chunks=OUT/"meshdata"
chunks.mkdir(exist_ok=True)
assert chunks.resolve().is_relative_to(OUT.resolve())
for old in chunks.glob("*.txt"): old.unlink()
encoded=json.dumps(payload,separators=(",",":"))
for i in range(0,len(encoded),100000):
    (chunks/(str(i//100000+1).zfill(4)+".txt")).write_text(encoded[i:i+100000])
scene["reference"]="kfc_racer_van.png"
scene["livery"]="Separate outside-facing left/right UV maps, painted onto sheet-metal body"
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/"reference_van_v3.blend"))
bpy.ops.object.select_all(action="DESELECT")
for o in vehicle: o.select_set(True)
bpy.context.view_layer.objects.active=vehicle[0]
bpy.ops.export_scene.gltf(filepath=str(OUT/"reference_van_v3.glb"),export_format="GLB",use_selection=True,export_apply=True)
for label,position in (("right_front",(6,-8,3.6)),("left_front",(-6,-8,3.6)),("rear",(-6,8,3.6))):
    camera.location=position
    camera.rotation_euler=(Vector((0,0,1.05))-camera.location).to_track_quat("-Z","Y").to_euler()
    scene.render.filepath=str(OUT/(label+".png"))
    bpy.ops.render.render(write_still=True)
camera.location=(6,-8,3.6)
camera.rotation_euler=(Vector((0,0,1.05))-camera.location).to_track_quat("-Z","Y").to_euler()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/"reference_van_v3.blend"))
result={"scene":scene.name,"objects":len(vehicle),"triangles":sum(len(g["faces"]) for g in groups.values()),"groups":len(groups),"output":str(OUT)}
