# check-build.tcl

destroy .
if {[catch {::scidb::app::load eco [file join data eco.bin]} err]} {
	puts "FAILED"
}
puts "OK"

# vi:set ts=3 sw=3:
