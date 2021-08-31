from ranger.colorschemes.default import Default
from ranger.gui.color import black, blue, default, bold


class Scheme(Default):

    def use(self, context):
        fg, bg, attr = Default.use(self, context)

        if context.in_browser:
            if context.inactive_pane:
                fg = black

        elif context.in_titlebar:
            if context.tab:
                if context.good:
                    bg = default
                    fg = default
                else:
                    fg = black

        return fg, bg, attr
