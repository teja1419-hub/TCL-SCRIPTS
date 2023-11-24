if { [sizeof_collection [get_drc_errors -filter {type_name == "Short"} -quiet -error_data pinmux_top_lvs.err]] > 0 } {

	set all_shorted_nets [filter_collection [get_attribute [get_drc_errors -filter {type_name == "Short"} -quiet -error_data pinmux_top_lvs.err] objects ] "net_type == signal" ]
	set num_short_nets [sizeof_collection $all_shorted_nets]
	echo "Number of shorts $num_short_nets\n"
	echo "note: all shorted nets are deleted except clock, power & ground nets and rerouted for DRC clean up \n"
	if { $num_short_nets > 0 } {
		remove_routes -net_types signal -detail_route -nets $all_shorted_nets
		
		check_lvs -max_errors 0 -open_reporting detailed

if { [sizeof_collection [get_drc_errors -filter {type_name == "Open"} -quiet -error_data pinmux_top_lvs.err]] > 0 } {

	set all_open_nets [filter_collection [get_attribute [get_drc_errors -filter {type_name == "Open"} -quiet -error_data pinmux_top_lvs.err] objects ] "net_type == signal" ]

	route_eco -nets [get_nets $all_open_nets]
	#incremental cleanup
	route_detail -initial_drc_from_input false -incremental true

}

	}
}

