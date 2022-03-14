    join (
        select pitchermlbamid                                    as player_id
             , sum(num_pitches)                                  as num_pitches
