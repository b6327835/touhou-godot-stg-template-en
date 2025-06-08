# -*- coding: utf-8 -*-
import os
import sys
import hashlib
import platform
import shutil

if __name__ == '__main__':
    work_dir = os.getcwd()
    if not os.path.exists("../UpdateArchiveFolder"):
        os.mkdir("../UpdateArchiveFolder")
    all_files = {}
    hsb_exists = os.path.exists("./UpdateFunctionTable.txt")
    if hsb_exists:
        with open("./UpdateFunctionTable.txt",'r', encoding='utf-8') as fp:
            text = fp.read()
        t_files = filter(None, text.split('\n'))
        for f in t_files:
            file = f.split(';')
            all_files[file[0]] = file[1]
    else:
        os.mknod("./UpdateFunctionTable.txt")
    
    for root, dirs, files in os.walk(".", topdown=False):
        for f in files:
            is_updated = False
            f_path = os.path.join(root, f)
            with open(f_path, 'rb') as fp:
                data = fp.read()
            f_md5 = hashlib.md5(data).hexdigest()
            if f_path not in all_files:
                is_updated = True
            elif not f_md5 == all_files[f_path]:
                is_updated = True
            # print(is_updated)
            if hsb_exists and is_updated:
                try:
                    n_root = root.replace(".", "../UpdateArchiveFolder", 1)
                    os.makedirs(n_root, exist_ok=True)
                except OSError as e:
                    print(e)
                try:
                    n_path = os.path.join(n_root, f)
                    shutil.copyfile(f_path, n_path)
                except IOError as e:
                    print(e)
                except:
                    print(sys.exc_info())
            all_files[f_path] = f_md5
    
    with open("./UpdateFunctionTable.txt",'w', encoding='utf-8') as fp:
        for key in all_files:
            fp.write(key+";"+all_files[key]+"\n")
