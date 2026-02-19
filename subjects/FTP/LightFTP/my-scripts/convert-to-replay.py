#!/usr/bin/env python3
import sys
import struct


def convert_to_aflnet_replay(input_path, output_path):
    # Read original seed
    with open(input_path, "rb") as f:
        data = f.read()

    # Split by CRLF while keeping protocol formatting
    parts = data.split(b"\r\n")

    messages = []
    for p in parts:
        if len(p) == 0:
            continue
        msg = p + b"\r\n"
        messages.append(msg)

    # Write AFLNet replay file
    with open(output_path, "wb") as out:
        for msg in messages:
            length_prefix = struct.pack("<I", len(msg))  # little endian uint32
            out.write(length_prefix)
            out.write(msg)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print('Usage: {} <input_seed> <output_replay>'.format(sys.argv[0]))
        sys.exit(1)

    convert_to_aflnet_replay(sys.argv[1], sys.argv[2])
