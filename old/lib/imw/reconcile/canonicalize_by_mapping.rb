#
#
#

#
# Take a raw object with non-standard naming -- perhaps a human-edited list --
# and map its elements to a standard & normalized form.
#
# For instance, you may wish to map country_names such as
#   "United States of America", "United States", "USA", "U.S.A.",  "U.S.A"
# or
#   "Burkina Faso", "Burkina-Faso", "Upper Volta"
# onto their respective ISO 2-letter country codes.
#
# A canonicalizer can simply map element to canonical (using a hash) -- this is
# fast or additionally map regexp matches to canonical forms (scanning an
# associative array) -- this is slower.
#


#
# For regexp: can optimize with initial match of 'all left-hand-sides concatenated' -- so, for
#   [:country => /^United States of America$/, :cc => 'us'],
#   [:country => /^U\.?S\.?A\.?$/,             :cc => 'us'],
#   [:country => /^U\.?S\.?$/,                 :cc => 'us'],
#   [:country => /^U\.?K\.?$/,                 :cc => 'us'],
# first check /^(?:United States of America|U\.?S\.?A\.?|U\.?S\.?|U\.?K\.?)$/
#
# This could be much faster or much slower.
#
