/**
* Name: Network
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Network

import 'Main.gaml'

global {
	int port <- 5000;
	string url <- "localhost";
	int a <- 0;
	int current_num<-10000;
	}

species NetworkAgent skills:[network]{
	
	string road_info;
	
	init{
		do connect to:url protocol:"http" port:port raw:true;
	}
	
	
	//クリックされた道路の属性情報を取得
	reflex when:every(10 #second) and (a=0){
		do send to:"/get_clicked_road" contents:["GET"];
		a <- 0;
	}
	
	//GAMAからPythonへのデータ送信成功コード
//	reflex when:every(10 #second) and (a=0){
//こっちはうまくいかなかった//do send to:"/test" contents:["POST",["test"::"hello"],["Content-Type"::"application/json"]];
//		do send to:"/test" contents:["POST",'hello'];
//		a <- 0;
//	}
	
//	reflex get_message when:every(10 #second){
//		loop while: has_more_message(){
//			message mess <- fetch_message();
//			write mess;
//			map content <- mess.contents['BODY'];
//			write 'test:'+content;
//			//map(['fid'::2432,'fukuin'::458,'length'::48.5,'linkno'::2918,'maxspeed'::20,'maxspeed_2'::nil,'mlanesu'::0,'netlevel'::0,'oneway'::1,'planesu'::0,'road_id'::8])
//			
//			//取得したroad_idが現在のroad_idと違えば書き出す。
//			if current_num != int(content['road_id']){
//				write 'id:'+string(content['road_id']);
//				current_num <- int(content['road_id']);
//				ask road where (each.road_id = current_num){
//					myself.road_info <- string(car_num_manage);
//					write car_num_manage;
//				}
//				do send to:"/road_info_gama" contents:["POST",string(content['road_id'])+":"+string(road_info)];
//			}
//			
//		}
//	}

	reflex get_message when:every(10 #second){
		loop while: has_more_message() {
			message mess <- fetch_message();
			map body <- mess.contents['BODY'];
			if body['status'] = 'road_info'{
				int click_road_id <- int(body['road_info']['road_id']);
				//write click_road_id;
				if current_num != click_road_id{
					current_num <- click_road_id;
					ask road where (each.road_id = current_num){
						myself.road_info <- string(car_num_manage);
						ask NetworkAgent{
							do send to:"/road_info_gama" contents:["POST",string(current_num)+":"+string(road_info)];
						}
						write string(current_num)+string(car_num_manage);
					}
					//2つのリストの内下のリストしか送られない
					//do send to:"/road_info_gama" contents:["POST",string(current_num)+":"+string(road_info)];
				}
			}
			
		}
	}
}

//message[sender: HTTP; content: {CODE=200, HEADERS={connection=[close], content-length=[31], content-type=[application/json], date=[Thu, 21 Nov 2024 02:35:02 GMT], server=[Werkzeug/2.3.4 Python/3.11.3]}, BODY={status=success_gama}}]
//content:map(['status'::'success_gama'])
//message[sender: HTTP; content: {CODE=200, HEADERS={connection=[close], content-length=[205], content-type=[application/json], date=[Thu, 21 Nov 2024 02:35:02 GMT], server=[Werkzeug/2.3.4 Python/3.11.3]}, BODY={fid=40282, fukuin=null, length=114.5, linkno=40275, maxspeed=null, maxspeed_2=null, mlanesu=null, netlevel=0, oneway=0, planesu=null, road_id=218}}]
//content:map(['fid'::40282,'fukuin'::nil,'length'::114.5,'linkno'::40275,'maxspeed'::nil,'maxspeed_2'::nil,'mlanesu'::nil,'netlevel'::0,'oneway'::0,'planesu'::nil,'road_id'::218])
//id:218
//[0]
//[0]

//message[sender: HTTP; content: {CODE=200, HEADERS={connection=[close], content-length=[281], content-type=[application/json], date=[Thu, 21 Nov 2024 02:44:19 GMT], server=[Werkzeug/2.3.4 Python/3.11.3]}, BODY={clicked_road_info={fid=40282, fukuin=null, length=114.5, linkno=40275, maxspeed=null, maxspeed_2=null, mlanesu=null, netlevel=0, oneway=0, planesu=null, road_id=218}, status=road_info}}]
//test:map(['road_info'::map(['fid'::40282,'fukuin'::nil,'length'::114.5,'linkno'::40275,'maxspeed'::nil,'maxspeed_2'::nil,'mlanesu'::nil,'netlevel'::0,'oneway'::0,'planesu'::nil,'road_id'::218])
                    //,'status'::'road_info'])





