import os
import sys

from fandango.evolution.algorithm import Fandango, LoggerLevel
from fandango.io.navigation.coverage_goal import CoverageGoal
from fandango.language.grammar import FuzzingMode
from fandango.language.parse.parse import parse


def main():
    sys.setrecursionlimit(10**6)
    # Parse grammar and constraints
    with open("ftp_client.fan") as f:
        grammar, constraints = parse(f, use_stdlib=True)
    assert grammar is not None
    fandango = Fandango(
        grammar=grammar,
        constraints=constraints,
        logger_level=LoggerLevel.DEBUG,
        coverage_goal=CoverageGoal.INPUTS,
    )
    fandango.coverage_log_interval = 10
    solutions = []
    try:
        for solution in fandango.generate(mode=FuzzingMode.IO):
            solutions.append(solution)
    finally:
        seed_nr = 0
        os.makedirs("capture", exist_ok=True)
        for solution in solutions:
            run_msgs = []
            for msg in solution.protocol_msgs():
                if msg.sender in ['ClientControl', 'ClientData']:
                    run_msgs.append(bytes(msg.msg))
            if len(run_msgs) > 0:
                seed_nr += 1
                with open(f"capture/seed_{seed_nr}.raw", "ab") as f:
                    f.writelines(run_msgs)
        pass

if __name__ == "__main__":
    main()
