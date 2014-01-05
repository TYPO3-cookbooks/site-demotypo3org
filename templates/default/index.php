<?php

/**
 * CONFIG
 */
$usageFile = 'usage.html';

// Rediect packages
foreach (array('introduction', 'bootstrap', 'government', 'neos') as $distribution) {
	if (strpos($_SERVER['REQUEST_URI'], '/' . $distribution) === 0) {
		$segment = ltrim($_SERVER['REQUEST_URI'], '/');
		$parts = explode('/', $segment);
		$host = array_shift($parts);
		$path = implode('/', $parts);
		$path = ltrim($path, '/');

		$location = sprintf('http://%s.typo3cms.demo.typo3.org/%s', $host, $path);
		if ($distribution == 'neos') {
		    $location = sprintf('http://%s.demo.typo3.org/%s', $host, $path);
		}
		header('Location: ' . $location);
		die();
	}
}

// well... quite rude ending!
$content = file_get_contents($usageFile);
print $content;
