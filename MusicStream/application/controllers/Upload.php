<?php

class Upload extends CI_Controller {

    var $config;
    public function __construct() {
        
        parent::__construct();
        $this->load->helper('url');   

        $this->config =  array(
                  'upload_path'     => dirname($_SERVER["SCRIPT_FILENAME"])."/upload/",
                  'upload_url'      => FCPATH."upload/",
                  'allowed_types'   => "*",
                  'overwrite'       => TRUE,
                  'max_size'        => "100000KB",
                  'max_height'      => "3000",
                  'max_width'       => "3000",
		  'remove_spaces'   => FALSE
                );
    }

	function index()
	{
		//$this->load->view('upload_form'，array('error' => ' ' ));
	}

    public function file_upload()
    {
        $session_id = $_POST['session_id'];
        $user_id = $_POST['user_id'];

        //session check
        // if( $this->session->userdata("session_id") != $session_id ){
        //  $result = array('upload_result' => 0);
        // }else{
            $x = explode('.', $_FILES['upfile']['name']);
            $ext = '';
            if (count($x) != 1)
            {
                $ext = strtolower(end($x));
            }
            $filename = md5(uniqid(mt_rand())).$ext;
            $this->config['file_name'] = $_FILES['upfile']['name'];

            $this->load->library('upload', $this->config);
            if($this->upload->do_upload('upfile'))
            {
                $this->data["uploaded_file"] = $this->upload->data();
                $data = $this->upload->data();
		if ($ext != 'mp3') {
			$x = explode('.', $data['file_name']);
			$len = count($x);
			if ($len != 1) {
				$x[$len - 1] = "mp3";
            		} else {
				$x[$len] = "mp3";
			}
			$filename = implode('.', $x);
			$original = '"'.FCPATH.'upload/'.$data['file_name'].'"';
			$newpath = '"'.FCPATH.'upload/'.$filename.'"';
			$cmd = 'ffmpeg -i '.$original.' -vn -ar 44100 -ac 2 -f mp3 '.$newpath;
			//$this->execInBackground($cmd);
			exec($cmd);
			$response = array("result_code" => ERR_OK, "result_data" => array('file_path' => 'upload/'.$filename));			
		} else {
			$response = array("result_code" => ERR_OK, "result_data" => array('file_path' => 'upload/'.$data['file_name']));
		}                
            }
            else
            {
                $response = array("result_code" => ERR_UNKOWN);
            }            
        
        $this->output->set_content_type('application/json')->set_output(json_encode($response));
    }
    
    
    function remove_dir($dir, $DeleteMe) {
        if(!$dh = @opendir($dir)) return;
        while (false !== ($obj = readdir($dh))) {
            if($obj=='.' || $obj=='..') continue;
            if (!@unlink($dir.'/'.$obj)) $this->remove_dir($dir.'/'.$obj, true);
        }
 
        closedir($dh);
        if ($DeleteMe){
            @rmdir($dir);
        }
    
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
?>
