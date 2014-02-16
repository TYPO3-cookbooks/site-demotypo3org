<?php

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

// Display landing page in a very inelegant way.
// well... quite rude ending!
$content = file_get_contents('http://typo3.org/?id=605');
$content = str_replace(array('src="/','href="/', 'url(/'), array('src="http://typo3.org/', '
href="http://typo3.org/', 'url(http://typo3.org/'), $content);
$content = preg_replace('@src="/(?!/)@', 'src="//typo3.org/', $content);
$content = preg_replace('@href="/(?!/)@', 'href="//typo3.org/', $content);
$content = preg_replace('@url\(/(?!/)@', 'url("//typo3.org/', $content);
print $content;
die();
