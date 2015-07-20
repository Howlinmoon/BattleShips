if (-f "update_db")
	{
        print "trying to call update_db sub\n";
        &update_db;
        }
        sub update_db
        {
        print "in update db sub\n";
	print LOG "Requested to Save db at: $rmon/$rmday/$ryear $rhour:$rmin:$rsec\n";
	$command = "";
        $command = "delete from how_many_ships";
        $sth = $dbh->query($command);
        die "error with command $command" unless (defined $sth);

        $command = "replace into how_many_ships (how_many) values ($number_test_ships) ";
        $sth = $dbh->query($command);
	die "error with command $command" unless (defined $sth);

        $command = "delete from master_ship_chart";
        $sth = $dbh->query($command);
        die "error with command $command" unless (defined $sth);

    	$command = "delete from how_many_waypoints";
        $sth = $dbh->query($command);
        die "error with command $command" unless (defined $sth);

        $command = "delete from waypoint_master";
        $sth = $dbh->query($command);
        die "error with command $command" unless (defined $sth);
	$waypoint_id = 0;

	$command = "delete from taskforce_master";
        $sth = $dbh->query($command);
        die "error with command $command" unless (defined $sth);

	$command = "delete from how_many_taskforces";
        $sth = $dbh->query($command);
        die "error with command $command" unless (defined $sth);

	for ($current_ship = 1; $current_ship <= $number_test_ships; $current_ship++)
	    {
		$command = "";
		$command = "replace into master_ship_chart (ship_id, ship_name, ship_owner, ship_country, ship_heading, ship_x, ship_y, ship_speed, ship_max_speed, ship_sighting_range, ship_sight_factor, hull_class, depth, task_force, ship_class, crew_skill) values ($ship_id[$current_ship],\"$ship_name[$current_ship]\",\"$ship_owner[$current_ship]\",\"$ship_country[$current_ship]\",$ship_course[$current_ship],$ship_x[$current_ship],$ship_y[$current_ship],$ship_speed[$current_ship],$max_speed[$current_ship],$ship_sighting_range[$current_ship],$ship_sight_factor[$current_ship], \"$hull_class[$current_ship]\",$depth[$current_ship], $task_force_id[$current_ship],\"$ship_class[$current_ship]\",$crew_skill[$current_ship])";
		$sth = $dbh->query($command);
		die "error with command $command" unless (defined $sth);

                $command = "";
                $command = "replace into targets (ship_id, target) values ($current_ship,\"$target[$current_ship]\")";
                $sth = $dbh->query($command);
                die "error with command $command" unless (defined $sth);

		$command = "";
		$command = "replace into how_many_waypoints (ship_id, waypoints) values ($current_ship, $number_waypoints[$current_ship])";
		$sth = $dbh->query($command);
		die "error with command $command" unless (defined $sth);
#		print "number of waypoints for ship $current_ship is $number_waypoints[$current_ship]\n";
		if ($number_waypoints[$current_ship] > 0 )
                   {
                   for ($xx = 1; $xx <= $number_waypoints[$current_ship]; $xx++)
		       {
		       $waypoint_id++;
		       $command = "";
		       $command = "insert into waypoint_master (waypoint_id, ship, waypoint_num, waypoint, speed, depth) values ($waypoint_id, $current_ship, $xx, \"$waypoint[$current_ship][$xx]\",0,0)";
#		       print "Command to save waypoints is $command\n";
                       $sth = $dbh->query($command);
                       die "error with command $command" unless (defined $sth);
		       }
                   }
            }
# Save Taskforce Information
	$command = "replace into how_many_taskforces (how_many) values ($number_taskforces)";
        $sth = $dbh->query($command);
        die "error with command $command" unless (defined $sth);
	if ($number_taskforces > 0)
           {
           for ($xx = 1; $xx <= $number_taskforces; $xx++)
               {
               $command = "insert into taskforce_master (tf_id,tf_name,tf_country, tf_type, num_waypoints, tf_speed, tf_course, tf_depth) values ($xx,\"$task_force[$xx]\",\"$task_force_country[$xx]\", \"$task_force_type[$xx]\",$task_force_waypoints[$xx],$task_force_speed[$xx],\"$task_force_course[$xx]\",$task_force_depth[$xx])";
#               print "command to save tf's is $command\n";
                       $sth = $dbh->query($command);
                       die "error with command $command" unless (defined $sth);
               }
           }
	unlink "./update_db";
	}
1;
