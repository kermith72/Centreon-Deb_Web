<?php /* Smarty version 2.6.18, created on 2017-10-06 16:10:23
         compiled from content.tpl */ ?>
<table cellspacing="0" cellpadding="0" border="0" align="center" class="shell">
    <tr class="install-header">
        <th class="logo-wrapper">
            <a href="http://www.centreon.com" target="_blank"><img src="../img/centreon.png" alt="Centreon" border="0" /></a>
        </th>
        <th class="step-wrapper">
            <h3><span><?php echo $this->_tpl_vars['step']; ?>
</span> <?php echo $this->_tpl_vars['title']; ?>
</h3>
        </th>

    </tr>
    <tr class="install-body">
        <td align="left" colspan="2">
            <table width='100%' cellspacing="0" cellpadding="0" border="0" class="stdTable">
                <tr>
                    <td><?php echo $this->_tpl_vars['content']; ?>
</td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td colspan="2" id="installPub">
            <?php if (isset ( $this->_tpl_vars['finish'] ) && $this->_tpl_vars['finish'] == 1): ?>
                <script type="text/javascript">
                    <?php echo '
                    function pubcallback(html) {
                        jQuery("#installPub").html(html);
                    }

                    jQuery(document).ready(function() {
                        jQuery.ajax({
                            url: \'https://advertising.centreon.com/centreon-2.8.1/pub.json\',
                            type: \'GET\',
                            dataType: \'jsonp\',
                            crossDomain: true
                        });
                    });

                    '; ?>

                </script>
            <?php endif; ?>
        </td>
    </tr>

    <tr style='height:40px;'>
        <td>
            <?php if ($this->_tpl_vars['finish']): ?>
                <p class="link-group">
                    <a href="https://documentation.centreon.com" target="_blank">Documentation</a> |
                    <a href="https://github.com/centreon/centreon" target="_blank">Github </a> |
                    <a href="https://forum.centreon.com/" target="_blank">Forum</a> |
                    <a href="http://support.centreon.com" target="_blank">Support</a>
                    <b><a href=" https://www.centreon.com" target="_blank">www.centreon.com</a></b>
                </p>
            <?php endif; ?>
        </td>

        <td align='right'>
        <?php if (( $this->_tpl_vars['step']-1 && ! $this->_tpl_vars['blockPreview'] )): ?>
        <input class='btc bt_info' type='button' id='previous' value='Back' onClick='jumpTo(<?php echo $this->_tpl_vars['step']-1; ?>
);'/>
        <?php endif; ?>
        <input class='btc bt_default' type='button' id='refresh' value='Refresh' onClick='jumpTo(<?php echo $this->_tpl_vars['step']; ?>
);'/>
        <?php if (! $this->_tpl_vars['finish']): ?>
        <input class='btc bt_info' type='button' id='next' value='Next' onClick='if (validation() == true) jumpTo(<?php echo $this->_tpl_vars['step']+1; ?>
);'/>
        <?php else: ?>
        <input class='btc bt_success' type='button' id='finish' value='Finish' onClick='javascript:self.location="../main.php"'/>
        <?php endif; ?>
        </td>
    </tr>
</table>