        group by pitchermlbamid
    ) as start on start.player_id = base.pitchermlbamid
