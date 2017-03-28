local _t
_t = {
  NAME = "sql",
  CREATE_CATALOG = [[
    CREATE TABLE IF NOT EXISTS catalog (
      type VARCHAR(20) NOT NULL,
      name VARCHAR(100) PRIMARY KEY,
      create_time INTEGER,
      last_time INTEGER
    )]],
  CREATE_COMPAT = [[
    CREATE TABLE IF NOT EXISTS compat (
      compat_id VARCHAR(32) PRIMARY KEY,
      damage_table_id INTEGER,
      status_table_id INTEGER,
      player_table_id INTEGER,
      src_id INTEGER,
      date VARCHAR(20),
      timestamp INTEGER,
      startframe INTEGER,
      endframe INTEGER
    )]],
  CREATE_DAMAGE = [[
    CREATE TABLE IF NOT EXISTS damage_log_%s (
      src_id INTEGER,
      dest_id INTEGER,
      time INTEGER NOT NULL,
      compat_id VARCHAR(32) NOT NULL,
      type INTEGER,
      skill_name NVARCHAR(20),
      skill_id INTEGER,
      skill_level INTEGER,
      damage INTEGER,
      damage_effect INTEGER,
      data VARCHAR(400)
    )]],
  CREATE_STATUS = [[
    CREATE TABLE IF NOT EXISTS status_log_%s (
      src_id INTEGER NOT NULL,
      time INTEGER NOT NULL,
      compat_id VARCHAR(32) NOT NULL,
      pos_x REAL,
      pos_y REAL,
      pos_z REAL,
      life INTEGER,
      mana INTEGER,
      status INTEGER,
      buff_count INTEGER,
      mana_extra INTEGER
    )]],
  INSERT_COMPAT = [[INSERT INTO compat (compat_id, src_id, date, timestamp, startframe)
                    VALUES             (        ?,      ?,    ?,         ?,          ?)]],
  INSERT_DAMAGE = [[INSERT INTO %s (src_id, dest_id, time, compat_id, type, skill_name, skill_id, skill_level, damage, damage_effect, data)
                    VALUES         (     ?,       ?,    ?,         ?,    ?,          ?,        ?,           ?,      ?,             ?,    ?)]],
  INSERT_STATUS = [[INSERT INTO %s (src_id, time, compat_id, pos_x, pos_y, pos_z, life, mana, mana_extra, status, buff_count)
                    VALUES         (     ?,    ?,         ?,     ?,     ?,     ?,    ?,    ?,          ?,      ?,          ?)]],

  db = SQLite3_Open('interface/Clouds/Flags/_data/data.db'),

  init_compat = function(info)
    if not _t.db_compat then
      _t.db:Execute(_t.CREATE_COMPAT)
      _t.db_compat = _t.db:Prepare(_t.INSERT_COMPAT)
    end
    if not info.dbname then
      info.dbname = "20170300"
    end
    info.id = _t.db:Execute("SELECT lower(hex(randomblob(16))) AS compat_id")[1].compat_id
    Clouds_Base.xv.debug.out(info.id, info.dbname)
    info.db_bind = _t.init_dbs(info.dbname)
    return info
  end,
  init_dbs = function(name)
    _t.db:Execute(_t.CREATE_DAMAGE:format(name))
    _t.db:Execute(_t.CREATE_STATUS:format(name))

    return {
      damage = _t.db:Prepare(_t.INSERT_DAMAGE:format("damage_log_" .. name)),
      status = _t.db:Prepare(_t.INSERT_DAMAGE:format("status_log_" .. name)),
      -- TODO: player
    }
  end,
  begin_transaction = function(info)
    _t.db:Execute("BEGIN TRANSACTION")
    _t.execute(_t.db_compat, {info.id, info.me, info.dbname, info.date, info.time})
  end,
  end_transaction = function()
    _t.db:Execute("END TRANSACTION")
  end,
  -- TODO: release db
  insert_damage = function(bind_dmage, i)
    _t.execute(bind_dmage, i)
  end,
  execute = function(bind, i)
    bind:ClearBindings()
    bind:BindAll(unpack(i))
    bind:Execute()
  end
}

_t.module = Clouds_Flags
Clouds_Flags.sql = _t
_t.module.base.gen_all_msg(_t)
