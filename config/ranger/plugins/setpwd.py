# We are going to extend the hook "ranger.api.hook_init", so first we need to
# import ranger.api:
import ranger.api

import os

# Save the previously existing hook, because maybe another module already
# extended that hook and we don't want to lose it:
HOOK_INIT_OLD = ranger.api.hook_init

def hook_init(fm):
    HOOK_INIT_OLD(fm)

    def setpwd(sig):
        os.environ['PWD'] = sig.new.path

    fm.signal_bind('cd', setpwd)

# Finally, "monkey patch" the existing hook_init function with our replacement:
ranger.api.hook_init = hook_init
