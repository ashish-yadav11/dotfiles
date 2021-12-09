# Refer to /usr/share/doc/ranger/config/commands.py for all the default
# commands and a complete documentation.

# We always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command

import os

class mkcd(Command):
    """
    :mkcd <dirname>

    Creates a directory with the name <dirname> and enters it.
    """

    def execute(self):
        import re

        dirname = os.path.join(self.fm.thisdir.path, os.path.expanduser(self.rest(1)))
        if not os.path.lexists(dirname):
            os.makedirs(dirname)

            match = re.search('^/|^~[^/]*/', dirname)
            if match:
                self.fm.cd(match.group(0))
                dirname = dirname[match.end(0):]

            for m in re.finditer('[^/]+', dirname):
                s = m.group(0)
                if s == '..' or (s.startswith('.') and not self.fm.settings['show_hidden']):
                    self.fm.cd(s)
                else:
                    # force ranger to load content before calling `scout`
                    self.fm.thisdir.load_content(schedule=False)
                    self.fm.execute_console(f"scout -ae ^{s}$")
            self.fm.ui.titlebar.need_redraw = True
        else:
            self.fm.notify("file/directory exists!", bad=True)

    def tab(self, tabnum):
        return self._tab_directory_content()


class fzf_search(Command):

    def execute(self):
        from subprocess import PIPE
        from ranger.ext.shell_escape import shell_escape

        if self.arg(1):
            if self.arg(1) == '--':
                fd_args = f"-- {shell_escape(self.rest(2))}"
            elif self.arg(1)[:2] == '-d' and self.arg(1)[2:].isdigit():
                fd_args = f"{shell_escape(self.arg(1))} -- {shell_escape(self.rest(2))}"
            else:
                fd_args = f"-- {shell_escape(self.rest(1))}"
        else:
            fd_args = ''

        command = f"fd -HiIL {fd_args} | cut -c3- | LC_ALL=C sort -f | fzf"
        fzf = self.fm.execute_command(command, stdout=PIPE)
        stdout, stderr = fzf.communicate()
        selection = stdout.decode('utf-8').rstrip('\n')
        self.fm.select_file(os.path.join(self.fm.thisdir.path, selection))

class fzf_cd(Command):

    def execute(self):
        from subprocess import PIPE
        from ranger.ext.shell_escape import shell_escape

        if self.arg(1):
            if self.arg(1) == '--':
                fd_args = f"-- {shell_escape(self.rest(2))}"
            elif self.arg(1)[:2] == '-d' and self.arg(1)[2:].isdigit():
                fd_args = f"{shell_escape(self.arg(1))} -- {shell_escape(self.rest(2))}"
            else:
                fd_args = f"-- {shell_escape(self.rest(1))}"
        else:
            fd_args = ''

        command = f"fd -HiIL -td {fd_args} | cut -c3- | LC_ALL=C sort -f | fzf"
        fzf = self.fm.execute_command(command, stdout=PIPE)
        stdout, stderr = fzf.communicate()
        selection = stdout.decode('utf-8').rstrip('\n')
        self.fm.cd(selection)



def src_in_dst(src, dst):
    if not os.path.isdir(dst) or os.path.islink(dst):
        return False
    f = os.path.realpath(src)
    while True:
        if os.path.samefile(f, dst):
            return True
        d = os.path.dirname(f)
        if d == f:
            return False
        f = d

def is_directory_with_files(path):
    return os.path.isdir(path) and not os.path.islink(path) and len(os.listdir(path)) > 0


archive_folder = "/media/storage/.temporary/.trash" # without trailing slash

class archive_highlighted(Command):

    def execute(self):
        from functools import partial

        cwd = self.fm.thisdir
        tfile = self.fm.thisfile
        if not cwd or not tfile:
            self.fm.notify("Error: no file highlighted for archiving!", bad=True)
            return
        if os.path.samefile(cwd.path, archive_folder):
            self.fm.notify("Highlighted file already in the archive folder!")
            return
        if src_in_dst(archive_folder, tfile.path):
            self.fm.notify("Error: cannot archive (a parent of) the archive folder!", bad=True)
            return

        if is_directory_with_files(tfile.path):
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
        import shutil
        from ranger.ext.safe_path import get_safe_path

        src = tfile.path
        dst = get_safe_path(os.path.join(archive_folder, os.path.basename(src)))
        try:
            os.rename(src, dst)
        except OSError:
            if os.path.isdir(src):
                shutil.copytree(src, dst, symlinks=True)
                shutil.rmtree(src)
            else:
                shutil.copy2(src, dst, follow_symlinks=False)
                os.unlink(src)

        self.fm.notify(f"Archiving {tfile.relative_path}!")

