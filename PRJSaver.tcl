# PRJSaver  Copyright (c) Nick Richards  ncr100@yahoo.com  Dec 2001 
# All Rights Reserved
#
# "It's so high tech it deserves a patent!" -Anonymous
# "w00t!" -Anonymous
#
# Meant to back up Hash AnimationMaster project files.
# Could be retrofitted to back up any file as it gets saved over time.
# Checks every 15 seconds for changes (see "waitTime" variable below).

# TODO
# 

#############################
# Intro crap / Configuration
#############################
set version 0.1
set waitTime 15000 ;# sec * 1000
set fileCtr 0
set extension .prj
set target Project1$extension

package require Tk ;# make sure Tk is available

#wm withdraw . ;# hide the primary window

set top . ;#[toplevel .top] ;# setup the subordinate window
wm title $top "PRJSaver v$version" ;# title it
bind $top <Destroy> exit ;# make it capable of shutting down the app if it's closed



# C:/Documents and Settings/Administrator/My Documents/my projects/hash
#cd "C:/Documents and Settings/Administrator/My Documents/my projects/hash"
#tk_messageBox -message "[pwd]"


proc about {} { 
    global version
    tk_messageBox -title About -message "PRJSaver $version  Copyright (c) Nick Richards  Dec 2001
ncr100@yahoo.com   All Rights Reserved

1. Click \"Browse...\" and pick your project, or enter its filename directly.
2. Turn the backup ON by clicking the big button at the bottom.
3. Enjoy worryfree Hashing." 
}


#######
# Menu
#######

set m [menu $top.m -relief sunken -bd 22]
$m add cascade -label File -menu [menu $m.file -tearoff 0] 
$m.file add command -label Exit -command {exit}
$m add cascade -label Help -menu [menu $m.help -tearoff 0] 
$m.help add command -label About -command {about}
$top conf -menu $m
   
set topWindow $top
set top [frame $top.frame -relief sunken -bd 1]
pack $top



##############################
# Instructions / Project Name
##############################

set instrFrame [frame $top.instrf]
set instructions [label $instrFrame.ins -text "Project filename you wish backed up:"]
set targetEntry [entry $instrFrame.entry -textvariable target -justify right]
set targetBrowse [button $instrFrame.browse -text Browse... -command {
    set target [tk_getOpenFile -initialdir $target -filetypes {{{AnimationMaster Project} *.prj}}] 
    $targetEntry xview end
}]
pack $instructions -side left
pack $targetBrowse -side right
pack $targetEntry -side right
pack $instrFrame -fill x




##########
# Counter
##########

set counterFrame [frame $top.ctrf]
set counterLabel [label $counterFrame.label -text "Current backup count: " -justify left]
pack $counterLabel -side left
set counter [label $counterFrame.ctr -textvariable fileCtr]
pack $counter -side right
pack $counterFrame -fill x


################
# On Off button
################

set mtime_base 0

set onoff 0
set ontext "Backup ON.  Click to turn off."
set offtext "Backup OFF.  Click to turn on."
set onoffButton [button $top.b -borderwidth 4 -text $offtext -command {
    set onoff [expr [incr onoff] % 2]
    if {$onoff == 0} { 
	$onoffButton conf -text $offtext
	set mtime_base 0
    } else {
	$onoffButton conf -text $ontext
    }
}]

pack $onoffButton


#######
# Guts
#######

set timer 0
set stop 0

tkwait visibility $onoffButton

wm resiz $topWindow 0 0 ;# Keep the user from resizing the window
wm deiconify .
#after 1000 {raise $topWindow} ;# bring the window to the top
#focus $targetEntry 

while {$stop != 1} {
    catch {
	after $waitTime {incr timer}
	tkwait variable timer
	
	if {$onoff == 1} { ;# the user has depressed the on/off button
	    puts Checking...

	    set mtime_new [file mtime $target] 

	    if {$mtime_base != $mtime_new} { 
		puts Copying...

		# Rip apart target into basename + extension
		set targetEnd [expr [string last $extension $target] - 1]
		set targetBase [string range $target 0 $targetEnd]

		set a ""
		
		append a $targetBase _ $fileCtr $extension

		file copy -force $target $a

		incr fileCtr ;# updates the displayed file counter
	    }
	    set mtime_base $mtime_new
	} else {
	    puts "Turned off..."
	}
    }
}
exit

