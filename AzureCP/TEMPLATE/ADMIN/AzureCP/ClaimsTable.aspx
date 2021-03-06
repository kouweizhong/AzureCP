﻿<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ClaimsTable.aspx.cs" Inherits="azurecp.ClaimsTablePage" MasterPageFile="~/_admin/admin.master" %>

<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>

<asp:Content ID="PageHead" ContentPlaceHolderID="PlaceHolderAdditionalPageHead" runat="server">
    <script type="text/javascript" src="/_layouts/15/azurecp/jquery-1.9.1.min.js"></script>
    <style type="text/css">
        #divTblClaims th a:link {
            color: white;
            text-decoration: underline;
        }

        #divTblClaims th a:visited {
            color: white;
        }

        .ms-error {
            margin-bottom: 10px;
            display: block;
        }

        .ms-inputformcontrols {
            width: 500px;
        }

        .azurecp-rowidentityclaim {
            font-weight: bold;
            color: green;
        }

        .azurecp-rowClaimTypeNotUsedInTrust {
            color: red;
            font-style: italic;
        }

        .azurecp-rowClaimTypeOk {
            color: green;
        }

        .azurecp-rowRoleClaimType {
            color: #0072c6;
        }

        #divNewItem label {
            display: inline-block;
            line-height: 1.8;
            vertical-align: top;
            width: 250px;
        }

        #divNewItem fieldset {
            border: 0;
        }

            #divNewItem fieldset ol {
                margin: 0;
                padding: 0;
            }

            #divNewItem fieldset li {
                list-style: none;
                padding: 5px;
                margin: 0;
            }

        #divNewItem em {
            font-weight: bold;
            font-style: normal;
            color: #f00;
        }

        #divNewItem div label {
            width: 700px;
        }

        .divbuttons input {
            margin: 10px;
        }

        #divTblClaims table, #divTblClaims th, #divTblClaims td {
            border: 1px solid black;
            padding: 4px;
            border-collapse: collapse;
            word-wrap: normal;
        }

        #divTblClaims th {
            background-color: #0072c6;
            color: #fff;
        }

        #divBtnsFullScreenMode {
            margin-bottom: 10px;
        }

        #divLegend {
            margin-top: 10px;
        }

            #divLegend fieldset {
                border: 0;
            }

                #divLegend fieldset ol {
                    margin: 0 0 0 5px;
                    padding: 0;
                }

                #divLegend fieldset li {
                    list-style: none;
                    padding: 5px;
                }
    </style>
