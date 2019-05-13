<?php
/**
 * @package     HTML_QuickForm
 * @author      Herim Vasquez <vasquezh@iro.umontreal.ca>
 * @author      Bertrand Mansion <bmansion@mamasam.com>
 * @author      Alexey Borzov <avb@php.net>
 * @copyright   2001-2011 The PHP Group
 * @license     http://www.php.net/license/3_01.txt PHP License 3.01
 */

/**
 * Hierarchical select element
 *
 * Class to dynamically create two or more HTML Select elements
 * The first select changes the content of the second select and so on.
 * This element is considered as a group. Selects will be named
 * groupName[0], groupName[1], groupName[2]...
 *
 * @package     HTML_QuickForm
 * @author      Herim Vasquez <vasquezh@iro.umontreal.ca>
 * @author      Bertrand Mansion <bmansion@mamasam.com>
 * @author      Alexey Borzov <avb@php.net>
 */
class HTML_QuickForm_hierselect extends HTML_QuickForm_group
{
    /**
     * Options for all the select elements
     *
     * @see       setOptions()
     * @var       array
     * @access    private
     */
    var $_options = array();

    /**
     * Number of select elements on this group
     *
     * @var       int
     * @access    private
     */
    var $_nbElements = 0;

    /**
     * The javascript used to set and change the options
     *
     * @var       string
     * @access    private
     */
    var $_js = '';

    /**
     * Class constructor
     *
     * @param     string    $elementName    (optional)Input field name attribute
     * @param     string    $elementLabel   (optional)Input field label in form
     * @param     mixed     $attributes     (optional)Either a typical HTML attribute string
     *                                      or an associative array. Date format is passed along the attributes.
     * @param     mixed     $separator      (optional)Use a string for one separator,
     *                                      use an array to alternate the separators.
     */
    function __construct($elementName=null, $elementLabel=null, $attributes=null, $separator=null)
    {
        parent::__construct($elementName, $elementLabel, $attributes);
        $this->_persistantFreeze = true;
        if (isset($separator)) {
            $this->_separator = $separator;
        }
        $this->_type = 'hierselect';
        $this->_appendName = true;
    }

    /**
     * Initialize the array structure containing the options for each select element.
     * Call the functions that actually do the magic.
     *
     * Format is a bit more complex than for a simple select as we need to know
     * which options are related to the ones in the previous select:
     *
     * Ex:
     * <code>
     * // first select
     * $select1[0] = 'Pop';
     * $select1[1] = 'Classical';
     * $select1[2] = 'Funeral doom';
     *
     * // second select
     * $select2[0][0] = 'Red Hot Chil Peppers';
     * $select2[0][1] = 'The Pixies';
     * $select2[1][0] = 'Wagner';
     * $select2[1][1] = 'Strauss';
     * $select2[2][0] = 'Pantheist';
     * $select2[2][1] = 'Skepticism';
     *
     * // If only need two selects
     * //     - and using the deprecated functions
     * $sel =& $form->addElement('hierselect', 'cds', 'Choose CD:');
     * $sel->setMainOptions($select1);
     * $sel->setSecOptions($select2);
     *
     * //     - and using the new setOptions function
     * $sel =& $form->addElement('hierselect', 'cds', 'Choose CD:');
     * $sel->setOptions(array($select1, $select2));
     *
     * // If you have a third select with prices for the cds
     * $select3[0][0][0] = '15.00$';
     * $select3[0][0][1] = '17.00$';
     * // etc
     *
     * // You can now use
     * $sel =& $form->addElement('hierselect', 'cds', 'Choose CD:');
     * $sel->setOptions(array($select1, $select2, $select3));
     * </code>
     *
     * @param     array    $options    Array of options defining each element
     */
    public function setOptions($options)
    {
        $this->_options = $options;

        if (empty($this->_elements)) {
            $this->_nbElements = count($this->_options);
            $this->_createElements();
        } else {
            // setDefaults has probably been called before this function
            // check if all elements have been created
            $totalNbElements = count($this->_options);
            for ($i = $this->_nbElements; $i < $totalNbElements; $i ++) {
                $this->_elements[] = new HTML_QuickForm_select($i, null, array(), $this->getAttributes());
                $this->_nbElements++;
            }
        }

        $this->_setOptions();
    }

