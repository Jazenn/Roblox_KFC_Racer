"""Regression checks for outward glass and paint on the actual body surfaces."""
import json
import math
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT / "blender/export/reference_van.mesh.json").read_text())
GROUPS = {group["name"]: group for group in DATA["groups"]}


def readable_u(group):
    samples=[(v[2],uv[0],n[0]) for v,n,uv in zip(group["vertices"],group["normals"],group["uv"])
             if abs(n[0])>.99 and v[0]*n[0]>2.63]
    first,last=min(samples),max(samples)
    # In Roblox's Y-up coordinates, the outside observer's right is -normal x up.
    return (last[1]-first[1])/(last[0]-first[0])*first[2]<0


class ReferenceMesh(unittest.TestCase):
    def test_complete_finite_geometry(self):
        self.assertEqual(DATA["reference"], "kfc_racer_van.png")
        self.assertEqual(len(GROUPS),13)
        for group in GROUPS.values():
            count=len(group["vertices"])
            self.assertEqual(count,len(group["normals"]))
            self.assertEqual(count,len(group["uv"]))
            self.assertTrue(group["faces"])
            for vectors in (group["vertices"],group["normals"],group["uv"]):
                self.assertTrue(all(math.isfinite(x) for v in vectors for x in v))
            self.assertTrue(all(0 <= i < count for face in group["faces"] for i in face))

    def test_cab_windows_face_outside(self):
        group=GROUPS["Glass"]
        checked=0
        for vertex,normal in zip(group["vertices"],group["normals"]):
            if abs(normal[0]) > .9:
                self.assertGreater(vertex[0]*normal[0],0,"Cab glass is facing inside")
                checked+=1
        self.assertEqual(checked,12,"Expected both side windows, four triangles")

    def test_left_and_right_paint_maps_are_distinct(self):
        self.assertEqual(GROUPS["Paint_Left"]["texture"],"body_left.png")
        self.assertEqual(GROUPS["Paint_Right"]["texture"],"body_right.png")
        for name,side in (("Paint_Left",1),("Paint_Right",-1)):
            group=GROUPS[name]
            exterior=0
            for vertex,normal,uv in zip(group["vertices"],group["normals"],group["uv"]):
                if normal[0]*side > .99 and abs(vertex[0]) > 2.63:
                    exterior+=1
                    y=vertex[2]/2.7
                    expected=(2.4-y)/4.8 if name=="Paint_Left" else (y+2.4)/4.8
                    self.assertAlmostEqual(uv[0],expected,delta=.003)
            self.assertGreater(exterior,100,"Paint must occupy the exterior skin")

    def test_export_has_no_logo_boards(self):
        # Paint is the wheel-arch body silhouette, not a rectangular sign mesh.
        for name in ("Paint_Left","Paint_Right"):
            vertices=GROUPS[name]["vertices"]
            for wheel in (-1.45,1.48):
                arch=[v[1]/2.7 for v in vertices if abs(v[2]/2.7-wheel)<.025]
                self.assertTrue(arch)
                self.assertGreater(min(arch),.77,"Wheel arch was covered by a logo board")

    def test_lettering_reads_forward_on_both_outsides(self):
        for name in ("Paint_Left","Paint_Right"):
            self.assertTrue(readable_u(GROUPS[name]),name+" has mirrored lettering")
            mirrored=dict(GROUPS[name])
            mirrored["vertices"]=[[-v[0],v[1],v[2]] for v in mirrored["vertices"]]
            mirrored["normals"]=[[-v[0],v[1],v[2]] for v in mirrored["normals"]]
            self.assertFalse(readable_u(mirrored),"Regression check missed the first import's mirrored basis")

    def test_local_geometry_chunks_match_export(self):
        chunks=sorted((ROOT/"blender/export/meshdata").glob("*.txt"))
        self.assertTrue(chunks)
        self.assertTrue(all(0<len(p.read_text())<200000 for p in chunks))
        self.assertEqual(json.loads("".join(p.read_text() for p in chunks)),DATA)


if __name__=="__main__":
    unittest.main()
