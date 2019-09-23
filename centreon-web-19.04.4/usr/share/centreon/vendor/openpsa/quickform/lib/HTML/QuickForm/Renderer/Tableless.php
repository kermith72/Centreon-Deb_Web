<?php
/**
 * Replacement for the default renderer of HTML_QuickForm that uses only XHTML
 * and CSS but no table tags, and generates fully valid XHTML output
 *
 * PHP versions 5
 *
 * LICENSE:
 *
 * Copyright (c) 2005-2007, Mark Wiesemann <wiesemann@php.net>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    * The names of the authors may not be used to endorse or promote products
 *      derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @package    HTML_QuickForm
 * @author     Alexey Borzov <borz_off@cs.msu.su>
 * @author     Adam Daniel <adaniel1@eesus.jnj.com>
 * @author     Bertrand Mansion <bmansion@mamasam.com>
 * @author     Mark Wiesemann <wiesemann@php.net>
 * @license    http://www.opensource.org/licenses/bsd-license.php New BSD License
 */

/**
 * Replacement for the default renderer of HTML_QuickForm that uses only XHTML
 * and CSS but no table tags, and generates fully valid XHTML output
 *
 * @package    HTML_QuickForm
 * @author     Alexey Borzov <borz_off@cs.msu.su>
 * @author     Adam Daniel <adaniel1@eesus.jnj.com>
 * @author     Bertrand Mansion <bmansion@mamasam.com>
 * @author     Mark Wiesemann <wiesemann@php.net>
 */
class HTML_QuickForm_Renderer_Tableless extends HTML_QuickForm_Renderer_Default
{
    /**
     * Header Template string
     * @var      string
     * @access   private
     */
    var $_headerTemplate = "\n\t\t<legend>{header}</legend>\n\t\t<ol>";

    /**
     * Element template string
     * @var      string
     * @access   private
     */
    var $_elementTemplate =
        "\n\t\t\t<li><label class=\"element\"><!-- BEGIN required --><span class=\"required\">*</span><!-- END required -->{label}</label><div class=\"element<!-- BEGIN error --> error<!-- END error -->\"><!-- BEGIN error --><span class=\"error\">{error}</span><br /><!-- END error -->{element}</div></li>";

    /**
     * Form template string
     * @var      string
     * @access   private
     */
    var $_formTemplate =
        "\n<form{attributes}>\n\t<div style=\"display: none;\">\n{hidden}\t</div>\n{content}\n</form>";

    /**
     * Template used when opening a fieldset
     * @var      string
     * @access   private
     */
    var $_openFieldsetTemplate = "\n\t<fieldset{id}{attributes}>";

    /**
     * Template used when opening a hidden fieldset
     * (i.e. a fieldset that is opened when there is no header element)
     * @var      string
     * @access   private
     */
    var $_openHiddenFieldsetTemplate = "\n\t<fieldset class=\"hidden{class}\">\n\t\t<ol>";

    /**
     * Template used when closing a fieldset
     * @var      string
     * @access   private
     */
    var $_closeFieldsetTemplate = "\n\t\t</ol>\n\t</fieldset>";

    /**
     * Required Note template string
     * @var      string
     * @access   private
     */
    var $_requiredNoteTemplate =
        "\n\t\t\t<li class=\"reqnote\"><label class=\"element\">&nbsp;</label>{requiredNote}</li>";

    /**
     * How many fieldsets are open
     * @var      integer
     * @access   private
     */
   var $_fieldsetsOpen = 0;

    /**
     * Array of element names that indicate the end of a fieldset
     * (a new one will be opened when the next header element occurs)
     * @var      array
     * @access   private
     */
    var $_stopFieldsetElements = array();

    /**
     * Name of the currently active group
     * @var      string
     * @access   private
     */
    var $_currentGroupName = '';

    /**
     * Called when visiting a header element
     *
     * @param    object     An HTML_QuickForm_header element being visited
     */
    public function renderHeader(&$header)
    {
        $name = $header->getName();
        $id = empty($name) ? '' : ' id="' . $name . '"';
        if (!empty($name) && isset($this->_templates[$name])) {
            $header_html = str_replace('{header}', $header->toHtml(), $this->_templates[$name]);
        } else {
            $header_html = str_replace('{header}', $header->toHtml(), $this->_headerTemplate);
        }
        $attributes = $header->getAttributes();
        $strAttr = '';
        if (is_array($attributes)) {
            $charset = HTML_Common::charset();
            foreach ($attributes as $key => $value) {
                if ($key == 'name') {
                    continue;
                }
                $strAttr .= ' ' . $key . '="' . htmlspecialchars($value, ENT_COMPAT, $charset) . '"';
            }
        }
        if ($this->_fieldsetsOpen > 0) {
            $this->_html .= $this->_closeFieldsetTemplate;
            $this->_fieldsetsOpen--;
        }
        $openFieldsetTemplate = str_replace('{id}', $id, $this->_openFieldsetTemplate);
        $openFieldsetTemplate = str_replace('{attributes}',
                                            $strAttr,
                                            $openFieldsetTemplate);
        $this->_html .= $openFieldsetTemplate . $header_html;
        $this->_fieldsetsOpen++;
    }