    /**
     * Sets the options for the first select element. Deprecated. setOptions() should be used.
     *
     * @param     array     $array    Options for the first select element
     *
     * @deprecated          Deprecated since release 3.2.2
     */
    public function setMainOptions($array)
    {
        $this->_options[0] = $array;

        if (empty($this->_elements)) {
            $this->_nbElements = 2;
            $this->_createElements();
        }
    }

    /**
     * Sets the options for the second select element. Deprecated. setOptions() should be used.
     * The main _options array is initialized and the _setOptions function is called.
     *
     * @param     array     $array    Options for the second select element
     *
     * @deprecated          Deprecated since release 3.2.2
     */
    public function setSecOptions($array)
    {
        $this->_options[1] = $array;

        if (empty($this->_elements)) {
            $this->_nbElements = 2;
            $this->_createElements();
        } else {
            // setDefaults has probably been called before this function
            // check if all elements have been created
            $totalNbElements = 2;
            for ($i = $this->_nbElements; $i < $totalNbElements; $i ++) {
                $this->_elements[] = new HTML_QuickForm_select($i, null, array(), $this->getAttributes());
                $this->_nbElements++;
            }
        }

        $this->_setOptions();
    }

    /**
     * Sets the options for each select element
     *
     * @access    private
     */
    function _setOptions()
    {
        $arrayKeys = [];
        foreach (array_keys($this->_elements) AS $key) {
            if (isset($this->_options[$key])) {
                if ((empty($arrayKeys)) || HTML_QuickForm_utils::recursiveIsset($this->_options[$key], $arrayKeys)) {
                    $array = empty($arrayKeys) ? $this->_options[$key] : HTML_QuickForm_utils::recursiveValue($this->_options[$key], $arrayKeys);
                    if (is_array($array)) {
                        $select =& $this->_elements[$key];
                        $select->_options = array();
                        $select->loadArray($array);

                        $value = is_array($v = $select->getValue()) ? $v[0] : key($array);
                        $arrayKeys[] = $value;
                    }
                }
            }
        }
    }

    /**
     * Sets values for group's elements
     *
     * @param     array     $value    An array of 2 or more values, for the first,
     *                                the second, the third etc. select
     */
    public function setValue($value)
    {
        // fix for bug #6766. Hope this doesn't break anything more
        // after bug #7961. Forgot that _nbElements was used in
        // _createElements() called in several places...
        $this->_nbElements = max($this->_nbElements, count($value));
        parent::setValue($value);
        $this->_setOptions();
    }

    /**
     * Creates all the elements for the group
     *
     * @access    private
     */
    function _createElements()
    {
        for ($i = 0; $i < $this->_nbElements; $i++) {
            $this->_elements[] = new HTML_QuickForm_select($i, null, array(), $this->getAttributes());
        }
    }

