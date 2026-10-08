#!/usr/bin/env python3
"""Regenerate the streaming EDID with edid-decode (CVT reduced blanking v2)."""

import re
import struct
import subprocess
from pathlib import Path

sizes = [
    (1280, 720),
    (1920, 1080),
    (2560, 1440),
    (2560, 1600),
    (2560, 1664),
    (2880, 1800),
    (2880, 1864),
    (3024, 1890),
    (3024, 1964),
    (3440, 1440),
    (3456, 2160),
    (3456, 2234),
    (3840, 2160),
    (5120, 2160),
]
directory = Path(__file__).resolve().parent
source = (directory / "tv-original.bin").read_bytes()
assert len(source) == 256 and all(sum(source[i : i + 128]) % 256 == 0 for i in (0, 128))
records = []
for width, height in sizes:
    for fps in (60, 120):
        text = subprocess.check_output(
            ["edid-decode", "--cvt", f"w={width},h={height},fps={fps},rb=2"], text=True
        )
        clock = float(re.search(r"([\d.]+) MHz", text)[1])
        horizontal = re.search(
            r"Hfront\s+(\d+) Hsync\s+(\d+) Hback\s+(\d+) Hpol ([PN])", text
        )
        vertical = re.search(
            r"Vfront\s+(\d+) Vsync\s+(\d+) Vback\s+(\d+) Vpol ([PN])", text
        )
        hf, hs, hb = map(int, horizontal.groups()[:3])
        vf, vs, vb = map(int, vertical.groups()[:3])
        aspect = (
            4
            if width * 9 == height * 16
            else 5
            if width * 10 == height * 16
            else 6
            if width * 27 == height * 64
            else 8
        )
        flags = aspect | (0x80 if (width, height, fps) == (3840, 2160, 60) else 0)
        timing = (round(clock * 100) - 1).to_bytes(3, "little") + bytes([flags])
        timing += struct.pack(
            "<8H",
            width - 1,
            hf + hs + hb - 1,
            (hf - 1) | (0x8000 if horizontal[4] == "P" else 0),
            hs - 1,
            height - 1,
            vf + vs + vb - 1,
            (vf - 1) | (0x8000 if vertical[4] == "P" else 0),
            vs - 1,
        )
        records.append(timing)

# DisplayID Type I uses a 24-bit pixel clock, covering modes beyond legacy DTD limits.
parameters = (
    bytes([1, 0, 12])
    + struct.pack("<4H", 16000, 9000, 3840, 2160)
    + bytes([0, 120, 78, 0x99])
)
payloads = []
for i in range(0, len(records), 5):
    timings = b"".join(records[i : i + 5])
    payloads.append(
        (parameters if i == 0 else b"") + bytes([3, 0, len(timings)]) + timings
    )
blocks = []
for i, payload in enumerate(payloads):
    block = (
        bytearray(
            [
                0x70,
                0x13,
                len(payload),
                4 if i == 0 else 0,
                len(payloads) - 1 if i == 0 else 0,
            ]
        )
        + payload
    )
    block.append((-sum(block[1:])) & 255)
    block.extend(bytes(127 - len(block)))
    block.append((-sum(block)) & 255)
    blocks.append(block)
# Preserve the TV's CTA block (audio, HDR, VRR and all original video modes).
block_map = bytearray(128)
block_map[0] = 0xF0
block_map[1 : 2 + len(blocks)] = bytes([2] + [0x70] * len(blocks))
block_map[127] = (-sum(block_map)) & 255
base = bytearray(source[:128])
base[126] = 2 + len(blocks)
# Correct the original dummy serial/sRGB flag and expand declared timing limits.
base[12:16] = bytes(4)
base[24] |= 4
assert base[90:95] == bytes([0, 0, 0, 0xFD, 0])
base[97] = 15
base[99] = 143
base[127] = 0
base[127] = (-sum(base)) & 255
result = bytes(base) + bytes(block_map) + source[128:] + b"".join(blocks)
assert len(result) == (base[126] + 1) * 128
assert all(sum(result[i : i + 128]) % 256 == 0 for i in range(0, len(result), 128))
out = directory.parent / "system/usr/lib/firmware/edid/streaming.bin"
out.write_bytes(result)
print(
    f"{out}: {len(result)} bytes; {len(sizes)} resolutions, 60/120 Hz; original TV CTA preserved"
)
