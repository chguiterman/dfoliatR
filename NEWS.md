# dfoliatR v0.0.39999
* Add data from Demi John; change built-in data naming scheme to help differentiate host series from nonhosr chronologies
* Added provision to prevent defoliation events two years following one, unless bridge_events is set to true.
* Reduced event levels for more meaningful interpretation
* Added Gantt plot to plotting options. This required adding several new helper functions, including the useful get_defol_events function

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
