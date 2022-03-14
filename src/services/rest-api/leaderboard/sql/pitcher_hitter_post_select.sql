     , round(100 * (sum(num_fastball) / nullif(sum(base.num_pitches), 0)), 1) as fastball_pct
     , round(100 * (sum(num_early_secondary) / nullif(sum(num_early), 0)), 1) as early_secondary_pct
     , round(100 * (sum(num_late_secondary) / nullif(sum(num_late), 0)), 1) as late_secondary_pct
