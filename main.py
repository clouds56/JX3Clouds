#!/bin/env python

import os
import itertools
import logging
import lupa
import codecs
from pprint import pformat
from configparser import ConfigParser
from toposort import toposort_flatten

logger_level = logging.DEBUG
logger_formatter = "[%(asctime)s][%(name)s] %(levelname)s::%(message)s"
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
        fake(lua, n, stubs[n].item)

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

if __name__ == "__main__":
    lua = lupa.LuaRuntime()
    root_dir = "../JX3Clouds/"

    fake(lua, "print", lua_logger.info, force=True)
    make_stubs(lua, "stubs.lua")
    lua.execute("print('hello world!')")
    ts, cs = load_package_ini(lua, root_dir)
    load_lua_file(lua, root_dir, ts, cs)