    /**
     * Renders an element Html
     * Called when visiting an element
     *
     * @param object     An HTML_QuickForm_element object being visited
     * @param bool       Whether an element is required
     * @param string     An error message associated with an element
     */
    public function renderElement(&$element, $required, $error)
    {
        $this->_handleStopFieldsetElements($element->getName());
        if (!$this->_inGroup) {
            $html = $this->_prepareTemplate($element->getName(), $element->getLabel(), $required, $error);
            // the following lines (until the "elseif") were changed / added
            // compared to the default renderer
            $element_html = $element->toHtml();
            if (!is_null($element->getAttribute('id'))) {
                $id = $element->getAttribute('id');
            } else {
                $id = $element->getName();
            }
            if ($element->getType() != 'static' && !empty($id)) {
                $html = str_replace('<label', '<label for="' . $id . '"', $html);
                $element_html = preg_replace('/name="' . preg_quote($id) . '/',
                                             'id="' . $id . '" name="' . $id,
                                             $element_html,
                                             1);
            }
            $this->_html .= str_replace('{element}', $element_html, $html);
        } elseif (!empty($this->_groupElementTemplate)) {
            $html = str_replace('{label}', $element->getLabel(), $this->_groupElementTemplate);
            if ($required) {
                $html = str_replace('<!-- BEGIN required -->', '', $html);
                $html = str_replace('<!-- END required -->', '', $html);
            } else {
                $html = preg_replace("/([ \t\n\r]*)?<!-- BEGIN required -->(\s|\S)*<!-- END required -->([ \t\n\r]*)?/i", '', $html);
            }
            $this->_groupElements[] = str_replace('{element}', $element->toHtml(), $html);

        } else {
            $element_html = $element->toHtml();
            // add "id" attribute to first element of the group
            if (count($this->_groupElements) === 0) {
                if (!is_null($element->getAttribute('id'))) {
                    $id = $element->getAttribute('id');
                } else {
                    $id = $element->getName();
                }
                $groupId = $this->_currentGroupName;
                if ($element->getType() != 'static' && !empty($id)) {
                    $element_html = preg_replace('/name="' . preg_quote($id) . '/',
                                                 'id="' . $groupId . '" name="' . $id,
                                                 $element_html,
                                                 1);
                }
            }
            $this->_groupElements[] = $element_html;
        }
    }

    /**
     * Renders an hidden element
     * Called when visiting a hidden element
     *
     * @param object     An HTML_QuickForm_hidden object being visited
     * @param bool       Whether an element is required
     * @param string     An error message associated with an element
     */
    public function renderHidden(&$element, $required, $error)
    {
        if (!is_null($element->getAttribute('id'))) {
            $id = $element->getAttribute('id');
        } else {
            $id = $element->getName();
        }
        $html = $element->toHtml();
        if (!empty($id)) {
            $html = str_replace('name="' . $id,
                                'id="' . $id . '" name="' . $id,
                                $html);
        }
        $this->_hiddenHtml .= $html . "\n";
    }

    /**
     * Called when visiting a group, before processing any group elements
     *
     * @param object     An HTML_QuickForm_group object being visited
     * @param bool       Whether a group is required
     * @param string     An error message associated with a group
     */
    public function startGroup(&$group, $required, $error)
    {
        $this->_handleStopFieldsetElements($group->getName());
        $name = $group->getName();
        $this->_groupTemplate        = $this->_prepareTemplate($name, $group->getLabel(), $required, $error);
        $this->_groupTemplate        = str_replace('<label', '<label for="' . $name . '"', $this->_groupTemplate);
        $this->_groupElementTemplate = empty($this->_groupTemplates[$name])? '': $this->_groupTemplates[$name];
        $this->_groupWrap            = empty($this->_groupWraps[$name])? '': $this->_groupWraps[$name];
        $this->_groupElements        = array();
        $this->_inGroup              = true;
        $this->_currentGroupName     = $name;
    }

    /**
     * Called when visiting a group, after processing all group elements
     *
     * @param    object      An HTML_QuickForm_group object being visited
     */
    public function finishGroup(&$group)
    {
        $separator = $group->_separator;
        if (is_array($separator)) {
            $count = count($separator);
            $html  = '';
            for ($i = 0; $i < count($this->_groupElements); $i++) {
                $html .= (0 == $i? '': $separator[($i - 1) % $count]) . $this->_groupElements[$i];
            }
        } else {
            if (is_null($separator)) {
                $separator = '&nbsp;';
            }
            $html = implode((string)$separator, $this->_groupElements);
        }
        if (!empty($this->_groupWrap)) {
            $html = str_replace('{content}', $html, $this->_groupWrap);
        }
        if (!is_null($group->getAttribute('id'))) {
            $id = $group->getAttribute('id');
        } else {
            $id = $group->getName();
        }
        $groupTemplate = $this->_groupTemplate;

        $this->_html   .= str_replace('{element}', $html, $groupTemplate);
        $this->_inGroup = false;
    }

