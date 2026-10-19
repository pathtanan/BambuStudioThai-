"""Merge reviewed Thai DeviceWeb strings with the upstream version's keys."""
import json
from pathlib import Path
import sys
def main():
    if len(sys.argv)!=3: raise SystemExit("usage: merge_native_web.py OFFICIAL_th_TH.json REVIEWED_th_TH.json")
    dst=Path(sys.argv[1])
    official=json.loads(dst.read_text(encoding="utf-8-sig"))
    reviewed=json.loads(Path(sys.argv[2]).read_text(encoding="utf-8-sig"))
    if not isinstance(official,dict) or not isinstance(reviewed,dict): raise TypeError("Expected translation dictionaries")
    count=0
    for k,v in reviewed.items():
        if isinstance(v,str) and v.strip():
            if official.get(k)!=v: count+=1
            official[k]=v
    dst.write_text(json.dumps(official,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print("Official strings:",len(official),"Reviewed overrides:",count)
if __name__=="__main__": main()
