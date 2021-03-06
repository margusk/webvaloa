<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:php="http://php.net/xsl">

    <xsl:template match="index">
        <h1>
            <button class="btn btn-default pull-right" data-toggle="modal" data-target="#add-category">
                <span class="glyphicon glyphicon-plus"></span>&#160;
                <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','ADD_CATEGORY')"/>
            </button>

            <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','CATEGORIES')"/>
        </h1>
        <hr/>

        <form method="get" action="{/page/common/basepath}/content_category">
            <div class="row">
                <div class="col-lg-9">

                </div>
                <div class="col-lg-3">
                    <div class="input-group webvaloa-search-form">
                        <input type="text" value="{search}" name="search" class="form-control" id="search" placeholder="{php:function('\Webvaloa\Webvaloa::translate','SEARCH')}" />
                        <span class="input-group-btn">
                            <button class="btn btn-default" type="submit">
                                <i class="fa fa-search"></i>
                            </button>
                        </span>
                    </div>
                </div>
            </div>
        </form>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th style="width: 1%">
                        
                    </th>
                    <th>
                        <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','ID')"/>
                    </th>
                    <th>
                        <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','NAME')"/>
                    </th>
                    <th> </th>
                </tr>
            </thead>
            <tbody>
                <xsl:if test="categories != ''">
                    <xsl:for-each select="categories">
                        <tr>
                            <td>
                                <a href="{/page/common/basehref}/content_category/toggle/{id}" class="favorite-toggle">
                                    <xsl:choose>
                                        <xsl:when test="starred = '1'">
                                            <i class="fa fa-star"></i>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <i class="fa fa-star-o"></i>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </a>
                            </td>
                            <td>
                                <xsl:value-of select="id"/>
                            </td>
                            <td>
                                <xsl:if test="published = '0'">
                                    <xsl:attribute name="class">text-muted</xsl:attribute>
                                </xsl:if>
                                <span class="label label-default">
                                    <xsl:value-of select="article_count"/>
                                </span>&#160;
                                <xsl:value-of select="category"/>
                            </td>
                            <td class="footable-last-column">
                                <div class="btn-group">
                                    <a href="{/page/common/basepath}/content_article/add/{id}" class="btn btn-default">
                                        <span class="glyphicon glyphicon-plus"></span>&#160;
                                        <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','ADD_ARTICLE')"/>
                                    </a>

                                    <a href="{/page/common/basepath}/content_article/1/{id}" class="btn btn-default">
                                        <span class="glyphicon glyphicon-list-alt"></span>&#160;
                                        <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','LIST_ARTICLES')"/>
                                    </a>

                                    <button class="btn btn-default edit-category" data-category-id="{id}" data-category-name="{category}" data-toggle="modal" data-target="#edit-category">
                                        <xsl:if test="category = 'Uncategorized'">  
                                            <xsl:attribute name="href">javascript:;</xsl:attribute>
                                            <xsl:attribute name="disabled">disabled</xsl:attribute>
                                        </xsl:if>
                                        <span class="glyphicon glyphicon-pencil"></span>&#160;
                                        <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','EDIT')"/>
                                    </button>

                                    <a class="btn btn-danger confirm" data-message="{php:function('\Webvaloa\Webvaloa::translate','ARE_YOU_SURE')}">
                                        <xsl:choose>
                                            <xsl:when test="category = 'Uncategorized'">  
                                                <xsl:attribute name="href">javascript:;</xsl:attribute>
                                                <xsl:attribute name="disabled">disabled</xsl:attribute>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="href">
                                                    <xsl:value-of select="/page/common/basepath"/>/content_category/delete/<xsl:value-of select="id"/>?token=<xsl:value-of select="../token"/>
                                                </xsl:attribute>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <span class="glyphicon glyphicon-remove"></span>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </xsl:for-each>
                </xsl:if>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="4">
                        <xsl:call-template name="pagination">
                            <xsl:with-param name="url">
                                <xsl:value-of select="/page/common/basepath"/>
                                <xsl:value-of select="pages/url"/>
                            </xsl:with-param>
                            <xsl:with-param name="pageCurrent">
                                <xsl:value-of select="pages/page"/>
                            </xsl:with-param>
                            <xsl:with-param name="pageNext">
                                <xsl:value-of select="pages/pageNext"/>
                            </xsl:with-param>
                            <xsl:with-param name="pagePrev">
                                <xsl:value-of select="pages/pagePrev"/>
                            </xsl:with-param>
                            <xsl:with-param name="pageCount">
                                <xsl:value-of select="pages/pages"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </td>
                </tr>
            </tfoot>
        </table>

        <div class="modal fade" id="add-category" tabindex="-1" role="dialog" aria-labelledby="add-category-label" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&#215;</button>
                        <h4 class="modal-title" id="add-user-label">
                            <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','ADD_CATEGORY')"/>
                        </h4>
                    </div>
                    <div class="">
                        <form method="post" action="{/page/common/basepath}/content_category/add" accept-charset="{/page/common/encoding}">

                            <div class="modal-body">

                                <div class="form-group input-group-lg">
                                    <label for="inputCategory">
                                        <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','CATEGORY')" />
                                    </label>
                                    <input type="text" name="category" class="form-control" id="inputCategory" placeholder="{php:function('\Webvaloa\Webvaloa::translate','CATEGORY')}" value="{category}" required="required" />
                                </div>

                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default" data-dismiss="modal">
                                    <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','CLOSE')"/>
                                </button>
                                <button type="submit" class="btn btn-success" id="add-user-button">
                                    <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','ADD')"/>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="edit-category" tabindex="-1" role="dialog" aria-labelledby="edit-category-label" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&#215;</button>
                        <h4 class="modal-title" id="edit-user-label">
                            <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','EDIT_CATEGORY')"/>
                        </h4>
                    </div>
                    <div class="">
                        <form method="post" action="{/page/common/basepath}/content_category/edit" accept-charset="{/page/common/encoding}">
                            <input type="hidden" name="category_id" id="category_id" />
                            <div class="modal-body">
                                <div class="form-group input-group-lg">
                                    <label for="inputCategory">
                                        <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','CATEGORY')" />
                                    </label>
                                    <input type="text" name="category" class="form-control" id="inputCategoryEdit" placeholder="{php:function('\Webvaloa\Webvaloa::translate','CATEGORY')}" value="{category}" required="required" />
                                </div>

                                <div id="layout-overrides"/>
                            </div>

                            <div class="modal-footer">
                                <button type="button" class="btn btn-default" data-dismiss="modal">
                                    <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','CLOSE')"/>
                                </button>
                                <button type="submit" class="btn btn-success" id="add-user-button">
                                    <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','SAVE')"/>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="hide" id="token">
            <xsl:value-of select="token"/>
        </div>
        <div class="hide" id="basehref">
            <xsl:value-of select="/page/common/basehref"/>
        </div>
    </xsl:template>      

    <xsl:template match="layouts">
        <div class="form-group input-group-lg">
            <label for="inputOverrideList1">
                <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','OVERRIDE_TEMPLATE')" />
            </label>

            <select name="override_template" id="inputOverrideList1" class="form-control">
                <option value=""></option>
                <xsl:for-each select="templateOverrides">
                    <option value="{template}">
                        <xsl:if test="selected">
                            <xsl:attribute name="selected">selected</xsl:attribute>
                        </xsl:if>

                        <xsl:value-of select="template" />
                    </option>
                </xsl:for-each>
            </select>
        </div>
        
        <div class="form-group input-group-lg">
            <label for="inputOverride2">
                <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','OVERRIDE')" />
            </label>

            <select name="override" id="inputOverride2" class="form-control">
                <option value=""></option>
                <xsl:for-each select="overrides">
                    <option value="{template}">
                        <xsl:if test="selected">
                            <xsl:attribute name="selected">selected</xsl:attribute>
                        </xsl:if>

                        <xsl:value-of select="template" />
                    </option>
                </xsl:for-each>
            </select>
        </div>

        <div class="form-group input-group-lg">
            <label for="inputOverrideList3">
                <xsl:value-of select="php:function('\Webvaloa\Webvaloa::translate','OVERRIDE_LIST')" />
            </label>

            <select name="override_list" id="inputOverrideList3" class="form-control">
                <option value=""></option>
                <xsl:for-each select="listOverrides">
                    <option value="{template}">
                        <xsl:if test="selected">
                            <xsl:attribute name="selected">selected</xsl:attribute>
                        </xsl:if>

                        <xsl:value-of select="template" />
                    </option>
                </xsl:for-each>
            </select>
        </div>
    </xsl:template>

</xsl:stylesheet>
