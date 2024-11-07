import re
import os

haos_image_filename_regex = "^haos_generic-x86-64-(\d+\.\d+)\.img\.xz$"

use_binary_size = True  # If true, all storage conversion functions will use the 8-bit units, or the "binary representation" (eg. KiB vs KB) instead of the 10-bit unit system. 
                        # Can be confusing, since the two units are misused ALL THE TIME.
                        # Read this for more info: https://www.mirazon.com/storage-ram-size-doesnt-add/

def get_storage_mutliplier():
    if use_binary_size:
        return 1024  # 8-bit
    else:
        return 1000


def clear_screen():
    os.system('clear')
