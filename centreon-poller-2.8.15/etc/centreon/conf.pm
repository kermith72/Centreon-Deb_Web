#############################################
# File Added by Centreon
#

$centreon_config = {
   	VarLib => "/var/lib/centreon",
   	CentreonDir => "/usr/share/centreon/",
   	"centreon_db" => "dbname=/etc/snmp/centreon_traps/centreontrapd.sdb",
   	"centstorage_db" => "dbname=/etc/snmp/centreon_traps/centreontrapd.sdb",
   	"db_host" => "",
   	"db_user" => "",
   	"db_passwd" => "",
   	"db_type" => "SQLite",
};

# Central or Poller ?
$instance_mode = "poller";

$cmdFile = "/var/lib/centreon-engine/rw/centengine.cmd";

1;
