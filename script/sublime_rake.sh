#!/bin/sh

#
#  Define a build-definition for Sublime Text 2 in
#  ~/Library/Application Support/Sublime Text 2/Packages/User/rspec.sublime-build
#  with the following definition
#  {  
#    "cmd": ["script/sublime_rake.sh"],
#    "working_dir": "${project_path:${folder}}",
#    "selector": "source.ruby"
#  }
#
#  Then make sure you have a sublime-project-file in your app's root-path
#  Now check "rake" as your build-system in Sublime and press Cmd+B whenever
#  you wanna run your specs and show the output in your browser
#
#  
rspec --drb -f h --color -o tmp/rspec.html spec 
open tmp/rspec.html
