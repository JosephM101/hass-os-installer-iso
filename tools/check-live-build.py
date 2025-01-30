import subprocess
import sys
from packaging import version

try:
    from colorama import Fore
    color_enabled = True
except ImportError:
    color_enabled = False

if color_enabled == False:
    # Create a dummy color class that returns nothing
    class Fore:
        RED = GREEN = RESET = ''


# Define the minimum required version
LB_MIN_VERSION = "20240810"

def check_live_build_installed():
    try:
        print("Checking live-build... ", end="")

        # Check if live-build is installed
        result = subprocess.run(['lb', '--version'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)

        # Parse the installed version
        installed_version = result.stdout.decode().strip().split()[0]
        print(f"{Fore.GREEN}{installed_version}{Fore.RESET}")
        return installed_version
    except (subprocess.CalledProcessError, IndexError, FileNotFoundError) as e:
        print(f"{Fore.RED}fail!{Fore.RESET}")
        print(f"{Fore.RED}Could not find the 'lb' command. Is live-build installed?{Fore.RESET}")
        sys.exit(1)

def compare_versions(installed_version):
    # Compare installed version with minimum required version
    if version.parse(installed_version) >= version.parse(LB_MIN_VERSION):
        #print(f"live-build version {installed_version} meets the minimum version requirement of {MIN_VERSION}.")
        pass
    else:
        print()
        print(f"""\
Dependency error:
    live-build: {installed_version} < {LB_MIN_VERSION}

{Fore.RED}live-build is installed, but is outdated. You need at least version {LB_MIN_VERSION}.
You may need to get it from somewhere other than your distro's package manager, as that may be several versions behind.{Fore.RESET}\
""")
        sys.exit(1)


def main():
    installed_version = check_live_build_installed()

    try:
        compare_versions(installed_version)
    except:
        print()
        print(f"{Fore.RED}live-build is installed, but the version check failed. \nIt's possible that a very old alpha version is installed, or the version code is unrecognized.{Fore.RESET}")
        print()
        print(f"live-build reported version: {installed_version}")
        print(f"The version code should look like, for example, {LB_MIN_VERSION} (the minimum required version).")
        print()
        print("You will need to compile and install live-build from source. See COMPILING-AND-INSTALLING-LIVEBUILD.md for more information.")
        sys.exit(1)

if __name__ == "__main__":
    main()
