<?php defined('BASEPATH') OR exit('No direct script access allowed');
/**
* Name:  Vote_model Model
* 
* Author:  jinsi
* Created:  2.20.2016 
* 
* Description:  manage users in database such as register, login, delete...
* 
*/

class Vote_model extends CI_Model {

	public $table_name = "vote_tbl";
	
	public function __construct()
	{
		parent::__construct();
		$this->load->database();
	}

	//login user request.
	public function save_vote($userId, $musicId, $voteValue)
	{	 
	   	$data = array(
		    'user_id'   => $userId,
		    'music_id'   => $musicId,
		    'vote_value'   => $voteValue
		);
		if ($result = $this->db->insert($this->table_name, $data))
			return ERR_OK;
		else
			return ERR_DATABASE;		
	}

	public function list_vote($userId) {
		$query = $this->db->where('vote_tbl.user_id', $userId)
				->where('vote_value >', 0)
				->join('music_tbl','vote_tbl.music_id = music_tbl.music_id','left')
				->get($this->table_name);
		$result = $query->result();		
		return $result;
	}

	public function get_music_vote($musicId) {
		$this->db->select('sum(vote_value) as vote_value');
		$this->db->where('music_id', $musicId);
		$query = $this->db->get($this->table_name);
		$result = $query->result();
		return $result;
	}
}
