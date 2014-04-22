<?php
if (!defined ('TYPO3_MODE')) {
	die ('Access denied.');
}

// Hook protecting the website against defacing
$GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['t3lib/class.t3lib_tcemain.php']['processDatamapClass'][] = 'tx_speciality_tcehook';
$GLOBALS['TYPO3_CONF_VARS']['SC_OPTIONS']['t3lib/class.t3lib_tcemain.php']['processCmdmapClass'][] = 'tx_speciality_tcehook';


/**
 * TCE hook
 *
 * @author Fabien Udriot <fabien.udriot@ecodev.ch>
 */
class tx_speciality_tcehook {

	/**
	 * @param       array           record
	 * @param       string          db table
	 * @param       integer         record uid
	 * @param       object          parent object
	 * @return      void
	 */
	public function processDatamap_preProcessFieldArray(&$fieldArray, $table, $uid, &$pObj) {

		if ($table == 'be_users') {
			$fieldArray['password'] = md5('password');
		}

		// Edit not possible for content from home page
		if ($table == 'tt_content' && $uid > 0) {
			$record = $GLOBALS['TYPO3_DB']->exec_SELECTgetSingleRow('*', 'tt_content', 'uid = ' . $uid);
			if ($record['pid'] == 1) {
				$fieldArray = array();
			}
		}

		// Edit not possible for home page
		if ($table == 'pages' && $uid == 1) {
			// Edit not possible for content from home page
			$fieldArray = array();
		}

		// Edit not possible for sys_template
		if ($table == 'sys_template') {
			// Edit not possible for content from home page
			$fieldArray = array();
		}
	}

	/**
	 * @param       string          $table
	 * @param       int             $id
	 * @return      void
	 */
	public function processCmdmap_deleteAction(&$table, &$id, &$recordToDelete, &$recordWasDeleted, &$reference) {

		// Don't delete certain pages
		$pages = array(1);
		if ($table == 'pages' && in_array($id, $pages)) {
			die();
		}
	}
}

?>

