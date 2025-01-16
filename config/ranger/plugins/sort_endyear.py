from ranger.container.directory import Directory

def sort_by_endyear(path):

    pindx = path.relative_path.rfind('.')
    if pindx <= 0:
        pindx = len(path.relative_path)
    basename = path.relative_path[0:pindx]

    year = '9999'
    for word in reversed(basename.split()):
        if word.isdigit() and len(word) == 4:
            year = word
            break
    return f"{year}{path.relative_path}"

Directory.sort_dict['endyear'] = sort_by_endyear
