import os
import sys
import time

from fandango.evolution.algorithm import Fandango, LoggerLevel
from fandango.language.grammar import FuzzingMode
from fandango.language.parse.parse import parse


def main():
    sys.setrecursionlimit(10**6)
    for _ in range(10):
        # Parse grammar and constraints
        with open("ftp_client.fan") as f:
            grammar, constraints = parse(f, use_stdlib=True)
        assert grammar is not None
        fandango = Fandango(
            grammar=grammar,
            constraints=constraints,
            logger_level=LoggerLevel.INFO
        )

        try:
            for solution in fandango.generate(mode=FuzzingMode.IO):
                pass
        finally:
            pass

if __name__ == "__main__":
    main()
