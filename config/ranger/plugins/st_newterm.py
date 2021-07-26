# We are going to extend the hook "ranger.api.hook_init", so first we need to
# import ranger.api:
import ranger.api

import os

# Save the previously existing hook, because maybe another module already
# extended that hook and we don't want to lose it:
HOOK_INIT_OLD = ranger.api.hook_init

def hook_init(fm):
    HOOK_INIT_OLD(fm)

    def send_pwd(sig):
        print(f"\033]7;{sig.new}\033\\", end='', flush=True)

    fm.signal_bind('cd', send_pwd)

# Finally, "monkey patch" the existing hook_init function with our replacement:
if os.environ.get('TERM', '').startswith('st'):
    ranger.api.hook_init = hook_init
