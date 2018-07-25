
type action =
  | Cast(int, string, int);

type state = {
  role_id: int,
  global_role_id: string,
  name: string,
  team: int,
  team_name: string,
};

let component = ReasonReact.reducerComponent("Target");

let fromPlayer = (player) => {
  role_id: player|.Types.role_id,
  global_role_id: player|.Types.global_role_id,
  name: player|.Types.role_name,
  team: player|.Types.team,
  team_name: player|.Types.team_name,
};

let make = (~player, _children) => {
  ...component,
  initialState: () => fromPlayer(player),
  reducer: (_: action, _: state) => NoUpdate,
  render: ({state: {name}}) => <div>{ReasonReact.string(name)}</div>
};
