local _t
_t = {
  NAME = "enum",

  FORCE_TYPE = {
    JIANG_HU  = 0 , -- 江湖
    SHAO_LIN  = 1 , -- 少林
    WAN_HUA   = 2 , -- 万花
    TIAN_CE   = 3 , -- 天策
    CHUN_YANG = 4 , -- 纯阳
    QI_XIU    = 5 , -- 七秀
    WU_DU     = 6 , -- 五毒
    TANG_MEN  = 7 , -- 唐门
    CANG_JIAN = 8 , -- 藏剑
    GAI_BANG  = 9 , -- 丐帮
    MING_JIAO = 10, -- 明教
    CANG_YUN  = 21, -- 苍云
    CHANG_GE  = 22, -- 长歌
    BA_DAO    = 23, -- 霸刀
  }, -- me.dwForceID

  KUNGFU_TYPE = {
    TIAN_CE     = 1,      -- 天策内功
    WAN_HUA     = 2,      -- 万花内功
    CHUN_YANG   = 3,      -- 纯阳内功
    QI_XIU      = 4,      -- 七秀内功
    SHAO_LIN    = 5,      -- 少林内功
    CANG_JIAN   = 6,      -- 藏剑内功
    GAI_BANG    = 7,      -- 丐帮内功
    MING_JIAO   = 8,      -- 明教内功
    WU_DU       = 9,      -- 五毒内功
    TANG_MEN    = 10,     -- 唐门内功
    CANG_YUN    = 18,     -- 苍云内功
    CHANG_GE    = 19,     -- 长歌内功
    BA_DAO      = 20,     -- 霸刀内功
  }, -- me.GetSchoolList()

  PLAYER_TALK_CHANNEL = {
    INVALID = 0,
    NEARBY = 1,
    TEAM = 2,
    RAID = 3,
    BATTLE_FIELD = 4,
    SENCE = 5,
    WHISPER = 6,
    FACE = 7,
    GM_MESSAGE = 8,
    LOCAL_SYS = 9,
    GLOBAL_SYS = 10,
    GM_ANNOUNCE = 11,
    TO_TONG_GM_ANNOUNCE = 12,
    TO_PLAYER_GM_ANNOUNCE = 13,
    NPC_NEARBY = 14,
    NPC_PARTY = 15,
    NPC_SENCE = 16,
    NPC_WHISPER = 17,
    NPC_SAY_TO = 18,
    NPC_YELL_TO = 19,
    NPC_FACE = 20, -- emoji?
    NPC_SAY_TO_ID = 21,
    NPC_SAY_TO_CAMP = 22,
    TONG = 23,
    TONG_ALLIANCE = 24,
    --TongAlliance = 24,
    TONG_SYS = 25,
    WORLD = 26,
    FORCE = 27,
    CAMP = 28,
    MENTOR = 29,
    FRIENDS = 30,
    DEBUG_THREAT = 31,
    IDENTITY = 34,
    --CHANNEL1
    --CHANNEL2
    --CHANNEL3
    --CHANNEL4
    --CHANNEL5
    --CHANNEL6
    --CHANNEL7
    --CHANNEL8
    --DEBUG_THREAT
  },

  as = function(n, t)
    if type(t) == "string" then
      t = _t[t]
    end
    for i, v in pairs(t) do
      if v == n then
        return i
      end
    end
  end,
}

_t.module = Clouds.Base
Clouds.Base.enum = _t
Clouds.Base.base.gen_all_msg(_t)
