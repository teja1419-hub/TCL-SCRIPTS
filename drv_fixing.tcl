###Before sourcing this tcl, 
#change the report generation path
#check the lib cells are available
#check the number of flat loads and net length

report_constraints -all_violators -verbose -scenarios {func_slow func_fast} > rpts_fc/route_opt/report_constraint

set nets [sh cat rpts_fc/route_opt/report_constraint | grep Net | awk '{print \$2}']

foreach net $nets {
    if {[get_attribute [get_nets $net] dr_length] > 10} {
        add_buffer_on_route -cell_prefix eco_cap_cell_fix -net_prefix eco_cap_net_fix -respect_blockages [get_nets $net] -lib_cell saed14rvt_tt0p8v25c/SAEDRVT14_BUF_ECO_4 -repeater_distance_length_ratio 0.4
    } else {
        set num_flat_loads [get_attribute [get_nets $net] number_of_flat_loads]
        if {$num_flat_loads >= 5} {
            split_fanout -net_prefix eco_cap_net_fix -cell_prefix eco_cap_cell_fix -net $net -lib_cell saed14rvt_tt0p8v25c/SAEDRVT14_BUF_ECO_4 -max_fanout 5 -on_route
        }
    }
}

legalize_placement -incr
			
