-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/aatiis/.config/awesome/theme.lua")

-- Register commands for later
printscr   = "ksnapshot"
konsole    = "konsole"
urxvt      = "urxvt -e byobu -U"

chromium   = "chromium"
firefox    = "firefox"
opera      = "opera"

wallpaper  = "/home/aatiis/pics/chwall"

nautilus   = "nautilus -n"
xcompmgr   = "xcompmgr -c -C -f -F -D 2.5 -l -2 -t -2 -r 2 -o 0.25"
powerman   = "gnome-power-manager"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.magnifier,
    awful.layout.suit.max,
    awful.layout.suit.floating,
    awful.layout.suit.max.fullscreen
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(
        { '[ C ]', '[ 1 ]', '[ 2 ]', '[ 3 ]', '[ 4 ]', '[ 5 ]'},
        s,
        {
            awful.layout.suit.max,
            awful.layout.suit.magnifier,
            awful.layout.suit.max,
            awful.layout.suit.max,
            awful.layout.suit.max,
            awful.layout.suit.max,
        }
    )
end
-- }}}

-- {{{ Hex converter, for RGB colors
function hex(inp)
    return inp > 16 and string.format("%X", inp) or string.format("0%X", inp)
end
-- }}}

-- {{{ Heat monitor
myheatmon = widget({ type = "textbox", name = "myheatmon", align = "right" })
function heat_status ()
    local output = {} -- output buffer
    local fd = io.popen("cat /sys/class/thermal/thermal_zone0/temp", "r") -- cat first thermal zone
    local line = fd:read()
    local heat = string.match(line, "(%d+)")
    if heat then
        heat = tonumber(heat) / 1000
        table.insert(output, "<span color=\"#"
            .. hex(255 * (heat - 40) / 65)
            .. hex(255 * (105 - heat) / 65)
            .. "00\">" .. heat .. "&#8451;</span>")
    end
    return table.concat(output, " ")
end
myheatmon.text = heat_status() .. " "
my_heatmon_timer = timer({timeout = 19})
my_heatmon_timer:add_signal("timeout", function()
    myheatmon.text = heat_status() .. " "
end)
my_heatmon_timer:start()
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, "%H:%M:%S", 1 )

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylayoutbox[s],
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mytextclock,
        myheatmon,
        mybattmon,
        mysystray, -- was: s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Print screen
    awful.key({                   }, "Print",   function () awful.util.spawn(printscr)        end),

    -- Standard programs
    awful.key({ modkey,           }, "Return",  function () awful.util.spawn(konsole)         end),
    awful.key({ modkey,           }, "'",       function () awful.util.spawn(chromium)        end),
    awful.key({ modkey,           }, "q",       function () awful.util.spawn(firefox)         end),
    awful.key({ modkey,           }, "j",       function () awful.util.spawn(opera)           end),
    awful.key({ modkey, "Control" }, "w",       function () awful.util.spawn(wallpaper)       end),
    awful.key({ modkey, "Control" }, "r",       awesome.restart                                  ),
    awful.key({ modkey, "Shift"   }, "q",       awesome.quit                                     ),

    awful.key({ modkey,           }, "l",       function () awful.tag.incmwfact( 0.05)        end),
    awful.key({ modkey,           }, "h",       function () awful.tag.incmwfact(-0.05)        end),
    awful.key({ modkey, "Shift"   }, "h",       function () awful.tag.incnmaster( 1)          end),
    awful.key({ modkey, "Shift"   }, "l",       function () awful.tag.incnmaster(-1)          end),
    awful.key({ modkey, "Control" }, "h",       function () awful.tag.incncol( 1)             end),
    awful.key({ modkey, "Control" }, "l",       function () awful.tag.incncol(-1)             end),
    awful.key({ modkey,           }, "space",   function () awful.layout.inc(layouts,  1)     end),
    awful.key({ modkey, "Shift"   }, "space",   function () awful.layout.inc(layouts, -1)     end),

    -- Prompt
    awful.key({ modkey            }, "r",       function () mypromptbox[mouse.screen]:run()   end),

    awful.key({ modkey            }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",        function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",        function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",    awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return",   function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",        awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",        function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",        function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "URxvt" },
      properties = { border_width = 0 } },
    { rule = { class = "Konsole" },
      properties = { border_width = 0 } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    -- c:add_signal("mouse::enter", function(c)
    --     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    --         and awful.client.focus.filter(c) then
    --         client.focus = c
    --     end
    -- end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they do not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Startup scripts:
awful.util.spawn(nautilus)
awful.util.spawn(xcompmgr)
awful.util.spawn(powerman)