    function toHtml()
    {
        $this->_js = '';
        if (!$this->_flagFrozen) {
            // set the onchange attribute for each element except last
            $keys     = array_keys($this->_elements);
            $onChange = array();
            for ($i = 0; $i < count($keys) - 1; $i++) {
                $select =& $this->_elements[$keys[$i]];
                $onChange[$i] = $select->getAttribute('onchange');
                $select->updateAttributes(
                    array('onchange' => '_hs_swapOptions(this.form, \'' . $this->_escapeString($this->getName()) . '\', ' . $keys[$i] . ');' . $onChange[$i])
                );
            }

            // create the js function to call
            if (!defined('HTML_QUICKFORM_HIERSELECT_EXISTS')) {
                $this->_js .= <<<JAVASCRIPT
function _hs_findOptions(ary, keys)
{
    if (ary == undefined) {
        return {};
    }
    var key = keys.shift();
    if (!key in ary) {
        return {};
    } else if (0 == keys.length) {
        return ary[key];
    } else {
        return _hs_findOptions(ary[key], keys);
    }
}

function _hs_findSelect(form, groupName, selectIndex)
{
    if (groupName+'['+ selectIndex +']' in form) {
        return form[groupName+'['+ selectIndex +']'];
    } else {
        return form[groupName+'['+ selectIndex +'][]'];
    }
}

function _hs_unescapeEntities(str)
{
    var div = document.createElement('div');
    div.innerHTML = str;
    return div.childNodes[0] ? div.childNodes[0].nodeValue : '';
}

function _hs_replaceOptions(ctl, options)
{
    var j = 0;
    ctl.options.length = 0;
    for (var i = 0; i < options.values.length; i++) {
        ctl.options[i] = new Option(
            (-1 == String(options.texts[i]).indexOf('&'))? options.texts[i]: _hs_unescapeEntities(options.texts[i]),
            options.values[i], false, false
        );
    }
}

function _hs_setValue(ctl, value)
{
    var testValue = {};
    if (value instanceof Array) {
        for (var i = 0; i < value.length; i++) {
            testValue[value[i]] = true;
        }
    } else {
        testValue[value] = true;
    }
    for (var i = 0; i < ctl.options.length; i++) {
        if (ctl.options[i].value in testValue) {
            ctl.options[i].selected = true;
        }
    }
}

function _hs_swapOptions(form, groupName, selectIndex)
{
    var hsValue = [];
    for (var i = 0; i <= selectIndex; i++) {
        hsValue[i] = _hs_findSelect(form, groupName, i).value;
    }

    _hs_replaceOptions(_hs_findSelect(form, groupName, selectIndex + 1),
                       _hs_findOptions(_hs_options[groupName][selectIndex], hsValue));
    if (selectIndex + 1 < _hs_options[groupName].length) {
        _hs_swapOptions(form, groupName, selectIndex + 1);
    }
}

function _hs_onReset(form, groupNames)
{
    for (var i = 0; i < groupNames.length; i++) {
        try {
            for (var j = 0; j <= _hs_options[groupNames[i]].length; j++) {
                _hs_setValue(_hs_findSelect(form, groupNames[i], j), _hs_defaults[groupNames[i]][j]);
                if (j < _hs_options[groupNames[i]].length) {
                    _hs_replaceOptions(_hs_findSelect(form, groupNames[i], j + 1),
                                       _hs_findOptions(_hs_options[groupNames[i]][j], _hs_defaults[groupNames[i]].slice(0, j + 1)));
                }
            }
        } catch (e) {
            if (!(e instanceof TypeError)) {
                throw e;
            }
        }
    }
}

function _hs_setupOnReset(form, groupNames)
{
    setTimeout(function() { _hs_onReset(form, groupNames); }, 25);
}

function _hs_onReload()
{
    var ctl;
    for (var i = 0; i < document.forms.length; i++) {
        for (var j in _hs_defaults) {
            if (ctl = _hs_findSelect(document.forms[i], j, 0)) {
                for (var k = 0; k < _hs_defaults[j].length; k++) {
                    _hs_setValue(_hs_findSelect(document.forms[i], j, k), _hs_defaults[j][k]);
                }
            }
        }
    }

    if (_hs_prevOnload) {
        _hs_prevOnload();
    }
}

var _hs_prevOnload = null;
if (window.onload) {
    _hs_prevOnload = window.onload;
}
window.onload = _hs_onReload;

var _hs_options = {};
var _hs_defaults = {};

JAVASCRIPT;
                define('HTML_QUICKFORM_HIERSELECT_EXISTS', true);
            }
            // option lists
            $jsParts = array();
            for ($i = 1; $i < $this->_nbElements; $i++) {
                $jsParts[] = $this->_convertArrayToJavascript($this->_prepareOptions($this->_options[$i], $i));
            }
            $this->_js .= "\n_hs_options['" . $this->_escapeString($this->getName()) . "'] = [\n" .
                          implode(",\n", $jsParts) .
                          "\n];\n";
            // default value; if we don't actually have any values yet just use
            // the first option (for single selects) or empty array (for multiple)
            $values = array();
            foreach (array_keys($this->_elements) as $key) {
                if (is_array($v = $this->_elements[$key]->getValue())) {
                    $values[] = count($v) > 1? $v: $v[0];
                } else {
                    // XXX: accessing the supposedly private _options array
                    $values[] = $this->_elements[$key]->getMultiple() || empty($this->_elements[$key]->_options[0])?
                                array():
                                $this->_elements[$key]->_options[0]['attr']['value'];
                }
            }
            $this->_js .= "_hs_defaults['" . $this->_escapeString($this->getName()) . "'] = " .
                          $this->_convertArrayToJavascript($values) . ";\n";
        }
        $renderer = new HTML_QuickForm_Renderer_Default();
        $renderer->setElementTemplate('{element}');
        parent::accept($renderer);

        if (!empty($onChange)) {
            $keys     = array_keys($this->_elements);
            for ($i = 0; $i < count($keys) - 1; $i++) {
                $this->_elements[$keys[$i]]->updateAttributes(array('onchange' => $onChange[$i]));
            }
        }
        return (empty($this->_js)? '': "<script type=\"text/javascript\">\n//<![CDATA[\n" . $this->_js . "//]]>\n</script>") .
               $renderer->toHtml();
    }

