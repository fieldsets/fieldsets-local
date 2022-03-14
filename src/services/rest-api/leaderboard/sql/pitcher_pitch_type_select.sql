select pitchermlbamid                                            as player_id
     , pitchername                                               as player_name
     , pitcherteam                                               as player_team
     , pitcherteam_abb                                           as player_team_abb
     , pitchtype                                                 as pitchtype
     , coalesce(start.num_starts, 0)                             as num_starts