    /**
     * Called when visiting a form, before processing any form elements
     *
     * @param    object      An HTML_QuickForm object being visited
     */
    public function startForm(&$form)
    {
        $this->_fieldsetsOpen = 0;
        parent::startForm($form);
    }

    /**
     * Called when visiting a form, after processing all form elements
     * Adds required note, form attributes, validation javascript and form content.
     *
     * @param    object      An HTML_QuickForm object being visited
     */
    public function finishForm(&$form)
    {
        // add a required note, if one is needed
        if (!empty($form->_required) && !$form->_freezeAll) {
            $requiredNote = $form->getRequiredNote();
            // replace default required note by DOM/XHTML optimized note
            if ($requiredNote == '<span style="font-size:80%; color:#ff0000;">*</span><span style="font-size:80%;"> denotes required field</span>') {
                $requiredNote = '<span class="required">*</span> denotes required field';
            }
            $this->_html .= str_replace('{requiredNote}', $requiredNote, $this->_requiredNoteTemplate);
        }
        // close the open fieldset
        if ($this->_fieldsetsOpen > 0) {
            $this->_html .= $this->_closeFieldsetTemplate;
            $this->_fieldsetsOpen--;
        }
        // add form attributes and content
        $html = str_replace('{attributes}', $form->getAttributes(true), $this->_formTemplate);
        if (strpos($this->_formTemplate, '{hidden}')) {
            $html = str_replace('{hidden}', $this->_hiddenHtml, $html);
        } else {
            $this->_html .= $this->_hiddenHtml;
        }
        $this->_hiddenHtml = '';
        $this->_html = str_replace('{content}', $this->_html, $html);
        $this->_html = str_replace('></label>', '>&nbsp;</label>', $this->_html);
        // add a validation script
        if ('' != ($script = $form->getValidationScript())) {
            $this->_html = $script . "\n" . $this->_html;
        }
    }

    /**
     * Sets the template used when opening a fieldset
     *
     * @param       string      The HTML used when opening a fieldset
     */
    public function setOpenFieldsetTemplate($html)
    {
        $this->_openFieldsetTemplate = $html;
    }

    /**
     * Sets the template used when opening a hidden fieldset
     * (i.e. a fieldset that is opened when there is no header element)
     *
     * @param       string      The HTML used when opening a hidden fieldset
     */
    public function setOpenHiddenFieldsetTemplate($html)
    {
        $this->_openHiddenFieldsetTemplate = $html;
    }

    /**
     * Sets the template used when closing a fieldset
     *
     * @param       string      The HTML used when closing a fieldset
     */
    public function setCloseFieldsetTemplate($html)
    {
        $this->_closeFieldsetTemplate = $html;
    }

    /**
     * Adds one or more element names that indicate the end of a fieldset
     * (a new one will be opened when a the next header element occurs)
     *
     * @param       mixed      Element name(s) (as array or string)
     * @param       string     (optional) Class name for the fieldset(s)
     */
    public function addStopFieldsetElements($element, $class = '')
    {
        if (is_array($element)) {
            $elements = array();
            foreach ($element as $name) {
                $elements[$name] = $class;
            }
            $this->_stopFieldsetElements = array_merge($this->_stopFieldsetElements,
                                                       $elements);
        } else {
            $this->_stopFieldsetElements[$element] = $class;
        }
    }

    /**
     * Handle element/group names that indicate the end of a group
     *
     * @param string     The name of the element or group
     */
    private function _handleStopFieldsetElements($element)
    {
        // if the element/group name indicates the end of a fieldset, close
        // the fieldset
        if (   array_key_exists($element, $this->_stopFieldsetElements)
            && $this->_fieldsetsOpen > 0
           ) {
            $this->_html .= $this->_closeFieldsetTemplate;
            $this->_fieldsetsOpen--;
        }
        // if no fieldset was opened, we need to open a hidden one here to get
        // XHTML validity
        if ($this->_fieldsetsOpen === 0) {
            $replace = '';
            if (   array_key_exists($element, $this->_stopFieldsetElements)
                && $this->_stopFieldsetElements[$element] != ''
               ) {
                $replace = ' ' . $this->_stopFieldsetElements[$element];
            }
            $this->_html .= str_replace('{class}', $replace,
                                        $this->_openHiddenFieldsetTemplate);
            $this->_fieldsetsOpen++;
        }
    }

    /**
     * Sets element template
     *
     * @param   string    The HTML surrounding an element
     * @param   mixed     (optional) Name(s) of the element to apply template
     *                    for (either single element name as string or multiple
     *                    element names as an array)
     */
    public function setElementTemplate($html, $element = null)
    {
        if (is_null($element)) {
            $this->_elementTemplate = $html;
        } elseif (is_array($element)) {
            foreach ($element as $name) {
                $this->_templates[$name] = $html;
            }
        } else {
            $this->_templates[$element] = $html;
        }
    }

}
?>