    public function accept(HTML_QuickForm_Renderer &$renderer, $required = false, $error = null)
    {
        $renderer->renderElement($this, $required, $error);
    }

    function onQuickFormEvent($event, $arg, &$caller)
    {
        if ('updateValue' == $event) {
            // we need to call setValue() so that the secondary option
            // matches the main option
            return HTML_QuickForm_element::onQuickFormEvent($event, $arg, $caller);
        } else {
            $ret = parent::onQuickFormEvent($event, $arg, $caller);
            // add onreset handler to form to properly reset hierselect (see bug #2970)
            if ('addElement' == $event) {
                $onReset = $caller->getAttribute('onreset');
                if (strlen($onReset)) {
                    if (strpos($onReset, '_hs_setupOnReset')) {
                        $caller->updateAttributes(array('onreset' => str_replace('_hs_setupOnReset(this, [', "_hs_setupOnReset(this, ['" . $this->_escapeString($this->getName()) . "', ", $onReset)));
                    } else {
                        $caller->updateAttributes(array('onreset' => "var temp = function() { {$onReset} } ; if (!temp()) { return false; } ; if (typeof _hs_setupOnReset != 'undefined') { return _hs_setupOnReset(this, ['" . $this->_escapeString($this->getName()) . "']); } "));
                    }
                } else {
                    $caller->updateAttributes(array('onreset' => "if (typeof _hs_setupOnReset != 'undefined') { return _hs_setupOnReset(this, ['" . $this->_escapeString($this->getName()) . "']); } "));
                }
            }
            return $ret;
        }
    }

   /**
    * Prepares options for JS encoding
    *
    * We need to preserve order of options when adding them via javascript, so
    * cannot use object literal and for/in loop (see bug #16603). Therefore we
    * convert an associative array of options to two arrays of their values
    * and texts. Backport from HTML_QuickForm2.
    *
    * @param    array   Options array
    * @param    int     Depth within options array
    * @link     http://pear.php.net/bugs/bug.php?id=16603
    * @return   array
    * @access   private
    */
    function _prepareOptions($ary, $depth)
    {
        if (!is_array($ary)) {
            $ret = $ary;
        } elseif (0 == $depth) {
            $ret = array('values' => array_keys($ary), 'texts' => array_values($ary));
        } else {
            $ret = array();
            foreach ($ary as $k => $v) {
                $ret[$k] = $this->_prepareOptions($v, $depth - 1);
            }
        }
        return $ret;
    }

   /**
    * Converts PHP array to its Javascript analog
    *
    * @access private
    * @param  array     PHP array to convert
    * @return string    Javascript representation of the value
    */
    function _convertArrayToJavascript($array)
    {
        if (!is_array($array)) {
            return $this->_convertScalarToJavascript($array);
        } elseif (count($array) && array_keys($array) != range(0, count($array) - 1)) {
            return '{' . implode(',', array_map(
                array($this, '_encodeNameValue'),
                array_keys($array), array_values($array)
            )) . '}';
        } else {
            return '[' . implode(',', array_map(
                array($this, '_convertArrayToJavascript'),
                $array
            )) . ']';
        }
    }

   /**
    * Callback for array_map used to generate JS name-value pairs
    *
    * @param    mixed
    * @param    mixed
    * @return   string
    */
    function _encodeNameValue($name, $value)
    {
        return $this->_convertScalarToJavascript((string)$name) . ':'
               . $this->_convertArrayToJavascript($value);
    }

   /**
    * Converts PHP's scalar value to its Javascript analog
    *
    * @access private
    * @param  mixed     PHP value to convert
    * @return string    Javascript representation of the value
    */
    function _convertScalarToJavascript($val)
    {
        if (is_bool($val)) {
            return $val ? 'true' : 'false';
        } elseif (is_int($val) || is_double($val)) {
            return $val;
        } elseif (is_string($val)) {
            return "'" . $this->_escapeString($val) . "'";
        } elseif (is_null($val)) {
            return 'null';
        } else {
            // don't bother
            return '{}';
        }
    }

   /**
    * Quotes the string so that it can be used in Javascript string constants
    *
    * @access private
    * @param  string
    * @return string
    */
    function _escapeString($str)
    {
        return strtr($str,array(
            "\r"    => '\r',
            "\n"    => '\n',
            "\t"    => '\t',
            "'"     => "\\'",
            '"'     => '\"',
            '\\'    => '\\\\'
        ));
    }
}
