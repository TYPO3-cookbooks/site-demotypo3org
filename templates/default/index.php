<?php

/**
 * CONFIG
 */
$usageFile = 'usage.html';

// Redirect packages
foreach (array('introduction', 'bootstrap', 'government') as $package) {
    if ($_SERVER['REQUEST_URI'] == '/' . $package) {
        header('Location: http://' . $package . '.typo3cms.demo.typo3.org/');
        die();
    }
}

if ($_SERVER['REQUEST_URI'] == '/') {
	// well... quite rude ending!
	$content = file_get_contents($usageFile);
	print $content;
	die();
}

