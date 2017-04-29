<?php

class IceCast {
    var $server = STREAM_SERVER;
    var $stats_file = "/status.xsl";
    var $radio_info=array();

    function __construct() {
        //build array to store our radio stats for later use        
        $this->radio_info['server'] = $this->server;
        $this->radio_info['title'] = 'Offline';
        $this->radio_info['description'] = 'Radio offline';
        $this->radio_info['content_type'] = '';
        $this->radio_info['mount_start'] = '';
        $this->radio_info['bit_rate'] = '';
        $this->radio_info['listeners'] = '';
        $this->radio_info['most_listeners'] = '';
        $this->radio_info['genre'] = '';
        $this->radio_info['url'] = '';
        $this->radio_info['now_playing'] = array();
        $this->radio_info['now_playing']['artist'] = 'Unknown';
        $this->radio_info['now_playing']['track'] = 'Unknown';
    }

    function setUrl($url) {
        $this->server=$url;
        $this->radio_info['server'] = $this->server;
    }

    private function fetch() {
        //create a new curl resource
        $ch = curl_init();

        //set url
        curl_setopt($ch,CURLOPT_URL,$this->server.$this->stats_file);

        //return as a string
        curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);

        //$output = our stauts.xsl file
        $output = curl_exec($ch);

        //close curl resource to free up system resources
        curl_close($ch);

        return $output;
    }

    function getStatus() {
        $output=$this->fetch();

        //loop through $ouput and sort into our different arrays
        $temp_array = array();

        $search_for = "<td\s[^>]*class=\"streamdata\">(.*)<\/td>";
        $search_td = array('<td class="streamdata">','</td>');


        if(preg_match_all("/$search_for/siU",$output,$matches)) {
           foreach($matches[0] as $match) {
              $to_push = str_replace($search_td,'',$match);
              $to_push = trim($to_push);
              array_push($temp_array,$to_push);
           }
        }

        if(count($temp_array)) {
            //sort our temp array into our ral array
            $this->radio_info['title'] = $temp_array[0];
            $this->radio_info['description'] = $temp_array[1];
            $this->radio_info['content_type'] = $temp_array[2];
            $this->radio_info['mount_start'] = $temp_array[3];
            $this->radio_info['bit_rate'] = $temp_array[4];
            $this->radio_info['listeners'] = $temp_array[5];
            $this->radio_info['most_listeners'] = $temp_array[6];
            $this->radio_info['genre'] = $temp_array[7];
            $this->radio_info['url'] = $temp_array[8];
	    $this->radio_info['now_playing'] = $temp_array[9];
        }
        return $this->radio_info;
        }

}
?>
