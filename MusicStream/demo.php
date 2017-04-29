<?php 

		///testing start
		$deviceToken = 'C106AD4F84052D6AF2C5B7F294DFBC2FC4B992B5115B1C3838F69E03CA804563';
		$message = "this is the first notification";
		$payload = '{
						"aps" : 
						{"alert" : "'.$message.'",
						 "badge" : 1,
						 "sound" : "default"
						}
					}';
		$ctx = stream_context_create();
		stream_context_set_option($ctx, 'ssl', 'local_cert', 'ck.pem');
		stream_context_set_option($ctx, 'ssl', 'passphrase', '1111');
		$fp = stream_socket_client('ssl://gateway.sandbox.push.apple.com:2195', $err, $errstr, 60, STREAM_CLIENT_CONNECT, $ctx);
		if(!$fp){
			print "Failed to connec $err $errstr";
			return;
		} else {
			print "Notification sent!";
		}
		$devArray = array();
		$devArray[] = $deviceToken;

		foreach ($devArray as $deviceToken) {
			// $msg = chr(0) . pack("n", 32) . pack("H*", str_replace(" ", "", $deviceToken)) . pack("n", strlen($payload)) . $payload;
			$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;
			print "sending message: " . $payload . $deviceToken;
			fwrite($fp, $msg);
			
		}
		fclose($fp);

?>