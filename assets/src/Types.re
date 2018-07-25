[@bs.deriving abstract]
type player = {
  role_id: int,
  global_role_id: string,
  role_name: string,
  team: int,
  team_name: string,
  score: int,
};

let team_color = [|"blue", "red"|];
