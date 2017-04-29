<?php
// Codeigniter access check, remove it for direct use
if( !defined( 'BASEPATH' ) ) exit( 'No direct script access allowed' );

/**
 * my configuration class
 *
 *
 * @author      rijy
 * 
 */
class My_conf extends CI_Driver_Library {

	var $fileName = "logfile.txt";

	public function __construct( $config = array() ) {
    }

    //rename
    public function rename( $data = array(), $names = array() )
    {
    	$newarray = array();
    	foreach( $data as $key=>$value )
		{
			if(array_key_exists($key, $names)){
				// if($key == "_id")
				// 	$newarray[$names[$key]] = (string)$value;
				// else
				// 	$newarray[$names[$key]] = $value;
				$newarray[$names[$key]] = (string)$value;
			} else{
				$newarray[$key] = $value;
			}
		 	
		}
		return $newarray;
    }

    //sort array
    function sort($data = array(), $orderby = "", $option = SORT_DESC){

    	if(count($data) == 0)
    		return $data;

		$sortArray = array(); 

		foreach($data as $item){ 
		    foreach($item as $key=>$value){ 
		        if(!isset($sortArray[$key])){ 
		            $sortArray[$key] = array(); 
		        } 
		        $sortArray[$key][] = $value; 
		    } 
		} 
		array_multisort($sortArray[$orderby], $option, $data); 

		return $data;
	}

	//get MongoDate from string(es: "2016 年 03 月 17 23:2:47")
	function convertStringToMongoDate($date_str = "")
	{
		if($date_str == "")
			return "";
    	$date = DateTime::createFromFormat('Y 年 m 月 d', $date_str);
    	$date_result = new MongoDate(strtotime($date->format('Y-m-d H:i:s')));
    	return $date_result;
	}

	function writeLog($content = "") {
		$time = date('Y-m-d H:i:s');
		$data = $time. "  ".$content."\n";
		file_put_contents($this->$fileName, $data, FILE_APPEND);
	}
}