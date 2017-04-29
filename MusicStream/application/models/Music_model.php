<?php defined('BASEPATH') OR exit('No direct script access allowed');
/**
* Name:  User_model Model
* 
* Author:  rijy
* Created:  2.20.2016 
* 
* Description:  manage users in database such as register, login, delete...
* 
*/

class Music_model extends CI_Model {

	public $table_name = "music_tbl";
	
	public function __construct()
	{
		parent::__construct();
		$this->load->database();
	}

	//login user request.
	public function save_music($userId, $title, $artist, $album, $thumb, $path, $duration)
	{	 
	    $title = str_replace('[', '', $title);
	    $title = str_replace(']', '', $title);
	    $artist = str_replace('[', '', $artist);
	    $artist = str_replace(']', '', $artist); 

	    if(empty($artist))
		$info = $title;
	    else
	        $info = $artist." - ".$title;

	    $data = array(
		    'user_id'   => $userId,
		    'title'   	=> $title,
		    'artist'    => $artist,
		    'album' 	=> $album,
		    'info'	=> $info,
		    'thumb' 	=> $thumb,
		    'duration'  => $duration,
		    'path' 	=> $path,
		    'created_on' => time()
		);
		if ($result = $this->db->insert($this->table_name, $data))
			return ERR_OK;
		else
			return ERR_DATABASE;		
	}

	public function list_music($userId) {
		$query = $this->db->query('SELECT a . * , vote_tbl.vote_value AS my_vote FROM (SELECT  `music_tbl`. * , SUM( vote_tbl.vote_value ) AS vote_value FROM  `music_tbl` LEFT JOIN  `vote_tbl` ON  `vote_tbl`.`music_id` =  `music_tbl`.`music_id` WHERE  `state` <2 GROUP BY  `music_tbl`.`music_id`)a LEFT JOIN vote_tbl ON ( vote_tbl.music_id = a.music_id AND vote_tbl.user_id ='.$userId.' )');
		$result = $query->result();		
		return $result;
	}

	public function get_music($now) {
		$this->db->like('title', $now);
		$this->db->where('state <', 2);	
		$result = $this->db->get($this->table_name)->row();
		return $result;
	}

	public function get_current_music() {
		$this->db->where('state', 1);	
		$result = $this->db->get($this->table_name)->row();
		return $result;
	}

	public function play_music($id) {
		$data = array('state' => 1);
	        $this->db->where('music_id', $id);
        	$this->db->update($this->table_name, $data);
	}

	public function remove_music($id) {
		$data = array('state' => 2);
	        $this->db->where('music_id', $id);
        	$this->db->update($this->table_name, $data);
	}

	public function remove_previous($id) {
		$data = array('state' => 2);
		$this->db->where('music_id <', $id);
	        $this->db->update($this->table_name, $data);
	}

	public function get_played_count($id) {
		$this->db->where('music_id <', $id);
		$this->db->from($this->table_name);
		$count = $this->db->count_all_results();
		return $count;
	}

	public function play_complete() {
		$data = array('state' => 2);
	        $this->db->update($this->table_name, $data);
	}

	public function get_next_music($id) {
		$this->db->where('music_id >=', $id);
		$this->db->where('state <=', 1);
		$result = $this->db->get($this->table_name)->result();
		return $result;
	}

	public function get_active_count() {
		$this->db->where('state <', 2);
		$this->db->from($this->table_name);
		$count = $this->db->count_all_results();
		return $count;	
	}

}
