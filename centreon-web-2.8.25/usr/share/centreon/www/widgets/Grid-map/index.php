<?php
/**
 * Copyright 2005-2011 MERETHIS
 * Centreon is developped by : Julien Mathis and Romain Le Merlus under
 * GPL Licence 2.0.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation ; either version 2 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, see <http://www.gnu.org/licenses>.
 *
 * Linking this program statically or dynamically with other modules is making a
 * combined work based on this program. Thus, the terms and conditions of the GNU
 * General Public License cover the whole combination.
 *
 * As a special exception, the copyright holders of this program give MERETHIS
 * permission to link this program with independent modules to produce an executable,
 * regardless of the license terms of these independent modules, and to copy and
 * distribute the resulting executable under terms of MERETHIS choice, provided that
 * MERETHIS also meet, for each linked independent module, the terms  and conditions
 * of the license of that module. An independent module is a module which is not
 * derived from this program. If you modify this program, you may extend this
 * exception to your version of the program, but you are not obliged to do so. If you
 * do not wish to do so, delete this exception statement from your version.
 *
 * For more information : contact@centreon.com
 *
 */

require_once "../require.php";

/* Get Env informations */
require_once "../../../config/centreon.config.php";

require_once $centreon_path . 'www/class/centreon.class.php';
require_once $centreon_path . 'www/class/centreonSession.class.php';
require_once $centreon_path . 'www/class/centreonDB.class.php';
require_once $centreon_path . 'www/class/centreonWidget.class.php';
require_once $centreon_path . 'www/class/centreonDuration.class.php';
require_once $centreon_path . 'www/class/centreonUtils.class.php';
require_once $centreon_path . 'www/class/centreonACL.class.php';
require_once $centreon_path . 'www/class/centreonHost.class.php';

/* load smarty Class */
require_once $centreon_path . 'GPL_LIB/Smarty/libs/Smarty.class.php';

session_start();

if (!isset($_SESSION['centreon']) || !isset($_REQUEST['widgetId'])) {
    exit;
}

$centreon = $_SESSION['centreon'];
$widgetId = $_REQUEST['widgetId'];

/* INIT */

$colors = array(
    0 => '#8FCF3C',
    1 => '#ff9a13',
    2 => '#e00b3d',
    3 => '#bcbdc0',
    4 => '#2AD1D4'
);

try {
    global $pearDB;

    $db_centreon = new CentreonDB();
    $db = new CentreonDB("centstorage");
    $pearDB = $db_centreon;

    if ($centreon->user->admin == 0) {
        $access = new CentreonACL($centreon->user->get_id());
        $grouplist = $access->getAccessGroups();
        $grouplistStr = $access->getAccessGroupsString();
    }

    $widgetObj = new CentreonWidget($centreon, $db_centreon);
    $preferences = $widgetObj->getWidgetPreferences($widgetId);
    $autoRefresh = 0;

    if (isset($preferences['refresh_interval'])) {
        $autoRefresh = $preferences['refresh_interval'];
    }
} catch (Exception $e) {
    echo $e->getMessage() . "<br/>";
    exit;
}

/* Start Smarty Init */
$template = new Smarty();
$template = initSmartyTplForPopup(getcwd()."/src/", $template, "./", $centreon_path);

$data = array();
$data_service = array();
$data_check = array();
$inc = 0;

if ($preferences['host_group']) {

/* Query 1 */
$query1 = "SELECT DISTINCT T1.name, T2.host_id " .
          "FROM hosts T1, hosts_hostgroups T2 " .($centreon->user->admin == 0 ? ", centreon_acl acl " : ""). 
          "WHERE T1.host_id = T2.host_id ".
          "AND T1.enabled = 1 ".
          "AND T2.hostgroup_id = ".$preferences['host_group'].
          ($centreon->user->admin == 0 ? " AND T1.host_id = acl.host_id AND T2.host_id = acl.host_id AND acl.group_id IN (" .($grouplistStr != "" ? $grouplistStr : 0).")" : "");

/* Query 2 */
$query2 = "SELECT distinct T1.description ".
          "FROM services T1 " .($centreon->user->admin == 0 ? ", centreon_acl acl " : "").
          "WHERE T1.enabled = 1 ".
          ($centreon->user->admin == 0 ? " AND T1.service_id = acl.service_id AND acl.group_id IN (" .($grouplistStr != "" ? $grouplistStr : 0).") AND (" : " AND (");
foreach (explode(",", $preferences['service']) as $elem) {
    if (!$inc) {
        $query2 .= "T1.description LIKE '$elem'";
    } else {
        $query2 .= " OR T1.description like '$elem'";
    }
    $inc++;
}
$query2 .= ");";

/* Query 3 */
$query3 = "SELECT DISTINCT T1.service_id, T1.description, T1.state, T1.host_id ".
          "FROM services T1 " .($centreon->user->admin == 0 ? ", centreon_acl acl " : "").
          "WHERE T1.enabled = 1 " .
          "AND T1.description NOT LIKE 'ba_%' AND T1.description NOT LIKE 'meta_%' ".
          ($centreon->user->admin == 0 ? " AND T1.service_id = acl.service_id AND acl.group_id IN (" .($grouplistStr != "" ? $grouplistStr : 0).")" : "");
$inc = 0;

$services = explode(",", $preferences['service']);
if (count($services)) {
    $query3 .= " AND (";
    foreach ($services as $elem) {
        if (!$inc) {
            $query3 .= "T1.description LIKE '$elem'";
        } else {
            $query3 .= " OR T1.description like '$elem'";
        }
        $inc++;
    }
    $query3 .= ")";
}

/* Get host listing */
$res = $db->query($query1);
while ($row = $res->fetchRow()) {
    $data[] = $row;
}

/* Get service listing */
$res2 = $db->query($query2);
while ($row = $res2->fetchRow()) {
    $data_service[$row['description']] = array(
					     'description' => $row['description'],
					     'hosts' => array(),
					     'hostsStatus' => array()
					     );
}

/* Get host service statuses */
$res3 = $db->query($query3);
while ($row = $res3->fetchRow()) {
    if (isset($data_service[$row['description']])) {
        $data_service[$row['description']]['hosts'][] = $row['host_id'];
        $data_service[$row['description']]['hostsStatus'][$row['host_id']] = $colors[$row['state']];
    }
}

}

$template->assign('autoRefresh', $autoRefresh);
$template->assign('preferences', $preferences);
$template->assign('widgetId', $widgetId);
$template->assign('data', $data);
$template->assign('data_service', $data_service);

/* Display */
$template->display('table.ihtml');
