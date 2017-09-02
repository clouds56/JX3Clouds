local _t
_t = {
  NAME = "view",

  Analyze = function(data, id, filter)
    -- skills[id] = { [skill] = (dict){times, id, skill, damage, health}, ... }
    local skills = {}
    for i, v in pairs(data) do
      if v.dst.id == id and (not filter or filter(v)) then
        local source, skill = v.src.name or "#"..v.src.id, v.skill
        local t = skills[source]
        if not t then
          t = { id=source, damage=0, health=0 }
          skills[source] = t
          table.insert(skills, t)
        end
        t.damage = t.damage + v.damage
        t.health = t.health + v.health
        t.all = t.damage + t.health
        local item = skills[source][skill]
        if not skills[source][skill] then
          local t = { times=0, id=source, skill=skill, damage=0, health=0 }
          skills[source][skill] = t
          table.insert(skills[source], t)
        end
        local item = skills[source][skill]
        item.times = item.times + 1
        item.damage = item.damage + v.damage
        item.health = item.health + v.health
        item.all = item.damage + item.health
      end
    end
    return skills
  end,
  AnalyzeItemToString = function(self)
    local damage = self.damage ~= 0 and string.format(" %d damage", self.damage) or ""
    local health = self.health ~= 0 and string.format(" %d health", self.health) or ""
    return string.format("[%s] attack %d times done%s%s.", damage, health)
  end,
}

_t.module = Clouds.Flags
Clouds.Flags.view = _t
