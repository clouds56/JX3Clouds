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

_t.module = Clouds_Base
Clouds_Base.enum = _t
_t.Output = _t.module.base.gen_msg(_t.NAME)
