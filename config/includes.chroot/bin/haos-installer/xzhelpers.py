import subprocess
import re
import lzma
import xzhelpers

def xz_get_uncompressed_size(file_path):
    result = subprocess.run(['xz', '-lv', file_path], capture_output=True, text=True)
    # print (result.stdout)
    for line in result.stdout.split('\n'):
        if 'Uncompressed size:' in line:
            size_str = re.search(r'\((.*?) B\)', line).group(1)
            size = int(size_str.replace(',', ''))
            return size
    return None



