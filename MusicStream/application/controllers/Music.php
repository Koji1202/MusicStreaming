<?php defined('BASEPATH') OR exit('No direct script access allowed');
/**
* Name:  User Controller
* 
* Author:  rijy
* Created:  2.20.2016 
* 
* Description:  request and response from client.
* 
*/

class Music extends CI_Controller {
	
	function __construct()
	{
		parent::__construct();

		$this->load->model("Music_model");
		$this->music_model = new Music_model();		
		$this->load->model("Vote_model");
		$this->vote_model = new Vote_model();
		$this->ice_cast = new Icecast();
	}

	
	function upload_music()
	{
		$session_id = $_POST['session_id'];
		$userId = $_POST['user_id'];
		$title = $_POST['title'];
		$artist = $_POST['artist'];
		$album = $_POST['album'];
		$thumb = $_POST['thumb'];
		$path = $_POST['path'];
		$duration = $_POST['duration'];

		// $session_id = "123";
		// $userId = "19";
		// $title = "Take Me To Your Heart - Lyrics [Kara Vietsub - Engsub]";
		// $artist = "";
		// $album = "";
		// $thumb = "";
		// $path = "upload/Take_Me_To_Your_Heart_-_Lyrics_Kara_Vietsub_-_Engsub.mp3";
		// $duration = 5;
		$old = $this->music_model->get_music($title);
		if (is_null($old)) {
			$activeCount = $this->music_model->get_active_count();
			$result = $this->music_model->save_music($userId, $title, $artist, $album, $thumb, $path, $duration);
			if ($result == ERR_OK) {								
				if ($activeCount == 0)
					file_put_contents(PLAY_LIST, MUSIC_PATH.$path."\n");
				else
					file_put_contents(PLAY_LIST, MUSIC_PATH.$path."\n", FILE_APPEND);
				if ($activeCount == 0) {
					$this->execInBackground("/usr/local/bin/ices -c /etc/ices/ices.conf");
				}
				$response = array("result_code" => ERR_OK);
			} else {
				$response = array("result_code" => $result);
			}
		} else {
			$response = array("result_code" => ERR_DATABASE);
		}
		$this->output->set_content_type('application/json')->set_output(json_encode($response));	    
	}

	function list_music()
	{
		$session_id = $_POST['session_id'];
		$userId = $_POST['user_id'];
		// $session_id = "123";
		// $userId = "19";
		$result = $this->music_model->list_music($userId);
		$response = array("result_code" => ERR_OK, "result_data" => $result);		
		$this->output->set_content_type('application/json')->set_output(json_encode($response));	    
	}

	function remove_music()
	{
		$status = $this->ice_cast->getStatus();		
		print_r($status);
		if ($status['title'] == 'Offline') {
			if (!file_exists(PLAY_LIST)){
				$this->music_model->play_complete();				
			} else {
				//$playlist = file_get_contents(PLAY_LIST);
				//$playlist = str_replace("\n", "", $playlist);				
				//if (empty($playlist)) {					
					$this->music_model->play_complete();
					file_put_contents(PLAY_LIST, "");
				//} else {
					// $this->execInBackground("/usr/local/bin/ices -c /etc/ices/ices.conf");
				//}
			}			
			return;
		}
		$now = $status['now_playing'];
		file_put_contents("log.txt", "a", FILE_APPEND);
		$current = $this->music_model->get_music($now);
		if (!is_null($current)) {
			$this->music_model->play_music($current->music_id);
			$playedCount = $this->music_model->get_played_count($current->music_id);
			$this->music_model->remove_previous($current->music_id);				
			$list = $this->music_model->get_next_music($current->music_id);
			print_r($list);

			if (count($list) <= 1) {
				// no more music
				file_put_contents(PLAY_LIST, "");
				return;
			}
			//for ($i = 0; $i < count($list); $i++) {
			//	$row = $list[$i];
			//	file_put_contents(PLAY_LIST, MUSIC_PATH.$row->path."\n", FILE_APPEND);
			//}
		}
	}

	function save_vote() {
		$session_id = $_POST['session_id'];
		$userId = $_POST['user_id'];
		$musicId = $_POST['music_id'];
		$vote = $_POST['vote'];

		// $session_id = "123";
		// $userId = "19";
		// $musicId = "41";
		// $vote = -1;

		$result = $this->vote_model->save_vote($userId, $musicId, $vote);
		$response = array();
		if ($result == ERR_OK) {
			$response = array("result_code" => ERR_OK, "result_data" => array("refresh" => false, "restart" => false));
			if (intval($vote) < 0) {
 				// Dislike
				$voteValue = $this->vote_model->get_music_vote($musicId);
				if ($voteValue[0]->vote_value < 0) {
					$current = $this->music_model->get_current_music();
					$this->music_model->remove_music($musicId);
					file_put_contents(PLAY_LIST, "");
					if (!is_null($current)) {
						$list = $this->music_model->get_next_music($current->music_id);
						for ($i = 0; $i < count($list); $i++) {
							$row = $list[$i];
							file_put_contents(PLAY_LIST, MUSIC_PATH.$row->path."\n", FILE_APPEND);							
						}
						$this->restartServer();
						if ($current->music_id == $musicId) {
							$response = array("result_code" => ERR_OK, "result_data" => array("refresh" => true, "restart" => true));
						} else {
							$response = array("result_code" => ERR_OK, "result_data" => array("refresh" => true, "restart" => false));
						}
					}
				}				
			}
		} else {
			$response = array("result_code" => ERR_DATABASE);
		}
		$this->output->set_content_type('application/json')->set_output(json_encode($response));
	}

	function list_vote() {
		// $session_id = $_POST['session_id'];
		/// $userId = $_POST['user_id'];
		$session_id = "123";
		$userId = "19";

		$result = $this->vote_model->list_vote($userId);
		$response = array("result_code" => ERR_OK, "result_data" => $result);		
		$this->output->set_content_type('application/json')->set_output(json_encode($response));
	}

	function killServer() {
		$output = exec('/opt/lampp/htdocs/MusicStream/scheduleTasks/killServer.sh');
	}

	function restartServer() {
		$output = exec('/opt/lampp/htdocs/MusicStream/scheduleTasks/killServer.sh');
		$this->execInBackground("/usr/local/bin/ices -c /etc/ices/ices.conf");
	}

	function execInBackground($cmd) { 
    		if (substr(php_uname(), 0, 7) == "Windows"){ 
	        	pclose(popen("start /B ". $cmd, "r"));  
    		} 
    		else { 
      	  		exec($cmd . " > /dev/null &");   
    		} 
	}
}
