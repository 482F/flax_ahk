from mutagen.easyid3 import EasyID3
import sys
argvs = sys.argv
path = argvs[1]
tags = EasyID3(path)
if argvs[2] == "get":
    for argv in argvs[3:]:
        if argv in tags:
            k = tags[argv][0].encode("cp932", "ignore").decode("cp932")
            print(k)
        else:
            print()
elif argvs[2] == "edit":
    tags["title"] = argvs[3]
    if 5 <= len(argvs):
        tags["artist"] = argvs[4]
    if 6 <= len(argvs):
        tags["album"] = argvs[5]
    tags.save()
