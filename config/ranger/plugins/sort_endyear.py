from ranger.container.directory import Directory

def sort_by_endyear(path):

    pindx = path.relative_path.rfind('.')
    if pindx <= 0:
        pindx = len(path.relative_path)

    lword = path.relative_path[0:pindx].split()[-1]
    if lword.isdigit() and len(lword) == 4:
        return f"{lword}{path.relative_path}"
    else:
        return f"0000{path.relative_path}"

Directory.sort_dict['endyear'] = sort_by_endyear
