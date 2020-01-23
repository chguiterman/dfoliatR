# dfoliatR v0.0.39999
* Add data from Demi John; change built-in data naming scheme to help differentiate host series from nonhosr chronologies
* Added provision to prevent defoliation events two years following one, unless bridge_events is set to true.
* Reduced event levels for more meaningful interpretation
* Added Gantt plot to plotting options. This required adding several new helper functions, including the useful get_defol_events function
* Revised `defol_stats` to catch series with no defol events
* Gantt plot is now the default tree-level plotting option
* Added unit tests to defoliate and outbreak functions
* plotting is now stable to ggplot2 v3.2.0
* testing of plots via vdiffr
* Add "Maturing" as a lifecycle badge
* Add new constructor functions to (re)establish object classes for defol and outbreak. This is particularly useful when batch processing with {purrr} functions like `map`
* Changed the `outbreak` object code to `obr`. And updated several functions to account for the change.
* Bug fix in `get_defol_events()` to pass non-defoliated series through to final table.
* Spell check and code flow fixes
* Added MIT License
* Adding Zenodo DOI
* Ready for v.0.0.4


# dfoliatR v0.0.3
* Changed package name
* Add parameter to allow for events that are ongoing at the time of sampling, called series end events. This is for users who know, with certainty, that they sampling during an outbreak event. The paramter allows for events to be recorded regardless of duration, but only the recent end of the series.
* Add parameter to allow for bridging of two defoliation events on a single tree. This was done after observing instances where two successive events were separated by a single year, and in the case of western spruce budworm more likely represented a single, long event. The option should be used with caution and scrutinized closely.
* Update author list to reflect significant contributions to dfoliatR development by Ann Lynch and Jodi Axelson.
* Replaced the correct_host_series fucntion with gsi to better capture the process of calculating the growth suppression index.

# bugr v0.0.2
* This version in response to validation trials with real data
* Improve id_defoliation to prevent overlapping defol events
* Add both corrected and normalized index series to outputs of defoliate_trees and outbreak functions

# bugr v0.0.1

* Initial uploads of basic functions
* Includes detecting defoliation signals following protocols of Swetnam, Lynch, and Holmes studies and programs
* Adds basic tree and site level stats
* Adds basic plots for tree- and site-level objects
* Add some data for educational purpose
