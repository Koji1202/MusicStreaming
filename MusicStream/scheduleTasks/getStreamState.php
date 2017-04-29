<?php
while(true){
	// create a new cURL resource
	$ch = curl_init();
	// set URL and other appropriate options
	curl_setopt($ch, CURLOPT_URL, "http://localhost/MusicStream/index.php/music/remove_music");
	curl_setopt($ch, CURLOPT_HEADER, 0);
	curl_exec($ch);
	// close cURL resource, and free up system resources
	curl_close($ch);
	sleep(10);
}
?>