"""Merge reviewed Thai strings into the matching official-version gettext MO.
Preserve official new keys and the source catalog header. Changes remain resource-only.
"""
from pathlib import Path
import re
import sys

from prepare_patch_catalog import read_mo, write_mo

def format_tokens(raw):
    s=raw.decode("utf-8","replace")
    return sorted(re.findall(r'%(?:\d+\$)?[-+ #0.]*\d*(?:\.\d+)?[a-zA-Z]|\{\{[^{}]+\}\}',s))

def main():
    if len(sys.argv)!=4:
        raise SystemExit("usage: merge_native_catalog.py OFFICIAL.mo REVIEWED.mo OUT.mo")
    official=read_mo(Path(sys.argv[1]).read_bytes())
    edited=dict(read_mo(Path(sys.argv[2]).read_bytes()))
    result=[]
    updated=0
    incompatible=0
    for k,v in official:
        cv=edited.get(k)
        if k and cv and cv.strip():
            # Reject changes introducing/changing interpolation placeholders.
            baseline=k.split(b"\x04")[-1].split(b"\x00")[0]
            if format_tokens(baseline)==format_tokens(cv.split(b"\x00")[0]):
                if v!=cv:
                    updated+=1
                v=cv
            else:
                incompatible+=1
        result.append((k,v))
    merged=write_mo(result)
    if len(read_mo(merged))!=len(official):
        raise ValueError("Original official MO entries were lost")
    dst=Path(sys.argv[3])
    dst.parent.mkdir(parents=True,exist_ok=True)
    dst.write_bytes(merged)
    print("Original official keys:",len(official),"reviewed overrides:",updated,"skipped placeholder mismatches:",incompatible)

if __name__=="__main__":
    main()
