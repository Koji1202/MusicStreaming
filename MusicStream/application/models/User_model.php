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

class User_model extends CI_Model {

	public $table_name = "user_tbl";
	
	public function __construct()
	{
		parent::__construct();
		$this->load->database();
	}

	//login user request.
	public function login($email, $password, $facebookId)
	{	 
	    if ($password != '')
	    	$result = $this->db->get_where($this->table_name, array('email' => $email, 'password' => $password))->row();
	    else
	    	$result = $this->db->get_where($this->table_name, array('email' => $email, 'facebook_id' => $facebookId))->row();
	    
	    return $result;	    	
	}

	public function register($username, $email, $password, $facebookId, $active) {
		if ($email == '')
			return ERR_INPUT;
		$data = array(
		    'name'   => $username,
		    'password'   => $password,
		    'email'      => $email,
		    'facebook_id'=> $facebookId,
		    'created_on' => time(),
		    'last_login' => time(),
		    'active'     => $active
		);
		if ($result = $this->db->insert($this->table_name, $data))
			return ERR_OK;
		else
			return ERR_DATABASE;		
	}

}