</asp:Content>
<asp:Content ID="Main" ContentPlaceHolderID="PlaceHolderMain" runat="server">
    <script type="text/javascript">
        // Builds unique namespace
        window.Azurecp = window.Azurecp || {};
        window.Azurecp.ClaimsTablePage = window.Azurecp.ClaimsTablePage || {};
        
        // Hide labels and show input controls
        window.Azurecp.ClaimsTablePage.EditItem = function (ItemId) {
            $('#span_claimtype_' + ItemId).hide('fast');
            $('#span_graphproperty_' + ItemId).hide('fast');
            $('#span_GraphPropertyToDisplay_' + ItemId).hide('fast');
            $('#span_Metadata_' + ItemId).hide('fast');
            $('#span_ClaimEntityType_' + ItemId).hide('fast');
            $('#span_PrefixToBypassLookup_' + ItemId).hide('fast');
            $('#editLink_' + ItemId).hide('fast');
            $('#<%= DeleteItemLink_.ClientID %>' + ItemId).hide('fast');

            $('#input_claimtype_' + ItemId).show('fast');
            $('#list_graphproperty_' + ItemId).show('fast');
            $('#list_GraphPropertyToDisplay_' + ItemId).show('fast');
            $('#list_Metadata_' + ItemId).show('fast');
            $('#list_ClaimEntityType_' + ItemId).show('fast');
            $('#input_PrefixToBypassLookup_' + ItemId).show('fast');
            $('#<%= UpdateItemLink_.ClientID %>' + ItemId).show('fast');
            $('#cancelLink_' + ItemId).show('fast');
        }
		
        // Show labels and hide input controls
        window.Azurecp.ClaimsTablePage.CancelEditItem = function (ItemId) {
            $('#span_claimtype_' + ItemId).show('fast');
            $('#span_graphproperty_' + ItemId).show('fast');
            $('#span_GraphPropertyToDisplay_' + ItemId).show('fast');
            $('#span_Metadata_' + ItemId).show('fast');
            $('#span_ClaimEntityType_' + ItemId).show('fast');
            $('#span_PrefixToBypassLookup_' + ItemId).show('fast');
            $('#editLink_' + ItemId).show('fast');
            $('#<%= DeleteItemLink_.ClientID %>' + ItemId).show('fast');

            $('#input_claimtype_' + ItemId).hide('fast');
            $('#list_graphproperty_' + ItemId).hide('fast');
            $('#list_GraphPropertyToDisplay_' + ItemId).hide('fast');
            $('#list_Metadata_' + ItemId).hide('fast');
            $('#list_ClaimEntityType_' + ItemId).hide('fast');
            $('#input_PrefixToBypassLookup_' + ItemId).hide('fast');
            $('#<%= UpdateItemLink_.ClientID %>' + ItemId).hide('fast');
            $('#cancelLink_' + ItemId).hide('fast');
        }
		
        //$(document).ready(function () {
        //});
		
        // Register initialization method to run when DOM is ready and most SP JS functions loaded
        _spBodyOnLoadFunctionNames.push("window.Azurecp.ClaimsTablePage.Init");
		
        window.Azurecp.ClaimsTablePage.Init = function () {
            // Variables initialized from server side code
            window.Azurecp.ClaimsTablePage.ShowNewItemForm = <%= ShowNewItemForm.ToString().ToLower() %>;
            window.Azurecp.ClaimsTablePage.HideAllContent = <%= HideAllContent.ToString().ToLower() %>;
            window.Azurecp.ClaimsTablePage.TrustName = "<%= TrustName.ToString().ToLower() %>";

            // Check if all content should be hidden (most probably because AzureCP is not associated with any SPTrustedLoginProvider)
            if (window.Azurecp.ClaimsTablePage.HideAllContent) {
                $('#divMainContent').hide(); 
                return;
            }
			
            // Replace placeholder with actual SPTrustedIdentityTokenIssuer name
            $('#divMainContent').find("span").each(function(ev)
            {
                $(this).text($(this).text().replace("{trustname}", window.Azurecp.ClaimsTablePage.TrustName));
            });

            // ONLY FOR SP 2013
            // Display only current page in full screen mode
            window.Azurecp.ClaimsTablePage.SetFullScreenModeInCurPageOnly();
			
            // Initialize display
            var rdbGroupName= $('#<%= RdbNewItemClassicClaimType.ClientID %>').attr('name');
            if (Azurecp.ClaimsTablePage.ShowNewItemForm)
            {
                $('#divTblClaims').hide('fast'); 
                $('#divNewItem').show('fast');
				
                var id = $("input[name='"+rdbGroupName+"']:checked").attr('id');
                $('#'+id).trigger('click');
            }
            else
            {
                $("input[name='"+rdbGroupName+"']:checked").removeAttr('checked');
            }
        }
		
        // Display only current page in full screen mode
        window.Azurecp.ClaimsTablePage.SetFullScreenModeInCurPageOnly = function () {
            // Remove call to OOB InitFullScreenMode function. If not removed, it will disable full screen mode just after because it will not find cookie WSS_FullScreenMode
            _spBodyOnLoadFunctions.pop("InitFullScreenMode");
			
            // Copied from OOB SetFullScreenMode method (SP 2013 SP1 15.0.4569.1000)
            var bodyElement = document.body;
            var fsmButtonElement = document.getElementById('fullscreenmode');
            var efsmButtonElement = document.getElementById('exitfullscreenmode');
            AddCssClassToElement(bodyElement, "ms-fullscreenmode");
            if (fsmButtonElement != null && efsmButtonElement != null) {
                fsmButtonElement.style.display = 'none';
                efsmButtonElement.style.display = '';
            }
            if ('undefined' != typeof document.createEvent && 'function' == typeof window.dispatchEvent) {
                var evt = document.createEvent("Event");

                evt.initEvent("resize", false, false);
                window.dispatchEvent(evt);
            }
            else if ('undefined' != typeof document.createEventObject) {
                document.body.fireEvent('onresize');
            }
            CallWorkspaceResizedEventHandlers();
			
            PreventDefaultNavigation();
        }
    </script>
    <table width="100%" class="propertysheet" cellspacing="0" cellpadding="0" border="0">
        <tr>
            <td class="ms-descriptionText">
                <asp:Label ID="LabelMessage" runat="server" EnableViewState="False" class="ms-descriptionText" />
            </td>
        </tr>
        <tr>
            <td class="ms-error">
                <asp:Label ID="LabelErrorMessage" runat="server" EnableViewState="False" />
            </td>
        </tr>
        <tr>
            <td class="ms-descriptionText">
                <asp:ValidationSummary ID="ValSummary" HeaderText="<%$SPHtmlEncodedResources:spadmin, ValidationSummaryHeaderText%>"
                    DisplayMode="BulletList" ShowSummary="True" runat="server"></asp:ValidationSummary>
            </td>
        </tr>
    </table>
    <div id="divMainContent">
        <asp:LinkButton ID="DeleteItemLink_" runat="server" Visible="false"></asp:LinkButton>
        <asp:LinkButton ID="UpdateItemLink_" runat="server" Visible="false"></asp:LinkButton>
        <div id="divBtnsFullScreenMode">
            <input type="button" value="Quit page" onclick="location.href='/';" class="ms-ButtonHeightWidth" />
            <input id="btnDisableFullScreenMode" type="button" value="Show navigation" onclick="SetFullScreenMode(false);PreventDefaultNavigation(); $('#btnDisableFullScreenMode').hide(); $('#btnEnableFullScreenMode').show(); return false;" class="ms-ButtonHeightWidth" />
            <input id="btnEnableFullScreenMode" type="button" value="Maximize content" onclick="window.Azurecp.ClaimsTablePage.SetFullScreenModeInCurPageOnly(); $('#btnEnableFullScreenMode').hide(); $('#btnDisableFullScreenMode').show(); return false;" style="display: none;" class="ms-ButtonHeightWidth" />
        </div>
        <div id="divTblClaims">
            <span style="display: block; margin-bottom: 10px;">This table is used by AzureCP to link claim types with Azure objects. Claim types should match those set in SPTrustedIdentityTokenIssuer &quot;{trustname}&quot;.</span>
            <asp:Table ID="TblClaimsMapping" runat="server"></asp:Table>
            <div id="divLegend">
                <fieldset>
                    <legend>Color legend:</legend>
                    <ol>
                        <li><span class="azurecp-rowidentityclaim">This color</span><span> shows the identity claim type set in SPTrust {trustname}. It must always be present and unique, otherwise AzureCP won&#39;t work.</span></li>
                        <li><span class="azurecp-rowClaimTypeOk">This color</span><span> shows a claim type set in SPTrust {trustname}.</span></li>
                        <li><span class="azurecp-rowClaimTypeNotUsedInTrust">This color</span><span> shows a claim type missing in SPTrust {trustname}, thus it won&#39;t be used by AzureCP.</span></li>
                        <li><span class="azurecp-rowRoleClaimType">This color</span><span> shows role claim type set in SPTrust {trustname}. There must be only 1 and AzureCP can use it to augment SAML token of user with his group membership. Augmentation can be disabled in global settings page.</span></li>
                        <li><span>This color shows an optional entry.</span></li>
                    </ol>
                </fieldset>
            </div>
            <div class="divbuttons">
                <input type="button" value="New item" onclick="$('#divTblClaims').hide('fast'); $('#divNewItem').show('fast');" />
                <asp:Button ID="BtnReset" runat="server" Text="Reset" OnClick="BtnReset_Click" OnClientClick="javascript:return confirm('This will reset table to default mapping. Do you want to continue?');" />
            </div>
        </div>
        <div id="divNewItem" style="display: none;">
            <fieldset>
                <legend><b>Add a new item to the list</b></legend>
                <ol>
                    <li>
                        <label>Select which type of entry to create: <em>*</em></label>
                        <div>
                            <asp:RadioButton ID="RdbNewItemClassicClaimType" runat="server" GroupName="RdgGroupNewItem" Text="Query Azure AD with specified property and create permission with specified claim type" AutoPostBack="false" OnClick="$('#divNewItemControls').show('slow'); $('#rowClaimType').show('slow'); $('#rowGraphPropertyToDisplay').show('slow'); $('#emPermissionMetadata').hide('slow');" />
                        </div>
                        <div>
                            <asp:RadioButton ID="RdbNewItemLinkdedToIdClaim" runat="server" GroupName="RdgGroupNewItem" Text="Query Azure AD with specified property and create permission with the property linked to identity claim" AutoPostBack="false" OnClick="$('#divNewItemControls').show('slow'); $('#rowClaimType').hide('slow'); $('#rowGraphPropertyToDisplay').hide('slow'); $('#emPermissionMetadata').hide('slow');" />
                        </div>
                        <div>
                            <asp:RadioButton ID="RdbNewItemPermissionMetadata" runat="server" GroupName="RdgGroupNewItem" Text="Does not Azure AD with specified property, but use it as a <a href='http://msdn.microsoft.com/en-us/library/microsoft.sharepoint.webcontrols.peopleeditorentitydatakeys_members.aspx' target='_blank'>metadata</a> of the new permission" AutoPostBack="false" OnClick="$('#divNewItemControls').show('slow'); $('#rowClaimType').hide('slow'); $('#rowGraphPropertyToDisplay').hide('slow'); $('#emPermissionMetadata').show('slow');" />
                        </div>
                    </li>
					<div id="divNewItemControls" style="display: none;">
                    <li id="rowClaimType" style="display: none;">
                        <label for="<%= New_TxtClaimType.ClientID %>">Claim type: <em>*</em></label>
                        <asp:TextBox ID="New_TxtClaimType" runat="server" CssClass="ms-inputformcontrols"></asp:TextBox>
                    </li>
                    <li id="rowPermissionMetadata">
                        <label for="<%= New_DdlPermissionMetadata.ClientID %>">Type of <a href="http://msdn.microsoft.com/en-us/library/microsoft.sharepoint.webcontrols.peopleeditorentitydatakeys_members.aspx" target="_blank">permission metadata: </a><em id="emPermissionMetadata" style="display: none;">*</em></label>
                        <asp:DropDownList ID="New_DdlPermissionMetadata" runat="server" CssClass="ms-inputformcontrols"></asp:DropDownList>
                    </li>
                    <li>
                        <label for="<%= New_DdlGraphProperty.ClientID %>">Property to query: <em>*</em></label>
                        <asp:DropDownList ID="New_DdlGraphProperty" runat="server" CssClass="ms-inputformcontrols"></asp:DropDownList>
                    </li>
                    <li id="rowGraphPropertyToDisplay" style="display: none;">
                        <label for="<%= New_DdlGraphPropertyToDisplay.ClientID %>">Property to display:</label>
                        <asp:DropDownList ID="New_DdlGraphPropertyToDisplay" runat="server" CssClass="ms-inputformcontrols"></asp:DropDownList>
                    </li>
					</div>
                </ol>
                <div class="divbuttons">
                    <asp:Button ID="BtnCreateNewItem" runat="server" Text="Create" OnClick="BtnCreateNewItem_Click" />
                    <input type="button" value="Cancel" onclick="$('#divNewItem').hide('fast'); $('#divTblClaims').show('fast');" />
                </div>
            </fieldset>
        </div>
    </div>

</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PlaceHolderPageTitle" runat="server">
    Claims list
</asp:Content>
<asp:Content ID="PageTitleInTitleArea" ContentPlaceHolderID="PlaceHolderPageTitleInTitleArea"
    runat="server">
    Claims list - <a href="http://AzureCP.codeplex.com" target="_blank">AzureCP.codeplex.com</a>
</asp:Content>
