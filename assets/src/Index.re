
[@bs.val] external players: array(Types.player) = "data.players";
let () = Js.log("match start " ++ string_of_int(Array.length(players)) ++ " players");
let tcount = Array.length(players) / 2;
Array.iteri((i, p) => p |. Types.teamSet(i/tcount));
ReactDOMRe.renderToElementWithId(<Target player=players[0]/>, "game");
