# We are going to extend the hook "ranger.api.hook_init", so first we need to
# import ranger.api:
import ranger.api

import os

# Save the previously existing hook, because maybe another module already
# extended that hook and we don't want to lose it:
HOOK_INIT_OLD = ranger.api.hook_init

def hook_init(fm):
    HOOK_INIT_OLD(fm)

    def settitlecd(sig):
        print(f"\033]0;ranger:{sig.new.path}\033\\", end='', flush=True)

    def settitleea():
        print(f"\033]0;ranger{fm.thisdir}\033\\", end='', flush=True)

    fm.signal_bind('cd', settitlecd)
    fm.signal_bind('runner.execute.after', settitleea)

# Finally, "monkey patch" the existing hook_init function with our replacement:
TERM = os.environ.get('TERM', '')
if TERM.startswith('st') or TERM.startswith('alacritty') or 'xterm' in TERM:
    ranger.api.hook_init = hook_init