# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command


class mkcd(Command):
    """
    :mkcd <dirname>

    Creates a directory with the name <dirname> and enters it.
    """

    def execute(self):
        from os.path import join, expanduser, lexists
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


class fzf_search(Command):

    def execute(self):
        from os.path import join
        from subprocess import PIPE

        depth = '-d4'
        target = ''
        if self.arg(1):
            if self.arg(1)[:2] == '-d':
                depth = self.arg(1)
                target = ' ' + self.rest(2)
            else:
                target = ' ' + self.rest(1)

        command="fd -HL " + depth + target + " | LC_COLLATE=C sort -f | fzf"
        fzf = self.fm.execute_command(command, stdout=PIPE)
        stdout, stderr = fzf.communicate()
        file_dir = stdout.decode('utf-8').rstrip('\n')
        self.fm.select_file(join(self.fm.thisdir.path, file_dir))


class fzf_cd(Command):

    def execute(self):
        from subprocess import PIPE

        depth = '-d4'
        target = ''
        if self.arg(1):
            if self.arg(1)[:2] == '-d':
                depth = self.arg(1)
                target = ' ' + self.rest(2)
            else:
                target = ' ' + self.rest(1)

        command="fd -HL -td " + depth + target + " | LC_COLLATE=C sort -f | fzf"
        fzf = self.fm.execute_command(command, stdout=PIPE)
        stdout, stderr = fzf.communicate()
        directory = stdout.decode('utf-8').rstrip('\n')
        self.fm.cd(directory)


class trash_selection(Command):

    def execute(self):
        import os
        from functools import partial

        def is_directory_with_files(path):
            return os.path.isdir(path) and not os.path.islink(path) and len(os.listdir(path)) > 0

        cwd = self.fm.thisdir
        tfile = self.fm.thisfile
        if not cwd or not tfile:
            self.fm.notify("Error: no file selected for deletion!", bad=True)
            return

        # relative_path used for a user-friendly output in the confirmation.
        files = [f.relative_path for f in self.fm.thistab.get_selection()]
        many_files = (cwd.marked_items or is_directory_with_files(tfile.path))

        confirm = self.fm.settings.confirm_on_delete
        if confirm != 'never' and (confirm != 'multiple' or many_files):
            self.fm.ui.console.ask(
                "Confirm trashing of: %s (y/N)" % ', '.join(files),
                partial(self._question_callback),
                ('n', 'N', 'y', 'Y'),
            )
        else:
            # no need for a confirmation, just delete
            self._trash()

    def _question_callback(self, answer):
        if answer == 'y' or answer == 'Y':
            self._trash()

    def _trash(self):
        from ranger.ext.shell_escape import shell_escape

        selected_files = [shell_escape(f.path) for f in self.fm.thistab.get_selection()]
        self.fm.execute_command("trash-put -- " + ' '.join(selected_files), flags='s')
