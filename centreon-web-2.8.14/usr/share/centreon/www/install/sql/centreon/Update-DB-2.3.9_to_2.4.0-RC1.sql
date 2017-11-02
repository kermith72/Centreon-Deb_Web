--
-- Setting Centreon Engine as the default engine and adding a custom centreon engine configuration file
--
ALTER TABLE `cfg_nagios` ADD COLUMN `cfg_file` VARCHAR(255) NOT NULL DEFAULT 'centengine.cfg';
UPDATE `cfg_nagios` SET `cfg_file` = 'nagios.cfg' WHERE `cfg_dir` LIKE '%nagios%';
INSERT INTO `cfg_nagios` (`nagios_name`, `log_file`, `cfg_dir`, `object_cache_file`, `precached_object_file`, `temp_file`, `temp_path`, `status_file`, `check_result_path`, `max_check_result_file_age`, `p1_file`, `status_update_interval`, `nagios_user`, `nagios_group`, `enable_notifications`, `execute_service_checks`, `accept_passive_service_checks`, `execute_host_checks`, `accept_passive_host_checks`, `enable_event_handlers`, `log_rotation_method`, `log_archive_path`, `check_external_commands`, `external_command_buffer_slots`, `command_check_interval`, `command_file`, `downtime_file`, `comment_file`, `lock_file`, `retain_state_information`, `state_retention_file`, `retention_update_interval`, `use_retained_program_state`, `use_retained_scheduling_info`, `use_syslog`, `log_notifications`, `log_service_retries`, `log_host_retries`, `log_event_handlers`, `log_initial_states`, `log_external_commands`, `log_passive_checks`, `global_host_event_handler`, `global_service_event_handler`, `sleep_time`, `service_inter_check_delay_method`, `host_inter_check_delay_method`, `service_interleave_factor`, `max_concurrent_checks`, `max_service_check_spread`, `max_host_check_spread`, `check_result_reaper_frequency`, `interval_length`, `auto_reschedule_checks`, `auto_rescheduling_interval`, `auto_rescheduling_window`, `use_aggressive_host_checking`, `enable_flap_detection`, `low_service_flap_threshold`, `high_service_flap_threshold`, `low_host_flap_threshold`, `high_host_flap_threshold`, `soft_state_dependencies`, `service_check_timeout`, `host_check_timeout`, `event_handler_timeout`, `notification_timeout`, `ocsp_timeout`, `ochp_timeout`, `perfdata_timeout`, `obsess_over_services`, `ocsp_command`, `obsess_over_hosts`, `ochp_command`, `process_performance_data`, `host_perfdata_command`, `service_perfdata_command`, `host_perfdata_file`, `service_perfdata_file`, `host_perfdata_file_template`, `service_perfdata_file_template`, `host_perfdata_file_mode`, `service_perfdata_file_mode`, `host_perfdata_file_processing_interval`, `service_perfdata_file_processing_interval`, `host_perfdata_file_processing_command`, `service_perfdata_file_processing_command`, `check_for_orphaned_services`, `check_for_orphaned_hosts`, `check_service_freshness`, `service_freshness_check_interval`, `freshness_check_interval`, `check_host_freshness`, `host_freshness_check_interval`, `date_format`, `illegal_object_name_chars`, `illegal_macro_output_chars`, `use_regexp_matching`, `use_true_regexp_matching`, `admin_email`, `admin_pager`, `nagios_comment`, `nagios_activate`, `event_broker_options`, `translate_passive_host_checks`, `nagios_server_id`, `enable_predictive_host_dependency_checks`, `enable_predictive_service_dependency_checks`, `cached_host_check_horizon`, `cached_service_check_horizon`, `passive_host_checks_are_soft`, `use_large_installation_tweaks`, `free_child_process_memory`, `child_processes_fork_twice`, `enable_environment_macros`, `additional_freshness_latency`, `enable_embedded_perl`, `use_embedded_perl_implicitly`, `debug_file`, `debug_level`, `debug_level_opt`, `debug_verbosity`, `max_debug_file_size`, `cfg_file`) VALUES
('Centreon Engine CFG 1', '/var/log/centreon-engine/centengine.log', '/etc/centreon-engine/', NULL, NULL, '/var/log/centreon-engine/centengine.tmp', NULL, '/var/log/centreon-engine/status.dat', NULL, NULL, '/usr/sbin/p1.pl', NULL, 'centreon-engine', 'centreon-engine', '1', '1', '1', '2', '2', '1', 'd', '/var/log/centreon-engine/archives/', '1', NULL, '1s', '/var/lib/centreon-engine/rw/centengine.cmd', NULL, NULL, '/var/lock/subsys/centengine.lock', '1', '/var/log/centreon-engine/retention.dat', 60, '1', '1', '0', '1', '1', '1', '1', '1', '1', '2', NULL, NULL, '1', 's', NULL, 's', 200, 5, NULL, 5, 60, '2', NULL, NULL, '1', '0', '25.0', '50.0', '25.0', '50.0', '0', 60, 10, 30, 30, 5, 5, 5, '0', NULL, '2', NULL, '1', NULL, 41, NULL, NULL, NULL, NULL, '2', '2', NULL, NULL, NULL, NULL, '0', NULL, '1', NULL, NULL, '2', NULL, 'euro', '~!$%^&amp;*&quot;|&#039;&lt;&gt;?,()=', '`~$^&amp;&quot;|&#039;&lt;&gt;', '2', '2', 'admin@localhost', 'admin', 'Centreon Engine', '0', '-1', NULL, 1, '2', '2', NULL, NULL, NULL, '2', '2', '2', '2', NULL, '2', '2', '/var/log/centreon-engine/centengine.debug', 0, '0', '2', NULL, 'centengine.cfg');



