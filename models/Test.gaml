/**
* Name: Test
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Test

import 'Main.gaml'

species test_agent {
	
	intersection test1;
	
	reflex when:cycle = 100 {
		test1 <- one_of(intersection where (each.node_id=176));
		ask test1 {
			is_traffic_signal <- false;
	
		}
	}
}

