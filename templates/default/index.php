<?php

/**
 * CONFIG
 */
$usageFile = 'usage.html';

// Rediect packages
foreach (array('introduction', 'bootstrap', 'government') as $package) {
	if (strpos($_SERVER['REQUEST_URI'], '/' . $package) === 0) {
		$segment = ltrim($_SERVER['REQUEST_URI'], '/');
		$parts = explode('/', $segment);
		$host = array_shift($parts);
		$path = implode('/', $parts);
		$path = ltrim($path, '/');
		$location = sprintf('http://%s.typo3cms.demo.typo3.org/%s', $host, $path);
		header('Location: ' . $location);
		die();
	}
}

// well... quite rude ending!
$content = file_get_contents($usageFile);
print $content;