INSERT INTO `topology` (topology_name, topology_icone,topology_parent, topology_page, topology_order, topology_group, topology_url, topology_show) VALUES
('Custom Views', NULL, '1', '103', '1', '1', './include/home/customViews/index.php', '1'),
('Edit', NULL, '103', '10301', NULL, NULL, './include/home/customViews/form.php', '0'),
('Share', NULL, '103', '10302', NULL, NULL, './include/home/customViews/shareView.php', '0'),
('Parameters', NULL, '103', '10303', NULL, NULL, './include/home/customViews/widgetParam.php', '0'),
('Add Widget', NULL, '103', '10304', NULL, NULL, './include/home/customViews/addWidget.php', '0'),
('Rotation', NULL, '103', '10305', NULL, NULL, './include/home/customViews/rotation.php', '0'),
('Widgets', NULL, '507', NULL, '2', '30', NULL, '1'),
('Setup', './img/icones/16x16/press.gif', '507', '50703', '30', '30', './include/options/oreon/widgets/widgets.php', '1');

-- --------------------------------------------------------
--
-- Structure de la table `custom_views`
--

CREATE TABLE IF NOT EXISTS `custom_views` (
	`custom_view_id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
	`name` VARCHAR( 255 ) NOT NULL,
	`layout` VARCHAR( 255 ) NOT NULL,
	PRIMARY KEY (  `custom_view_id` )
) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `custom_view_user_relation`
--

CREATE TABLE IF NOT EXISTS `custom_view_user_relation` (
	`custom_view_id` INT( 11 ) NOT NULL,
	`user_id` INT( 11 ) NULL,
	`usergroup_id` INT( 11 ) NULL,
	`locked` TINYINT( 6 ) DEFAULT 0,	
	`is_owner` TINYINT( 6 ) DEFAULT 0,
	CONSTRAINT `fk_custom_views_user_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `contact` (`contact_id` )
    ON DELETE CASCADE,
    CONSTRAINT `fk_custom_views_usergroup_id`
    FOREIGN KEY (`usergroup_id` )
    REFERENCES `contactgroup` (`cg_id` )
    ON DELETE CASCADE,
    CONSTRAINT `fk_custom_view_user_id`
    FOREIGN KEY (`custom_view_id` )
    REFERENCES `custom_views` (`custom_view_id` )
    ON DELETE CASCADE
) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

ALTER TABLE  `custom_view_user_relation` ADD UNIQUE  `view_user_unique_index` ( `custom_view_id` , `user_id`, `usergroup_id` );


-- --------------------------------------------------------

--
-- Structure de la table `custom_view_default`
--

CREATE TABLE IF NOT EXISTS `custom_view_default` (
  `user_id` INT (11) NOT NULL,
  `custom_view_id` INT (11) NOT NULL,
  CONSTRAINT `fk_custom_view_default_user_id`
  FOREIGN KEY (`user_id` )
  REFERENCES `contact` (`contact_id` )
  ON DELETE CASCADE,
  CONSTRAINT `fk_custom_view_default_cv_id`
  FOREIGN KEY (`custom_view_id` )
  REFERENCES `custom_views` ( `custom_view_id` )
  ON DELETE CASCADE
) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `widget_models`
--

