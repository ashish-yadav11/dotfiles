# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command


from os.path import join

class mkcd(Command):
    """
    :mkcd <dirname>

    Creates a directory with the name <dirname> and enters it.
    """

    def execute(self):
        from os.path import expanduser, lexists
        from os import makedirs
        import re

        dirname = join(self.fm.thisdir.path, expanduser(self.rest(1)))
        if not lexists(dirname):
            makedirs(dirname)

            match = re.search('^/|^~[^/]*/', dirname)
            if match:
                self.fm.cd(match.group(0))
                dirname = dirname[match.end(0):]

            for m in re.finditer('[^/]+', dirname):
                s = m.group(0)
                if s == '..' or (s.startswith('.') and not self.fm.settings['show_hidden']):
                    self.fm.cd(s)
                else:
                    ## We force ranger to load content before calling `scout`.
                    self.fm.thisdir.load_content(schedule=False)
                    self.fm.execute_console('scout -ae ^{}$'.format(s))
        else:
            self.fm.notify("file/directory exists!", bad=True)


from subprocess import PIPE
fzf_command = "fzf --bind=change:top,ctrl-a:select-all,ctrl-t:toggle-all,ctrl-z:top,ctrl-space:toggle-sort --sync -1"

class fzf_search(Command):
    def execute(self):
        depth = '-d4'
        target = ''
        if self.arg(1):
            if self.arg(1)[:2] == '-d':
                depth = self.arg(1)
                target = ' ' + self.rest(2)
            else:
                target = ' ' + self.rest(1)

        command="fd -HL " + depth + target + " | LC_COLLATE=C sort -f | " + fzf_command
        fzf = self.fm.execute_command(command, stdout=PIPE)
        stdout, stderr = fzf.communicate()
        file_dir = stdout.decode('utf-8').rstrip('\n')
        self.fm.select_file(join(self.fm.thisdir.path, file_dir))


class fzf_cd(Command):
    def execute(self):
        depth = '-d4'
        target = ''
        if self.arg(1):
            if self.arg(1)[:2] == '-d':
                depth = self.arg(1)
                target = ' ' + self.rest(2)
            else:
                target = ' ' + self.rest(1)

        command="fd -HL -td " + depth + target + " | LC_COLLATE=C sort -f | " + fzf_command
        fzf = self.fm.execute_command(command, stdout=PIPE)
        stdout, stderr = fzf.communicate()
        directory = stdout.decode('utf-8').rstrip('\n')
        self.fm.cd(directory)