class archive_selection(Command):

    def execute(self):
        from functools import partial

        cwd = self.fm.thisdir
        tfile = self.fm.thisfile
        if not cwd or not tfile:
            self.fm.notify("Error: no file selected for archiving!", bad=True)
            return
        if os.path.samefile(cwd.path, archive_folder):
            self.fm.notify("Selected file(s) already in the archive folder!")
            return

        files = self.fm.thistab.get_selection()
        if any(src_in_dst(archive_folder, f.path) for f in files):
            self.fm.notify("Error: cannot archive (a parent of) the archive folder!", bad=True)
            return

        relative_paths = ', '.join([f.relative_path for f in files])
        if cwd.marked_items or is_directory_with_files(tfile.path):
            self.fm.ui.console.ask(
                f"Confirm archiving of: {relative_paths} (y/N)",
                partial(self._question_callback, files, relative_paths),
                ('n', 'N', 'y', 'Y'),
            )
        else:
            self._archive(files, relative_paths)

    def _question_callback(self, files, relative_paths, answer):
        if answer == 'y' or answer == 'Y':
            self._archive(files, relative_paths)

    def _archive(self, files, relative_paths):
        import shutil
        from ranger.ext.safe_path import get_safe_path

        for f in files:
            src = f.path
            dst = get_safe_path(os.path.join(archive_folder, os.path.basename(src)))

            try:
                os.rename(src, dst)
            except OSError:
                if os.path.isdir(src):
                    shutil.copytree(src, dst, symlinks=True)
                    shutil.rmtree(src)
                else:
                    shutil.copy2(src, dst, follow_symlinks=False)
                    os.unlink(src)

        self.fm.notify(f"Archiving {relative_paths}!")


class trash_highlighted(Command):

    def execute(self):
        from functools import partial

        cwd = self.fm.thisdir
        tfile = self.fm.thisfile
        if not cwd or not tfile:
            self.fm.notify("Error: no file highlighted for trashing!", bad=True)
            return

        if is_directory_with_files(tfile.path):
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
        from functools import partial

        cwd = self.fm.thisdir
        tfile = self.fm.thisfile
        if not cwd or not tfile:
            self.fm.notify("Error: no file selected for trashing!", bad=True)
            return

        files = self.fm.thistab.get_selection()
        relative_paths = ', '.join([f.relative_path for f in files])
        if cwd.marked_items or is_directory_with_files(tfile.path):
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
        from functools import partial

        cwd = self.fm.thisdir
        tfile = self.fm.thisfile
        if not cwd or not tfile:
            self.fm.notify("Error: no file highlighted for deletion!", bad=True)
            return

        confirm = self.fm.settings.confirm_on_delete
        if confirm == 'always' or (confirm == 'multiple' and is_directory_with_files(tfile.path)):
            self.fm.ui.console.ask(
                f"Confirm deletion of: {tfile.relative_path} (y/N)",
                partial(self._question_callback, tfile.relative_path),
                ('n', 'N', 'y', 'Y'),
            )
        else:
            self.fm.delete([tfile.relative_path])

    def _question_callback(self, relative_path, answer):
        if answer == 'y' or answer == 'Y':
            self.fm.delete([relative_path])


class terminal_curdir(Command):

    def execute(self):

        cwd = self.fm.thisdir
        if cwd:
            os.environ['NEWTERM_PWD'] = cwd.path

        self.fm.execute_command(f'st >>"${{XLOGFILE:-/dev/null}}" 2>&1', flags='fs')

class ranger_curfile(Command):

    def execute(self):
        from ranger.ext.shell_escape import shell_escape

        tfile = self.fm.thisfile
        if tfile:
            ranger_command = f"ranger --selectfile={shell_escape(tfile.path)}"
            self.fm.execute_command(f'RANGER_LEVEL=0 st -e {ranger_command} >>"${{XLOGFILE:-/dev/null}}" 2>&1', flags='fs')
        else:
            self.fm.execute_command(f'RANGER_LEVEL=0 st -e ranger >>"${{XLOGFILE:-/dev/null}}" 2>&1', flags='fs')

class ranger_curdir(Command):

    def execute(self):
        from ranger.ext.shell_escape import shell_escape

        cwd = self.fm.thisdir
        if cwd:
            ranger_command = f"ranger {shell_escape(cwd.path)}"
            self.fm.execute_command(f'RANGER_LEVEL=0 st -e {ranger_command} >>"${{XLOGFILE:-/dev/null}}" 2>&1', flags='fs')
        else:
            self.fm.execute_command(f'RANGER_LEVEL=0 st -e ranger >>"${{XLOGFILE:-/dev/null}}" 2>&1', flags='fs')