CREATE TABLE IF NOT EXISTS  `widget_models` (
	`widget_model_id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
	`title` VARCHAR( 255 ) NOT NULL ,
	`description` VARCHAR( 255 ) NOT NULL ,
	`url` VARCHAR( 255 ) NOT NULL ,
	`version` VARCHAR( 255 ) NOT NULL ,
	`directory` VARCHAR( 255 ) NOT NULL,
	`author` VARCHAR( 255 ) NOT NULL ,
	`email` VARCHAR( 255 ) NULL ,
	`website` VARCHAR( 255 ) NULL ,
	`keywords` VARCHAR( 255 ) NULL ,
	`screenshot` VARCHAR( 255 ) NULL ,
	`thumbnail` VARCHAR( 255 ) NULL ,
	`autoRefresh` INT( 11 ) NULL,	
	PRIMARY KEY (  `widget_model_id` )
) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `widgets`
--

CREATE TABLE IF NOT EXISTS  `widgets` (
	`widget_id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
	`widget_model_id` INT( 11 ) NOT NULL,
	`title` VARCHAR( 255 ) NOT NULL ,	
	CONSTRAINT `fk_wdg_model_id`
	FOREIGN KEY (`widget_model_id`)
	REFERENCES `widget_models` (`widget_model_id`)
	ON DELETE CASCADE,
	PRIMARY KEY (  `widget_id` )
) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `widget_views`
--

CREATE TABLE IF NOT EXISTS `widget_views` (
	`widget_view_id` INT( 11 ) NOT NULL AUTO_INCREMENT ,
	`custom_view_id` INT( 11 ) NOT NULL ,
	`widget_id` INT( 11 ) NOT NULL ,	
	`widget_order` VARCHAR( 255 ) NOT NULL ,	
	PRIMARY KEY (  `widget_view_id` ),
	CONSTRAINT `fk_custom_view_id`
    FOREIGN KEY (`custom_view_id` )
    REFERENCES `custom_views` (`custom_view_id` )
    ON DELETE CASCADE,
    CONSTRAINT `fk_widget_id`
    FOREIGN KEY (`widget_id` )
    REFERENCES `widgets` (`widget_id` )
    ON DELETE CASCADE    
) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `widget_parameters_field_type`
--

CREATE TABLE IF NOT EXISTS `widget_parameters_field_type` (
  `field_type_id` INT ( 11 ) NOT NULL AUTO_INCREMENT ,
  `ft_typename` VARCHAR(50) NOT NULL ,
  `is_connector` TINYINT(6) NOT NULL DEFAULT 0,
  PRIMARY KEY (`field_type_id`) 
) ENGINE = InnoDB CHARACTER SET utf8 COLLATE utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `widget_parameters`
--

CREATE TABLE IF NOT EXISTS `widget_parameters` (
	`parameter_id` INT( 11 ) NOT NULL AUTO_INCREMENT,
	`parameter_name` VARCHAR( 255 ) NOT NULL,
	`parameter_code_name` VARCHAR( 255 ) NOT NULL,
	`default_value` VARCHAR( 255 ) NULL,
	`parameter_order` TINYINT(6) NOT NULL,
	`header_title` VARCHAR( 255 ) NULL,
	`require_permission` VARCHAR( 255 ) NOT NULL,
	`widget_model_id` INT( 11 ) NOT NULL ,
	`field_type_id` INT( 11 ) NOT NULL,
	PRIMARY KEY (  `parameter_id` ),
	CONSTRAINT `fk_widget_param_widget_id`
    FOREIGN KEY (`widget_model_id` )
    REFERENCES `widget_models` (`widget_model_id` )
    ON DELETE CASCADE,    
	CONSTRAINT `fk_widget_field_type_id`
    FOREIGN KEY (`field_type_id` )
    REFERENCES `widget_parameters_field_type` (`field_type_id` )
    ON DELETE CASCADE
) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `widget_preferences`
--

CREATE TABLE IF NOT EXISTS `widget_preferences` (
	`widget_view_id` INT( 11 ) NOT NULL ,
	`parameter_id` INT( 11 ) NOT NULL ,
	`preference_value` VARCHAR( 255 ) NOT NULL,
	`user_id` INT( 11 ) NOT NULL,
	CONSTRAINT `fk_widget_view_id`
    FOREIGN KEY (`widget_view_id` )
    REFERENCES `widget_views` (`widget_view_id` )
    ON DELETE CASCADE,
    CONSTRAINT `fk_widget_parameter_id`
    FOREIGN KEY (`parameter_id` )
    REFERENCES `widget_parameters` (`parameter_id` )
    ON DELETE CASCADE,
    UNIQUE  `widget_preferences_unique_index` (  `widget_view_id` ,  `parameter_id`, `user_id` )
) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;


-- --------------------------------------------------------

--
-- Structure de la table `widget_parameters_multiple_options`
--

