#!/bin/env python

import os
import itertools
import logging
import lupa
import codecs
import sys
from pprint import pformat
from configparser import ConfigParser
from toposort import toposort_flatten

logger_level = logging.DEBUG
logger_formatter = "[%(asctime)s][%(name)s] %(levelname)s :: %(message)s"
logging.basicConfig(level=logger_level, format=logger_formatter)
py_logger = logging.getLogger("python")
lua_logger = logging.getLogger("lua")
fake_logger = logging.getLogger("lua_sys")

#py_logger.setLevel(logger_level)
#lua_logger.setLevel(logger_level)
#fake_logger.setLevel(logger_level)

# ts: topology_sort_table, cs: configs_table
def load_package_ini(lua, root_dir):
    ts, cs = {}, {}
    py_logger.info("loading inis from %s"%root_dir)
    for m in os.listdir(root_dir):
        if m[0]!="." and not os.path.isfile(m):
            lm = os.path.join(root_dir, m)
            lm_ini = os.path.join(lm, "info.ini")
            if os.path.isfile(lm_ini):
                f = codecs.open(lm_ini, encoding='gbk', mode='r')
                c = f.read()
                #print(lm_ini, f.read())
                config = ConfigParser()
                config.read_string(c)
                if m in config:
                    #py_logger.info("%s(%s) in %s (ver %s): %s"%(
                    #    config[m]["name"], m, config[m]["package"], config[m]["version"], config[m]["desc"]))
                    if "dependence" in config[m]:
                        ts[m] = set(x.strip() for x in config[m]["dependence"].split(";") if x.strip() != "")
                    else:
                        ts[m] = set()
                    ls = []
                    for i in itertools.count():
                        luaitemkey = "lua_%d"%i
                        if luaitemkey in config[m]:
                            fn = config[m][luaitemkey]
                            #print("loading...", fn)
                            ls.append(fn)
                        else:
                            break
                    cs[m] = ls #(config, ls)
                f.close()

    py_logger.debug("ts:%s", pformat(ts))
    py_logger.debug("cs:%s", pformat(cs))
    return ts, cs

def fake(lua, name, item, force=False):
    tostring = lua.globals().tostring
    if not force and name in lua.globals():
        fake_logger.warning("fake %s with %s failed, there's already %s", name, tostring(item), tostring(lua.globals()[name]))
    else:
        lua.globals()[name] = item
        fake_logger.info("fake %s with %s successfully", name, tostring(item))

def make_stubs(lua, stubs_file):
    dofile = lua.globals().dofile
    stubs = dofile(stubs_file)
    for n in stubs:
        fake(lua, n, stubs[n])

def load_lua_file(lua, rootdir, ts, cs):
    dofile = lua.globals().dofile
    for m in toposort_flatten(ts):
        for fn in cs[m]:
            fnn = os.path.join(root_dir, m, fn)
            py_logger.debug("loading... '%s'", fnn)
            try:
                dofile(fnn)
            except Exception as e:
                py_logger.error("%s", e)

def make_print_from_logger(logger, level=logging.INFO):
    tostring = lua.globals().tostring
    def print(*args):
        logger.log(level, "%s", " ".join([tostring(x) for x in args]))
    return print

class ReadlineHistory:
    def __init__(self, history=".hist"):
        self.history = history
        self.readline = sys.modules["readline"]

    def __enter__(self):
        py_logger.debug("read history file %s", self.history)
        try:
            self.readline.read_history_file(self.history)
        except:
            open(".hist", "a").close()
        return self

    def append(self, s):
        #py_logger.debug("append %s into history file %s", s, self.history)
        #self.readline.add_history(s, self.history)
        pass

    def __exit__(self, exc_type, exc_value, traceback):
        #py_logger.debug("%s", sorted(sys.modules.keys()))
        #self.readline.save_history_file(self.history)
        pass

def make_shell(lua, history=".hist"):
    with ReadlineHistory() as rl:
        while True:
            try:
                s = input()
            except EOFError:
                py_logger.debug("readline: EOF")
                break
            except Exception as e:
                py_logger.error("readline error: %s", e)
            py_logger.debug("readline: %s", s)
            if s == "exit":
                break
            else:
                rl.append(s)
                try:
                    lua.execute(s)
                except lupa.LuaSyntaxError as e:
                    py_logger.error("LuaSyntaxError: %s", e)
                except lupa.LuaError as e:
                    py_logger.error("LuaError: %s", e)
                except Exception as e:
                    py_logger.error("Exception(%s) in Lua: %s", type(e).__name__, e)
        pass

def run_world(lua):
    py_logger.info("world start")
    FireEvent = lua.globals().FireEvent
    try:
      FireEvent("LOADING_END")
    except Exception as e:
      py_logger.error("Exception(%s) in lua: %s", type(e).__name__, e)

if __name__ == "__main__":
    lua = lupa.LuaRuntime()
    root_dir = "../JX3Clouds/"

    fake(lua, "print", make_print_from_logger(lua_logger), force=True)
    fake(lua, "__log", make_print_from_logger(fake_logger), force=True)
    make_stubs(lua, "stubs.lua")
    lua.execute("print('hello', 'world!')")
    ts, cs = load_package_ini(lua, root_dir)
    load_lua_file(lua, root_dir, ts, cs)
    run_world(lua)
    make_shell(lua)
