/**
* Name: Parameters
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/



model Parameters

import 'Main.gaml'

global {
	float step <- 1.0#s;
	int residence_num<-500;
	int normalcar_num<-50;
	bool test_agent_on <- false;
	bool ave_speed_map <- false;
	bool jam_map <- false;
	
	date starting_date <- date("2024 10 01 13 00 00", "yyyy MM dd HH mm ss");
	
	file a_road <- file("../includes/complete_roads.shp");
	file a_node <- file("../includes/complete_node.shp");
	file a_building <- file("../includes/complete_building.shp");
	
	file shape_file_road <- a_road;
	file shape_file_node <- a_node;
	file shape_file_building <- a_building;
	
	geometry shape <- envelope(shape_file_road);

	
	graph road_network;
	
	intersection no5;
	intersection no12;
	
	intersection no36;
	intersection no37;
}

