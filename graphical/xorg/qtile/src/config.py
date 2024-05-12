import subprocess
from enum import StrEnum
from pathlib import Path

from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy


@hook.subscribe.startup
def autostart() -> None:
    autostart_script = Path.home() / ".config/xinit/autostart.sh"
    subprocess.run([str(autostart_script)])


class ModifierKey(StrEnum):
    ALT = "mod1"
    CONTROL = "control"
    SHIFT = "shift"
    SUPER = "mod4"


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html

    # Switch between windows
    Key([ModifierKey.SUPER], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([ModifierKey.SUPER], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([ModifierKey.SUPER], "j", lazy.layout.down(), desc="Move focus down"),
    Key([ModifierKey.SUPER], "k", lazy.layout.up(), desc="Move focus up"),
    Key([ModifierKey.SUPER], "space", lazy.layout.next(), desc="Move window focus to other window"),
    Key([ModifierKey.SUPER], "Tab", lazy.group.next_window(), desc="Move window focus to next window in group"),
    Key([ModifierKey.SUPER, ModifierKey.SHIFT], "Tab", lazy.group.prev_window(), desc="Move window focus to previous window in group"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([ModifierKey.SUPER, ModifierKey.SHIFT], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([ModifierKey.SUPER, ModifierKey.SHIFT], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([ModifierKey.SUPER, ModifierKey.SHIFT], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([ModifierKey.SUPER, ModifierKey.SHIFT], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([ModifierKey.SUPER, ModifierKey.CONTROL], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([ModifierKey.SUPER, ModifierKey.CONTROL], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([ModifierKey.SUPER, ModifierKey.CONTROL], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([ModifierKey.SUPER, ModifierKey.CONTROL], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([ModifierKey.SUPER, ModifierKey.CONTROL], "r", lazy.layout.normalize(), desc="Reset all window sizes"),
    
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([ModifierKey.SUPER, ModifierKey.SHIFT], "Return", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),
    
    # Toggle between different layouts as defined below
    Key([ModifierKey.SUPER], "Space", lazy.next_layout(), desc="Toggle between layouts"),
    Key([ModifierKey.SUPER], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([ModifierKey.SUPER, ModifierKey.SHIFT], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on the focused window"),
    Key([ModifierKey.SUPER], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([ModifierKey.SUPER, ModifierKey.CONTROL, ModifierKey.ALT], "r", lazy.reload_config(), desc="Reload the config"),
    Key([ModifierKey.SUPER, ModifierKey.CONTROL, ModifierKey.ALT, ModifierKey.SHIFT], "Escape", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([ModifierKey.SUPER], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
]

# Drag floating layouts.
mouse = [
    Drag([ModifierKey.SUPER], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([ModifierKey.SUPER], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([ModifierKey.SUPER], "Button2", lazy.window.bring_to_front()),
]

# FIXME: WTF IS THIS?
#
# # Add key bindings to switch VTs in Wayland.
# # We can't check qtile.core.name in default config as it is loaded before qtile is started
# # We therefore defer the check until the key binding is run by using .when(func=...)
# for vt in range(1, 8):
#     keys.append(
#         Key(
#             [ModifierKey.CONTROL, ModifierKey.SUPER],
#             f"f{vt}",
#             lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
#             desc=f"Switch to VT{vt}",
#         )
#     )


groups = [Group(i) for i in "1"]

for i in groups:
    keys.extend(
        [
            # ModifierKey.SUPER + group number = switch to group
            Key(
                [ModifierKey.SUPER],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # ModifierKey.SUPER + shift + group number = switch to & move focused window to group
            Key(
                [ModifierKey.SUPER, ModifierKey.SHIFT],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # ModifierKey.SUPER + shift + group number = move focused window to group
            # Key([ModifierKey.SUPER, ModifierKey.SHIFT], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    layout.Max(),
    layout.Stack(num_stacks=2),
    layout.Bsp(),
    layout.Matrix(),
    layout.MonadTall(),
    layout.MonadWide(),
    layout.RatioTile(),
    layout.Tile(),
    layout.TreeTab(),
    layout.VerticalTile(),
    layout.Zoomy(),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

# You can uncomment this variable if you see that on X11 floating resize/moving is laggy
# By default we handle these events delayed to already improve performance, however your system might still be struggling
# This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
#       Screen(x11_drag_polling_rate = 60)
screens = [Screen()]

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = False
bring_front_click = False
floats_kept_above = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# Run the utility of `xprop` to see the wm class and name of an X client.
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="termprompt")
    ]
)

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
