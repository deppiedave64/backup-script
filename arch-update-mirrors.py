import argparse
import subprocess
import shutil
import os

parser = argparse.ArgumentParser(description="Create a new pacman mirrorlist file with mirrors sorted by speed.")
parser.add_argument('-n', '--mirror-number', type=int, default=100, help="Number of mirrors to collect.")
args = parser.parse_args()

MIRROR_NUMBER = args.mirror_number

if os.path.isfile("/etc/pacman.d/mirrorlist"):
    print("mirrorlist already exists. Creating a backup and writing a new one...")
    try:
        shutil.copyfile("/etc/pacman.d/mirrorlist", "/etc/pacman.d/mirrorlist.bak")
        print("Succesfully backed up mirrorlist.")
    except OSError:
        print("Cannot read and write mirrorlist. Check for permissions")
        exit(1)

print("Creating new mirrorlist...")
subprocess.run(["reflector", "-p", "https", "-n", str(MIRROR_NUMBER), "-f", str(MIRROR_NUMBER), "--sort", "rate", "--save", "/etc/pacman.d/mirrorlist"])
print("Succesfully created new mirrorlist!")