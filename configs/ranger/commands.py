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


archive_folder = "/media/storage/.temporary/.trash" # without trailing slash

class archive_highlighted(Command):

    def execute(self):
        import os
        from functools import partial

        def is_directory_with_files(path):
            return os.path.isdir(path) and not os.path.islink(path) and len(os.listdir(path)) > 0

        cwd = self.fm.thisdir
        if (cwd.path == archive_folder):
            self.fm.notify("Error: cannot archive from archive folder!", bad=True)
            return

        tfile = self.fm.thisfile
        if (tfile.path == archive_folder):
            self.fm.notify("Error: cannot archive the archive folder!", bad=True)
            return

        if not cwd or not tfile:
            self.fm.notify("Error: no file highlighted for archiving!", bad=True)
            return

        many_files = is_directory_with_files(tfile.path)
        if many_files:
            self.fm.ui.console.ask(
                f"Confirm archiving of: {tfile.relative_path} (y/N)",
                partial(self._question_callback, tfile),
                ('n', 'N', 'y', 'Y'),
            )
        else:
            self._archive(tfile)

    def _question_callback(self, tfile, answer):
        if answer == 'y' or answer == 'Y':
            self._archive(tfile)

    def _archive(self, tfile):
        from ranger.ext.shell_escape import shell_escape

        escaped_path = shell_escape(tfile.path)
        self.fm.execute_command(f"mv --backup=numbered {escaped_path} {archive_folder}/", flags='s')
        self.fm.notify(f"Archiving {tfile.relative_path}!")


class archive_selection(Command):

    def execute(self):
        import os
        from functools import partial

        def is_directory_with_files(path):
            return os.path.isdir(path) and not os.path.islink(path) and len(os.listdir(path)) > 0

        cwd = self.fm.thisdir
        if (cwd.path == archive_folder):
            self.fm.notify("Error: cannot archive from archive folder!", bad=True)
            return

        tfile = self.fm.thisfile
        if not cwd or not tfile:
            self.fm.notify("Error: no file selected for archiving!", bad=True)
            return

        files = self.fm.thistab.get_selection()
        paths = [f.path for f in files]
        if archive_folder in paths:
            self.fm.notify("Error: cannot archive the archive folder!", bad=True)
            return

        relative_paths = ', '.join([f.relative_path for f in files])
        many_files = (cwd.marked_items or is_directory_with_files(tfile.path))

        if many_files:
            self.fm.ui.console.ask(
                f"Confirm archiving of: {relative_paths} (y/N)",
                partial(self._question_callback, paths, relative_paths),
                ('n', 'N', 'y', 'Y'),
            )
        else:
            self._archive(paths, relative_paths)

    def _question_callback(self, paths, relative_paths, answer):
        if answer == 'y' or answer == 'Y':
            self._archive(paths, relative_paths)

    def _archive(self, paths, relative_paths):
        from ranger.ext.shell_escape import shell_escape

        escaped_paths = ' '.join([shell_escape(path) for path in paths])
        self.fm.execute_command(f"mv --backup=numbered {escaped_paths} {archive_folder}/", flags='s')
        self.fm.notify(f"Archiving {relative_paths}!")


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
                f"Confirm trashing of: {tfile.relative_path} (y/N)",
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

        escaped_path = shell_escape(tfile.path)
        self.fm.execute_command(f"trash-put -- {escaped_path}", flags='s')
        self.fm.notify(f"Trashing {tfile.relative_path}!")


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
        relative_paths = ', '.join([f.relative_path for f in files])
        many_files = (cwd.marked_items or is_directory_with_files(tfile.path))

        if many_files:
            self.fm.ui.console.ask(
                f"Confirm trashing of: {relative_paths} (y/N)",
                partial(self._question_callback, files, relative_paths),
                ('n', 'N', 'y', 'Y'),
            )
        else:
            self._trash(files, relative_paths)

    def _question_callback(self, files, relative_paths, answer):
        if answer == 'y' or answer == 'Y':
            self._trash(files, relative_paths)

    def _trash(self, files, relative_paths):
        from ranger.ext.shell_escape import shell_escape

        escaped_paths = ' '.join([shell_escape(f.path) for f in files])
        self.fm.execute_command(f"trash-put -- {escaped_paths}", flags='s')
        self.fm.notify(f"Trashing {relative_paths}!")


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
                f"Confirm deletion of: {files[0]} (y/N)",
                partial(self._question_callback, files),
                ('n', 'N', 'y', 'Y'),
            )
        else:
            self.fm.delete(files)

    def _question_callback(self, files, answer):
        if answer == 'y' or answer == 'Y':
            self.fm.delete(files)
