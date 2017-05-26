<?php

// Mao: Hi, you should modify two fields below :)
// 1. The Url of the restful api, at line 17
// 2. Your username:password, at line 21

// We will use /api/2/issue, that is a restful api supplied by JIRA.
// You can install "Atlassian REST API Browser" plugin to browse details of all Rest API
// It is free :)


$taskData = file_get_contents("php://input");


$ch = curl_init();
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_URL, "http://{website, on which your JIRA platform are hosted}/rest/api/2/issue");
curl_setopt($ch, CURLOPT_POSTFIELDS, $taskData);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_HTTPHEADER, array(
		'Authorization: Basic {here, put your username:password, which must be encoded by Base64 first}',
        'Content-Type: application/json; charset=utf-8',
        'Content-Length: ' . strlen($taskData)
    )
);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);


echo $response;

?>