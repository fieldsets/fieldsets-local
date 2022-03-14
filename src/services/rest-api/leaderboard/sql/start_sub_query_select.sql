    left outer join (
        select pitchermlbamid                                    as player_id
             , sum(sum)                                          as num_starts
        from pl_leaderboard_starts
