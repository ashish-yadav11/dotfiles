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

        if self.rest(1):
            if self.arg(1)[:2] == '-d':
                fd_args = f"'{self.arg(1)}' '{self.rest(2)}'"
            else:
                fd_args = f"'{self.rest(1)}'"
        else:
            fd_args = ''

        command = f"fd -HiL {fd_args} | LC_COLLATE=C sort -f | fzf"
        fzf = self.fm.execute_command(command, stdout=PIPE)
        stdout, stderr = fzf.communicate()
        selection = stdout.decode('utf-8').rstrip('\n')
        self.fm.select_file(join(self.fm.thisdir.path, selection))


class fzf_cd(Command):

    def execute(self):
        from subprocess import PIPE

        if self.arg(1):
            if self.arg(1)[:2] == '-d':
                fd_args = f"'{self.arg(1)}' '{self.rest(2)}'"
            else:
                fd_args = f"'{self.rest(1)}'"
        else:
            fd_args = ''

        command = f"fd -HiL -td {fd_args} | LC_COLLATE=C sort -f | fzf"
        fzf = self.fm.execute_command(command, stdout=PIPE)
        stdout, stderr = fzf.communicate()
        selection = stdout.decode('utf-8').rstrip('\n')
        self.fm.cd(selection)


class trash_highlighted(Command):

    def execute(self):
        import os
        from functools import partial

        def is_directory_with_files(path):
            return os.path.isdir(path) and not os.path.islink(path) and len(os.listdir(path)) > 0

        cwd = self.fm.thisdir
        tfile = self.fm.thisfile
        if not cwd or not tfile:
            self.fm.notify("Error: no file highlighted for trashing!", bad=True)
            return

        many_files = is_directory_with_files(tfile.path)
        if many_files:
            self.fm.ui.console.ask(
                "Confirm trashing of: %s (y/N)" % tfile.relative_path,
                partial(self._question_callback, tfile),
                ('n', 'N', 'y', 'Y'),
            )
        else:
            self._trash(tfile)

    def _question_callback(self, tfile, answer):
        if answer == 'y' or answer == 'Y':
            self._trash(tfile)

    def _trash(self, tfile):
        from ranger.ext.shell_escape import shell_escape

        self.fm.execute_command("trash-put -- %s" % shell_escape(tfile.path), flags='s')
        self.fm.notify("Trashing %s!" % tfile.relative_path)


class trash_selection(Command):

    def execute(self):
        import os
        from functools import partial

        def is_directory_with_files(path):
            return os.path.isdir(path) and not os.path.islink(path) and len(os.listdir(path)) > 0

        cwd = self.fm.thisdir
        tfile = self.fm.thisfile
        if not cwd or not tfile:
            self.fm.notify("Error: no file selected for trashing!", bad=True)
            return

        files = self.fm.thistab.get_selection()
        relative_paths = [f.relative_path for f in files]
        many_files = (cwd.marked_items or is_directory_with_files(tfile.path))

        if many_files:
            self.fm.ui.console.ask(
                "Confirm trashing of: %s (y/N)" % ', '.join(relative_paths),
                partial(self._question_callback, files),
                ('n', 'N', 'y', 'Y'),
            )
        else:
            self._trash(files)

    def _question_callback(self, files, answer):
        if answer == 'y' or answer == 'Y':
            self._trash(files)

    def _trash(self, files):
        from ranger.ext.shell_escape import shell_escape

        escaped_paths = [shell_escape(f.path) for f in files]
        relative_paths = [f.relative_path for f in files]
        self.fm.execute_command("trash-put -- %s" % ' '.join(escaped_paths), flags='s')
        self.fm.notify("Trashing %s!" % ', '.join(relative_paths))


class delete_highlighted(Command):

    def execute(self):
        import os
        from functools import partial

        def is_directory_with_files(path):
            return os.path.isdir(path) and not os.path.islink(path) and len(os.listdir(path)) > 0

        cwd = self.fm.thisdir
        tfile = self.fm.thisfile
        if not cwd or not tfile:
            self.fm.notify("Error: no file highlighted for deletion!", bad=True)
            return

        files = [tfile.relative_path]
        many_files = is_directory_with_files(tfile.path)

        confirm = self.fm.settings.confirm_on_delete
        if confirm != 'never' and (confirm != 'multiple' or many_files):
            self.fm.ui.console.ask(
                "Confirm deletion of: %s (y/N)" % files[0],
                partial(self._question_callback, files),
                ('n', 'N', 'y', 'Y'),
            )
        else:
            # no need for a confirmation, just delete
            self.fm.delete(files)

    def _question_callback(self, files, answer):
        if answer == 'y' or answer == 'Y':
            self.fm.delete(files)