CREATE TABLE IF NOT EXISTS `widget_parameters_multiple_options` (
	`parameter_id` INT ( 11 ) NOT NULL,
	`option_name` VARCHAR ( 255 ) NOT NULL,
	`option_value` VARCHAR ( 255 ) NOT NULL,
	CONSTRAINT `fk_option_parameter_id`
    FOREIGN KEY (`parameter_id` )
    REFERENCES `widget_parameters` (`parameter_id` )
    ON DELETE CASCADE
) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `widget_parameters_range`
--

CREATE TABLE IF NOT EXISTS `widget_parameters_range` (
	`parameter_id` INT ( 11 ) NOT NULL,
	`min_range` INT ( 11 ) NOT NULL,
	`max_range` INT ( 11 ) NOT NULL,
	`step` INT ( 11 ) NOT NULL,
	CONSTRAINT `fk_option_range_id`
    FOREIGN KEY (`parameter_id` )
    REFERENCES `widget_parameters` (`parameter_id` )
    ON DELETE CASCADE
) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

-- 
-- For LDAP store password option default value
--
INSERT INTO `options` (`key`, `value`) VALUES ('ldap_store_password', '1');

--
-- Table structure for table `cfg_resource_instance_relations`
--

CREATE TABLE IF NOT EXISTS `cfg_resource_instance_relations` (
  `resource_id` int(11) NOT NULL,
  `instance_id` int(11) NOT NULL,
  CONSTRAINT `fk_crir_res_id` 
  FOREIGN KEY (`resource_id`)
  REFERENCES `cfg_resource` (`resource_id`)
  ON DELETE CASCADE,
  CONSTRAINT `fk_crir_ins_id` 
  FOREIGN KEY (`instance_id`)
  REFERENCES `nagios_server` (`id`)
  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE  `cfg_cgi` ADD  `instance_id` INT( 11 ) NULL AFTER  `cgi_name`;
ALTER TABLE  `cfg_cgi` ADD CONSTRAINT `fk_cgi_instance_id` FOREIGN KEY (`instance_id`) REFERENCES `nagios_server` (`id`) ON DELETE SET NULL;

-- 
-- Clone the active cgi configuration for each active poller instance and link them together
-- 
INSERT INTO `cfg_cgi`(
    `cfg_cgi`.`cgi_name`,
    `cfg_cgi`.`instance_id`,
    `cfg_cgi`.`main_config_file`,
    `cfg_cgi`.`physical_html_path`,
    `cfg_cgi`.`url_html_path`,
    `cfg_cgi`.`nagios_check_command`,
    `cfg_cgi`.`use_authentication`,
    `cfg_cgi`.`default_user_name`,
    `cfg_cgi`.`authorized_for_system_information`,
    `cfg_cgi`.`authorized_for_system_commands`,
    `cfg_cgi`.`authorized_for_configuration_information`,
    `cfg_cgi`.`authorized_for_all_hosts`,
    `cfg_cgi`.`authorized_for_all_host_commands`,
    `cfg_cgi`.`authorized_for_all_services`,
    `cfg_cgi`.`authorized_for_all_service_commands`,
    `cfg_cgi`.`statusmap_background_image`,
    `cfg_cgi`.`default_statusmap_layout`,
    `cfg_cgi`.`statuswrl_include`,
    `cfg_cgi`.`default_statuswrl_layout`,
    `cfg_cgi`.`refresh_rate`,
    `cfg_cgi`.`host_unreachable_sound`,
    `cfg_cgi`.`host_down_sound`,
    `cfg_cgi`.`service_critical_sound`,
    `cfg_cgi`.`service_warning_sound`,
    `cfg_cgi`.`service_unknown_sound`,
    `cfg_cgi`.`ping_syntax`,
    `cfg_cgi`.`cgi_comment`,
    `cfg_cgi`.`cgi_activate`
) SELECT
    CONCAT(`cfg_cgi`.`cgi_name`, '_', `nagios_server`.`name`),
    `nagios_server`.`id` `instance_id`,
    `cfg_cgi`.`main_config_file`,
    `cfg_cgi`.`physical_html_path`,
    `cfg_cgi`.`url_html_path`,
    `cfg_cgi`.`nagios_check_command`,
    `cfg_cgi`.`use_authentication`,
    `cfg_cgi`.`default_user_name`,
    `cfg_cgi`.`authorized_for_system_information`,
    `cfg_cgi`.`authorized_for_system_commands`,
    `cfg_cgi`.`authorized_for_configuration_information`,
    `cfg_cgi`.`authorized_for_all_hosts`,
    `cfg_cgi`.`authorized_for_all_host_commands`,
    `cfg_cgi`.`authorized_for_all_services`,
    `cfg_cgi`.`authorized_for_all_service_commands`,
    `cfg_cgi`.`statusmap_background_image`,
    `cfg_cgi`.`default_statusmap_layout`,
    `cfg_cgi`.`statuswrl_include`,
    `cfg_cgi`.`default_statuswrl_layout`,
    `cfg_cgi`.`refresh_rate`,
    `cfg_cgi`.`host_unreachable_sound`,
    `cfg_cgi`.`host_down_sound`,
    `cfg_cgi`.`service_critical_sound`,
    `cfg_cgi`.`service_warning_sound`,
    `cfg_cgi`.`service_unknown_sound`,
    `cfg_cgi`.`ping_syntax`,
    `cfg_cgi`.`cgi_comment`,
    `cfg_cgi`.`cgi_activate`
FROM
    `cfg_cgi`
JOIN
    `nagios_server`
ON
    1=1
WHERE
    `cfg_cgi`.`cgi_activate` = '1' AND
    `nagios_server`.`ns_activate` = '1'
ORDER BY
    `cfg_cgi`.`cgi_id` ASC;

-- 
-- This is a continuation of the last query; It deletes the original cgi configuration entry because now it is orphane (poller)
-- 
DELETE FROM
    `cfg_cgi`
WHERE
    `cfg_cgi`.`cgi_activate` = '1'
ORDER BY
    `cfg_cgi`.`cgi_id` ASC
LIMIT
    1;

INSERT INTO `options` (`key`, `value`) VALUES ('cengine_path_connectors','/usr/lib/centreon-connector/');
UPDATE  `options` SET  `value` =  'CENGINE' WHERE CONVERT(  `options`.`key` USING utf8 ) =  'monitoring_engine' AND CONVERT(  `options`.`value` USING utf8 ) =  'NAGIOS' LIMIT 1 ;
UPDATE `informations` SET `value` = '2.4.0' WHERE CONVERT( `informations`.`key` USING utf8 )  = 'version' AND CONVERT ( `informations`.`value` USING utf8 ) = '2.3.x' LIMIT 1;

SET foreign_key_checks = 0;
INSERT INTO `topology` (`topology_id`, `topology_name`, `topology_icone`, `topology_parent`, `topology_page`, `topology_order`, `topology_group`, `topology_url`, `topology_url_opt`, `topology_popup`, `topology_modules`, `topology_show`, `topology_style_class`, `topology_style_id`, `topology_OnClick`, `readonly`) VALUES
(NULL, 'SNMP Traps', NULL, 6, 611, 40, 1, NULL, NULL, '0', '0', '1', NULL, NULL, NULL, '1'),
(NULL, 'SNMP Traps', NULL, 611, NULL, 40, 1, NULL, NULL, '0', '0', '1', NULL, NULL, NULL, '1');
UPDATE  `topology` SET `topology_name` = 'SNMP Traps', `topology_parent` =  '611', `topology_page` = '61101', `topology_order` = '10', `topology_group` =  '1'  WHERE  `topology_page` = 60205;
UPDATE  `topology` SET `topology_name` = 'Manufacturer', `topology_parent` =  '611', `topology_page` = '61102', `topology_order` = '20', `topology_group` =  '1'  WHERE  `topology_page` = 60207;
UPDATE  `topology` SET `topology_name` = 'MIBs', `topology_parent` =  '611', `topology_page` = '61103', `topology_order` = '30', `topology_group` =  '1'  WHERE  `topology_page` = 60208;
UPDATE  `topology` SET `topology_name` = 'Generate', `topology_parent` =  '611', `topology_page` = '61104', `topology_order` = '40', `topology_group` =  '1'  WHERE  `topology_page` = 60705;
UPDATE  `topology_JS` SET  `id_page` =  '61101' WHERE  `id_page` = 60205;
UPDATE  `topology_JS` SET  `id_page` =  '61102' WHERE  `id_page` = 60207;
UPDATE  `topology_JS` SET  `id_page` =  '61103' WHERE  `id_page` = 60208;
UPDATE  `topology_JS` SET  `id_page` =  '61104' WHERE  `id_page` = 60705;
SET foreign_key_checks = 1;

--
-- Add columns for round min max in grpah
--
ALTER TABLE `giv_components_template` ADD `ds_minmax_int` ENUM('0', '1') DEFAULT '0' AFTER `ds_min`;

INSERT INTO `cfg_resource` (`resource_id`, `resource_name`, `resource_line`, `resource_comment`, `resource_activate`) VALUES
(NULL, '$USER3$', '/usr/lib/centreon-connector', 'path to the connectors', '1');

--
-- Adding all combinations between all old resources and pollers in order to keep the same functionality as in Centreon 2.3.9
--
INSERT INTO `cfg_resource_instance_relations` (`resource_id`, `instance_id`) SELECT `cfg_resource`.`resource_id`, `nagios_server`.`id` FROM `cfg_resource` JOIN `nagios_server` ON 1=1;

--
-- Adding connectors structure
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connector` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_swedish_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_swedish_ci DEFAULT NULL,
  `command_line` text CHARACTER SET utf8 COLLATE utf8_swedish_ci,
  `enabled` int(1) unsigned NOT NULL DEFAULT '1',
  `created` int(10) unsigned NOT NULL,
  `modified` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

ALTER TABLE `command`  ADD `connector_id` INT UNSIGNED NULL DEFAULT NULL AFTER `command_id`,  ADD INDEX (`connector_id`);
ALTER TABLE `command` ADD CONSTRAINT `command_ibfk_1` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- End adding connectors structure
--

--
-- Contenu de la table Connector
--
INSERT INTO `connector` (`id`, `name`, `description`, `command_line`, `enabled`, `created`, `modified`) VALUES
(1, 'Perl Connector', '', '$USER3$/centreon_connector_perl', 1, 1345126890, 1345127506),
(2, 'SSH Connector', '', '$USER3$/centreon_connector_ssh', 1, 1345127090, 1345127508);

--
-- Nagios server init script for  snmptt
--

ALTER TABLE `nagios_server` ADD COLUMN `init_script_snmptt` VARCHAR(255) DEFAULT NULL;

--
-- End nagios server init script for  snmptt
--

--
-- Add js effects options
--

ALTER TABLE contact ADD COLUMN contact_js_effects ENUM('0','1') DEFAULT '0' AFTER contact_comment;

--
-- End js effects options
--

--
-- Max check result reaper time
--

ALTER TABLE  `cfg_nagios` ADD  `max_check_result_reaper_time` INT( 11 ) NULL AFTER  `check_result_reaper_frequency`;

--
-- End max check result reaper time
--


--
-- Retentions masks
--

ALTER TABLE  `cfg_nagios` ADD  `retained_contact_host_attribute_mask` BIGINT NULL AFTER  `use_retained_scheduling_info` ,
ADD  `retained_contact_service_attribute_mask` BIGINT NULL AFTER  `retained_contact_host_attribute_mask` ,
ADD  `retained_process_host_attribute_mask` BIGINT NULL AFTER  `retained_contact_service_attribute_mask` ,
ADD  `retained_process_service_attribute_mask` BIGINT NULL AFTER  `retained_process_host_attribute_mask` ,
ADD  `retained_host_attribute_mask` BIGINT NULL AFTER  `retained_process_service_attribute_mask` ,
ADD  `retained_service_attribute_mask` BIGINT NULL AFTER  `retained_host_attribute_mask` ;

--
-- End retention masks
--


--
-- Added connectors menu to topology
--

INSERT INTO `topology` (`topology_id`, `topology_name`, `topology_icone`, `topology_parent`, `topology_page`, `topology_order`, `topology_group`, `topology_url`, `topology_url_opt`, `topology_popup`, `topology_modules`, `topology_show`, `topology_style_class`, `topology_style_id`, `topology_OnClick`, `readonly`) VALUES (NULL, 'Connectors', NULL, '608', NULL, NULL, 3, NULL, NULL, '0', '0', '1', NULL, NULL, NULL, '1');
INSERT INTO `topology` (`topology_id`, `topology_name`, `topology_icone`, `topology_parent`, `topology_page`, `topology_order`, `topology_group`, `topology_url`, `topology_url_opt`, `topology_popup`, `topology_modules`, `topology_show`, `topology_style_class`, `topology_style_id`, `topology_OnClick`, `readonly`) VALUES (NULL, 'Connectors', './img/icones/16x16/gauge.gif', 608, 60806, 60, 3, './include/configuration/configObject/connector/connector.php', NULL, '0', '0', '1', NULL, NULL, NULL, '1');
--
-- End added connectors menu to topology
--

--
-- Add unique configuration block type in Centreon Broker
--
ALTER TABLE `cb_tag_type_relation` ADD COLUMN `cb_type_uniq` int(1) NOT NULL DEFAULT 0 AFTER `cb_type_id`;
UPDATE `cb_tag_type_relation` SET `cb_type_uniq` = 1 WHERE `cb_tag_id` = 4 AND `cb_type_id` = 22;
INSERT INTO `topology_JS` (`id_page`, `o`, `PathName_js`, `Init`) VALUES
('60909', 'c', NULL, 'loadedConfiguration'),
('60909', 'w', NULL, 'loadedConfiguration'),
('60909', 'a', NULL, 'loadedConfiguration');

--
-- Add retry interval for input and output in Centreon Broker
-- 
INSERT INTO `cb_field` (`cb_field_id`, `fieldname`, `displayname`, `description`, `fieldtype`, `external`) VALUES
(31, 'retry_interval', 'Retry Interval', 'Time in seconds to wait between each connection attempt.', 'int', NULL),
(32, 'buffering_timeout', 'Buffering Timeout', 'Time in seconds to wait before launching failover.', 'int', NULL);
INSERT INTO `cb_type_field_relation` (`cb_type_id`, `cb_field_id`, `is_required`, `order_display`) VALUES
(21, 31, 0, 2),
(21, 32, 0, 2);

--
-- Add options for statistics file in Centreon Broker
--
INSERT INTO `cb_tag` (`cb_tag_id`, `tagname`) VALUES (5, 'stats');
INSERT INTO `cb_module` (`cb_module_id`, `name`, `libname`, `loading_pos`, `is_bundle`, `is_activated`) VALUES (14, 'Statistics', 'stats.so', 5, 0, 1);
INSERT INTO `cb_type` (`cb_type_id`, `type_name`, `type_shortname`, `cb_module_id`) VALUES (23, 'Statistics', 'stats', 14);
INSERT INTO `cb_field` (`cb_field_id`, `fieldname`, `displayname`, `description`, `fieldtype`, `external`) VALUES (33, 'fifo', 'File for Centreon Broker statistics', 'File where Centreon Broker statistics will be stored', 'text', NULL);
INSERT INTO `cb_tag_type_relation` (`cb_tag_id`, `cb_type_id`, `cb_type_uniq`) VALUES (5, 23, 1);
INSERT INTO `cb_type_field_relation` (`cb_type_id`, `cb_field_id`, `is_required`, `order_display`) VALUES (23, 33, 1, 1);

--
-- Add options for transactions in SQL connector for Centreon Broker
--
INSERT INTO `cb_field` (`cb_field_id`, `fieldname`, `displayname`, `description`, `fieldtype`, `external`) VALUES
(34, 'queries_per_transaction', 'Maximum queries per transaction', 'The maximum queries per transaction before commit.', 'int', NULL),
(35, 'read_timeout', 'Transaction commit timeout', 'The transaction timeout before running commit.', 'int', NULL);
INSERT INTO `cb_type_field_relation` (`cb_type_id`, `cb_field_id`, `is_required`, `order_display`) VALUES
(16, 34, 0, 7),
(16, 35, 0, 8),
(14, 34, 0, 9),
(14, 35, 0, 10);

--
-- Add wizards topology for Centreon Broker
--
INSERT INTO `topology` (`topology_id`, `topology_name`, `topology_icone`, `topology_parent`, `topology_page`, `topology_order`, `topology_group`, `topology_url`, `topology_url_opt`, `topology_popup`, `topology_modules`, `topology_show`, `topology_style_class`, `topology_style_id`, `topology_OnClick`, `readonly`) VALUES
(NULL, 'Wizard', NULL, 60909, 6090901, 40, 11, './include/configuration/configCentreonBroker/wizard.php', NULL, '0', '0', '0', NULL, NULL, NULL, '1'),
(NULL, 'WizardAjax', NULL, 60909, 6090902, 40, 11, './include/configuration/configCentreonBroker/wizard_ajax.php', NULL, '0', '0', '0', NULL, NULL, NULL, '1');

--
-- Add enable shell option for commands
--

ALTER TABLE  `command` ADD  `enable_shell` INT( 1 ) UNSIGNED NOT NULL DEFAULT  '0' AFTER  `command_type`;

--
-- End add enable shell option for commands
--

--
-- Replace Nagios name for generic
--
UPDATE `topology` SET `topology_name` = 'Monitoring Engine' WHERE `topology_parent` = 202 AND `topology_group` = 12 AND `topology_page` IS NULL;
UPDATE `topology` SET `topology_name` = 'Monitoring Engine' WHERE `topology_parent` = 202 AND `topology_group` = 33 AND `topology_page` IS NULL;
UPDATE `topology` SET `topology_name` = 'Monitoring Engine' WHERE `topology_parent` = 607 AND `topology_group` = 33 AND `topology_page` IS NULL;
UPDATE `topology` SET `topology_name` = 'Monitoring Engine' WHERE `topology_parent` = 203 AND `topology_group` = 34 AND `topology_page` IS NULL;
UPDATE `topology` SET `topology_name` = 'Monitoring Engine' WHERE `topology_parent` = 201 AND `topology_group` = 2 AND `topology_page` IS NULL;
UPDATE `topology` SET `topology_name` = 'Monitoring Engine' WHERE `topology_page` = 607;
UPDATE `topology` SET `topology_name` = 'Monitoring Engine Statistics' WHERE `topology_page` = 102;
UPDATE `topology` SET `topology_name` = 'main.cfg' WHERE `topology_page` = 60703;

--
-- Criticality stuff
--
CREATE TABLE `criticality` (
  `criticality_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `level` int(11) NOT NULL,
  `comments` text,
  `icon_id` int(11) NOT NULL,
  PRIMARY KEY  (`criticality_id`),
  KEY `fk_criticality_icon_id` (`icon_id`),
  CONSTRAINT `fk_criticality_icon_id` FOREIGN KEY (`icon_id`) REFERENCES `view_img` (`img_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `criticality_resource_relations` (
  `criticality_id` int(11) NOT NULL,
  `host_id` int(11) default NULL,
  `service_id` int(11) default NULL,
  KEY `fk_crit_host_id` (`host_id`),
  KEY `fk_crit_svc_id` (`service_id`),
  CONSTRAINT `fk_crit_host_id` FOREIGN KEY (`host_id`) REFERENCES `host` (`host_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_crit_svc_id` FOREIGN KEY (`service_id`) REFERENCES `service` (`service_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `topology` (`topology_name`, `topology_icone`, `topology_parent`, `topology_page`, `topology_order`, `topology_group`, `topology_url`, `topology_url_opt`, `topology_popup`, `topology_modules`, `topology_show`, `topology_style_class`, `topology_style_id`, `topology_OnClick`, `readonly`) VALUES
                       ('Extra', NULL, 602, NULL, NULL, 10, NULL, NULL, NULL, NULL, '1', NULL, NULL, NULL, '1'),
                       ('Extra', NULL, 601, NULL, 20, 2, NULL, NULL, NULL, NULL, '1', NULL, NULL, NULL, '1'),
                       ('Criticality', './img/icones/16x16/scroll_warning.gif', 602, 60228, 10, 10, './include/configuration/configObject/criticality/index.php', NULL, NULL, NULL, '1', NULL, NULL, NULL, '1'),
                       ('Criticality', './img/icones/16x16/scroll_warning.gif', 601, 60107, 10, 2, './include/configuration/configObject/criticality/index.php', NULL, NULL, NULL, '1', NULL, NULL, NULL, '1');

INSERT INTO `nagios_macro` (`macro_name`) VALUES ('$_HOSTCRITICALITY_LEVEL$');
INSERT INTO `nagios_macro` (`macro_name`) VALUES ('$_SERVICECRITICALITY_LEVEL$');
INSERT INTO `nagios_macro` (`macro_name`) VALUES ('$_HOSTCRITICALITY_ID$');
INSERT INTO `nagios_macro` (`macro_name`) VALUES ('$_SERVICECRITICALITY_ID$');

--
-- End of criticality stuff
--

--
-- Add wizards topology for Centreon Broker
--
INSERT INTO `topology` (`topology_id`, `topology_name`, `topology_icone`, `topology_parent`, `topology_page`, `topology_order`, `topology_group`, `topology_url`, `topology_url_opt`, `topology_popup`, `topology_modules`, `topology_show`, `topology_style_class`, `topology_style_id`, `topology_OnClick`, `readonly`) VALUES
(NULL, 'Broker Statistics', './img/icones/16x16/document_gear.gif', 102, 10205, 15, 1, './include/Administration/brokerPerformance/brokerPerformance.php', NULL, '0', '0', '1', NULL, NULL, NULL, '1');
UPDATE `topology` SET `topology_order` = 20 WHERE `topology_page` = 10201;

INSERT INTO `widget_parameters_field_type` (`ft_typename`, `is_connector`) VALUES 
                                           ('text', 0),
                                           ('boolean', 0),
                                           ('hidden', 0),
                                           ('password', 0),
                                           ('list', 0),
                                           ('range', 0),
                                           ('compare', 0),
                                           ('sort', 0),
                                           ('date', 0),
                                           ('host', 1),
                                           ('hostTemplate', 1),
                                           ('serviceTemplate', 1),
                                           ('hostgroup', 1),
                                           ('servicegroup', 1),
                                           ('service', 1);

UPDATE `informations` SET `value` = '2.4.0-RC1' WHERE CONVERT( `informations`.`key` USING utf8 )  = 'version' AND CONVERT ( `informations`.`value` USING utf8 ) = '2.3.9' LIMIT 1;
