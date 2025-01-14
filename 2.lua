local server = {
    [0] = "connect 62.122.215.105:6666",
    [1] = "connect 46.174.51.137:7777",
    [2] = "connect 46.174.55.52:1488",
    [3] = "connect 46.174.52.69:27015"
}
local ind = ui.new_listbox("Lua", "B", "Name", {"eXpidors ONLY SCOUT", "eXpidors MM 16k", "spinn on wok mm hvh", "Shark Arena"})
ui.new_button("Lua", "B", "Connect", function() client.exec(server[ui.get(ind)]) end)