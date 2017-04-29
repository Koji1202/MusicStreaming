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

class User extends CI_Controller {
	
	function __construct()
	{
		parent::__construct();

		$this->load->model("User_model");
		$this->user_model = new User_model();
		$this->load->library('session');
	}

	
	//login user request.
	function login()
	{
		$email = $_POST['email'];
		$password = $_POST['password'];
		$facebookId = $_POST['facebook_id'];


		if ($email == '' || ($password == '' && $facebookId == '')) {
			$response = array("result_code" => ERR_INPUT, "result_data" => array());
			$this->output->set_content_type('application/json')->set_output(json_encode($response));		
			return;
		}
		$result = $this->user_model->login($email, $password, $facebookId);
		if (is_null($result))
			$response = array("result_code" => ERR_DATABASE, "result_data" => array());
		else {
			// Session Set

			$session_id = session_id(); 
			$ip_address = $_SERVER['REMOTE_ADDR'];

			$session_var = array( "session_id" => $session_id, "ip_address" => $ip_address, "email" => $email);
			$this->session->set_userdata($session_var);

			$result->session_id = $session_id;
			$response = array("result_code" => ERR_OK, "result_data" => $result);
		}
		$this->output->set_content_type('application/json')->set_output(json_encode($response));	    
	}

	function register() {
		// parsing request
		$email = $_POST['email'];
		$password = $_POST['password'];
		$facebookId = $_POST['facebook_id'];

		$result = $this->user_model->register('', $email, $password, $facebookId, true);

		if($result != ERR_OK) {
			$response = array("result_code" => $result, "result_data" => array("register_result" => false));
		} else {
			$response = array("result_code" => $result, "result_data" => array("register_result" => true));
		}
		$this->output->set_content_type('application/json')->set_output(json_encode($response));		
	}
}