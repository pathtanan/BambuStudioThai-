from pathlib import Path
import argparse
import struct

# The stock ImGuizmo cube lacks Thai glyphs. Use ASCII labels on shared keys.
# This is a resource-only patch; the original signed EXE/DLL are untouched.
REPLACEMENTS = {
    "Front": "Front",
    "Back": "Back",
    "Top": "Top",
    "Bottom": "Bottom",
    "Camera\x04Left": "Left",
    "Camera\x04Right": "Right",
    "Part": "ชิ้นส่วน",
    "World coordinates": "พิกัดอ้างอิงแท่นพิมพ์",
    "Operation": "รูปแบบการทำงาน",
}

def read_mo(data):
    if len(data) < 28:
        raise ValueError("MO too short")
    magic, revision, n, oi, ti, _, _ = struct.unpack_from("<7I", data)
    if magic != 0x950412DE or (revision >> 16):
        raise ValueError("Invalid GNU MO header")
    if oi + n*8 > len(data) or ti + n*8 > len(data):
        raise ValueError("Bad MO index")
    pairs = []
    for i in range(n):
        kl, kp = struct.unpack_from("<2I", data, oi+i*8)
        vl, vp = struct.unpack_from("<2I", data, ti+i*8)
        if kp+kl >= len(data) or vp+vl >= len(data):
            raise ValueError("Invalid MO string offset")
        if data[kp+kl] or data[vp+vl]:
            raise ValueError("MO string not terminated")
        pairs.append((data[kp:kp+kl],data[vp:vp+vl]))
    if len({k for k,_ in pairs}) != n:
        raise ValueError("Duplicate translation key")
    return pairs

def write_mo(pairs):
    pairs=sorted(pairs)
    count=len(pairs)
    ofs=28+16*count
    ot, tt, ob, tb = [], [], bytearray(), bytearray()
    for k, _ in pairs:
        ot.append((len(k),ofs+len(ob)))
        ob.extend(k+b"\0")
    ofs+=len(ob)
    for _, v in pairs:
        tt.append((len(v),ofs+len(tb)))
        tb.extend(v+b"\0")
    out=bytearray(struct.pack("<7I",0x950412DE,0,count,28,28+count*8,0,0))
    for table in (ot,tt):
        for rec in table:
            out.extend(struct.pack("<2I",*rec))
    return bytes(out+ob+tb)

def main():
    p=argparse.ArgumentParser()
    p.add_argument("source",type=Path)
    p.add_argument("destination",type=Path)
    a=p.parse_args()
    original=read_mo(a.source.read_bytes())
    seen=set()
    patched=[]
    changed=[]
    for key, value in original:
        name=key.decode("utf-8")
        seen.add(name)
        if name in REPLACEMENTS:
            new=REPLACEMENTS[name].encode("utf-8")
            if new!=value:
                changed.append(name.replace(chr(4),"/"))
            value=new
        patched.append((key,value))
    missing=set(REPLACEMENTS)-seen
    if missing:
        raise ValueError("Missing MO keys: "+str(sorted(missing)))
    result=write_mo(patched)
    if dict(read_mo(result))!=dict(patched) or len(patched)!=len(original):
        raise AssertionError("Failed MO verification")
    a.destination.parent.mkdir(parents=True,exist_ok=True)
    a.destination.write_bytes(result)
    print("MO entries:",len(original),"changed:",len(changed),changed)

if __name__=="__main__":
    main()
