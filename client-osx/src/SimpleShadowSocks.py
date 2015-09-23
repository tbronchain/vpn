#!/usr/bin/python
'''
 Easy ShadowSocks
 by Thibault Bronchain
 (c) 2015 Almaritech Ltd. - All Rights Reserved
'''

import rumps
import subprocess
import json
import os
import time

base_model = {
    "server":"127.0.0.1",
    "server_port":443,
    "local_port":8080,
    "password":"my_password",
    "timeout":300,
    "method":"aes-256-cfb"
}

class SimpleShadowSocks(rumps.App):
    def __init__(self):
        super(SimpleShadowSocks, self).__init__("ES")
        self.menu = ["Disconnect", "Reconnect", "Change IP", "Change Password", "About"]
        subprocess.call(["launchctl","load",os.path.expanduser("~/Library/LaunchAgents/homebrew.mxcl.shadowsocks-libev.plist")])
        pout,perr = subprocess.Popen("networksetup -getsocksfirewallproxy Wi-Fi | grep \"^Enabled: Yes$\" | wc -l", shell=True, stdout=subprocess.PIPE).communicate()
        print "res = %s"%pout
        res = 0
        try:
            res = int(pout)
        except:
            pass
        if res != 1:
            subprocess.call(["networksetup","-setsocksfirewallproxy","Wi-Fi","127.0.0.1","8080"])
            subprocess.call(["networksetup","-setsocksfirewallproxystate","Wi-Fi","on"])

    @rumps.clicked("Reconnect")
    def reconnect(self, sender):
        subprocess.call(["launchctl","unload",os.path.expanduser("~/Library/LaunchAgents/homebrew.mxcl.shadowsocks-libev.plist")])
        time.sleep(1)
        subprocess.call(["launchctl","load",os.path.expanduser("~/Library/LaunchAgents/homebrew.mxcl.shadowsocks-libev.plist")])
        #rumps.alert("Easy ShadowSocks", "Reconnected!")

    @rumps.clicked("Disconnect")
    def disconnect(self, sender):
        if sender.title == "Disconnect":
            subprocess.call(["networksetup","-setsocksfirewallproxystate","Wi-Fi","off"])
            subprocess.call(["launchctl","unload",os.path.expanduser("~/Library/LaunchAgents/homebrew.mxcl.shadowsocks-libev.plist")])
            time.sleep(1)
            sender.title = 'Connect'
            #rumps.alert("Easy ShadowSocks", "Disconnected!")
        else:
            subprocess.call(["launchctl","load",os.path.expanduser("~/Library/LaunchAgents/homebrew.mxcl.shadowsocks-libev.plist")])
            subprocess.call(["networksetup","-setsocksfirewallproxy","Wi-Fi","127.0.0.1","8080"])
            subprocess.call(["networksetup","-setsocksfirewallproxystate","Wi-Fi","on"])
            time.sleep(1)
            sender.title = 'Disconnect'
            #rumps.alert("Easy ShadowSocks", "Connected!")

    def change_something(self, message, key):
        model = None
        try:
            with open("/usr/local/etc/shadowsocks-libev.json", "r") as f:
                model = json.loads(f.read())
        except:
            pass
        if not model:
            print "Warning: using base model"
            model = base_model
        w = rumps.Window(message=message, title='Easy ShadowSocks',default_text=model.get(key,""),cancel=True)
        r = w.run()
        if not r.clicked:
            return
        model[key] = r.text
        with open("/usr/local/etc/shadowsocks-libev.json", "w") as f:
            f.write(json.dumps(model))
        subprocess.call(["launchctl","unload",os.path.expanduser("~/Library/LaunchAgents/homebrew.mxcl.shadowsocks-libev.plist")])
        time.sleep(1)
        subprocess.call(["launchctl","load",os.path.expanduser("~/Library/LaunchAgents/homebrew.mxcl.shadowsocks-libev.plist")])

    @rumps.clicked("Change IP")
    def change_ip(self, _):
        self.change_something("Set the server's address:", "server")

    @rumps.clicked("Change Password")
    def change_ip(self, _):
        self.change_something("Set the server's password:", "password")

    @rumps.clicked("About")
    def about(self, _):
        rumps.alert("Easy ShadowSocks", "Author: Thibault Bronchain\n(c) 2015 Almaritech Ltd. - All Rights Reserved")

if __name__ == "__main__":
    SimpleShadowSocks().run()
