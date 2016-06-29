// release dollar sign for other libraries possible
jQuery.noConflict();
// all docusign front end logic starts from document.loaded event
jQuery(document).ready(function($) {

    console.log(dsGlobal);

/*------------------------------ Init ------------------------------*/

    // Populate all html and show it
    populateAllDocumentHTML(dsGlobal.envelope.documents);
    initRecipient();
    showEditEnvelope();
    if (dsGlobal.envelope.chatterEnabled === false) {
    	$("#add-feed-items").parent().remove();
    }
    if (dsGlobal.envelope.enableChatterUpdates === false) {
    	$("#add-libraries").parent().remove();
    }

    if(!Modernizr.svg) {
        console.log('SVG is NOT supported.');
        // Browser doesnt support SVG (eg. IE 8).  Replace all SVG with PNG.
        $('.logo').attr('src', dsGlobal.docusignPNG);
        $('#docIcon').attr('src', dsGlobal.DocumentIconPNG);
        $('#recipientIcon').attr('src', dsGlobal.RecipientIconPNG);
        $('#messageIcon').attr('src', dsGlobal.MessageIconPNG);
        $('#settingIcon').attr('src', dsGlobal.SettingIconPNG);
        $('.ds-recipient-close-icon, .ds-document-close-icon').attr('src', dsGlobal.deleteIconPNG);
        $('#ds-recipient-search-btn').css("background-image", "url("+dsGlobal.searchIconPNG+")");
        $('.docusignlogo').attr('src', dsGlobal.DocuSignLoadingLogoPNG);
    }
/*------------------------------ Helper functions ------------------------------*/

    /*
     * Hide all pages.
     */
    function hideAll() {
        hideRecipientModalLoading();
        hideFullScreenLoading();
        hideEditEnvelope();
        hideAddRecipientModal();
        hideEditRecipientModal();
        hideDocumentsModalLoading();
        hideDocumentsModal();
    }

    /*
     * Hide Recipient Modal Loading
     */
    function hideRecipientModalLoading() {
        $('.ds-edit-recipient-modal .modal .ds-edit-recipient-modal-content').css('opacity', '1.0');
        $(".modal-loading").hide();
    }

    /*
     * Show Recipient Modal Loading
     */
    function showRecipientModalLoading() {
        $('.ds-edit-recipient-modal .modal .ds-edit-recipient-modal-content').css('opacity', '0');
        $(".modal-loading").show();
    }
    
    function hideFullScreenLoading() {
    	$('.fullscreenload').hide();
    }
    
    function showFullScreenLoading() {
    	$('.fullscreenload').show();
    }
    
    /*
     *
     */
    function showDocumentModal() {
    	$('.ds-add-document-modal').show();
    }
    
    /*
     * Hide Documents Modal Dialog
     */
    function hideDocumentsModal() {
    	$(".ds-add-document-modal-content .content ").html('');
    	$("#ds_docmodal_folder_select").html('');
    	$("#ds_docmodal_header").html('');
    	$("#ds_docmodal_folder").hide();
    	$("#ds_docmodal_add_attachment").hide();
    	$('.ds-add-document-modal').hide();
    }
    
    /*
     * Show Documents Modal Loading
     */
    function showDocumentsModalLoadind() {
    	showDocumentModal();
    	$('.ds-add-document-modal .modal .ds-add-document-modal-content').css('opacity', '0');
    	$(".modal-loading").show();
    }
    
    /*
     * Hide Documents Modal Loading
     */
    function hideDocumentsModalLoading() {
    	$('.ds-add-document-modal .modal .ds-add-document-modal-content').css('opacity', '1.0');
    	$(".modal-loading").hide();
    }

    /*
     * Hide Edit Envelope
     */
    function hideEditEnvelope() {
        $("#ds-edit-envelope").hide();
    }

    /*
     * Show Edit Envelope
     */
    function showEditEnvelope() {
        hideAll();
        if (dsGlobal.envelope.messages.length > 0) {
            showErrors(dsGlobal.envelope.messages, false);
        } else {
            $("#ds-edit-envelope").show();
            if(dsGlobal.envelope.enableRecipientLanguageSelection !== true) {
                $('#message').show();
                if (dsGlobal.enableEmailSubjectEditingOverride === '0') {
                    $('#emailSubject').attr('disabled','disabled');
                } else {         
                    if(dsGlobal.envelope.enableEmailSubjectEditing !== true) {
                        $('#emailSubject').attr('disabled','disabled');
                    }
                }
                if (dsGlobal.enableEmailMessageEditingOverride === '0') {
                     $('#emailMessage').attr('disabled','disabled');
                } else {
                    if(dsGlobal.envelope.enableEmailMessageEditing !== true) {
                        $('#emailMessage').attr('disabled','disabled');
                    }
                }
            }
            if (dsGlobal.envelope.showRemindExpire === true && dsGlobal.showRemindExpireOverride !== '0') {
                $('#settings').show();
                $('#remindSignersFields').show();  
                $('#expireEnvelopeFields').show();
            }
            if (dsGlobal.envelope.chatterSettingCode !== 'Disabled' && dsGlobal.showChatterSettingOverride !== '0') {
                $('#settings').show();
                $('#enableChatterFields').show();
                if (dsGlobal.envelope.chatterSettingCode === 'EnabledAlwaysOn') {
                    $('#enableChatterUpdates').prop('disabled', true);
                }
            }
            if (dsGlobal.envelope.remindSigners === true) {
                $('#remindSigners').prop('checked', true);
                $('#reminders').show();
            } else {
                $('#reminders').hide();
            }
            if (dsGlobal.envelope.expireEnvelope === true) {
                $('#expireEnvelope').prop('checked', true);
                $('#expirations').show();
            } else {
                $('#expirations').hide();
            }
            if (dsGlobal.envelope.enableChatterUpdates === true) {
                $('#enableChatterUpdates').prop('checked', true);
            }
            if (dsGlobal.envelope.showTagButton === true && dsGlobal.showTagButtonOverride !== '0') {
                $('#nextButton').show();
            }
            if (dsGlobal.envelope.showSendNowButton === true && dsGlobal.showSendNowButtonOverride !== '0') {
                $('#sendNowButton').show();
            }
        }
    }

    $('#remindSigners').click(function() {
    	hideErrors();
        if ($('#remindSigners').prop('checked') === true) {
            $('#reminders').show();
        } else {
            $('#reminders').hide();
        }
    });
    
    $('#expireEnvelope').click(function() {
    	hideErrors();
        if ($('#expireEnvelope').prop('checked') === true) {
            $('#expirations').show();
        } else {
            $('#expirations').hide();
        }
    });
    
    $('#emailSubject').keyup(function() {
    	hideErrors();
    });
    
    $('#emailMessage').keyup(function() {
    	hideErrors();
    });

    /*
     * Hide Add Recipient Modal
     */
    function hideAddRecipientModal() {
        $(".ds-add-recipient-modal").hide();
    }

    /*
     * Hide Add Recipient Modal
     */
    function hideAddRecipientModal() {
        $(".ds-add-recipient-modal").hide();
    }

    /*
     * Show Add Recipient Modal
     */
    function showAddRecipientModal(type) {
    	hideErrors();
        console.log('showAddRecipientModal called, type='+type);
        hideAll();
        $("#ds-edit-envelope").show();
        $(".ds-add-recipient-modal").show();
        dsGlobal.currentEditingRecipientId = null;
        dsGlobal.recipientType = type;
        dsGlobal.newRecipientName = '';
        dsGlobal.newRecipientEmail = '';
        // Reset input fields
        $('#ds-recipient-search-text, #ds-recipient-signer-name').val('');
        $('#ds-recipient-search-result ul, #ds-recipient-info').html('');
        $('#ds-recipient-modal-title').text(dsGlobal.addRecipientLabel);
        $('#ds-recipient-info').show();
        $('#ds-edit-recipient-btn').hide();
        $('#ds-recipient-name').attr('class', '');
        $('#ds-change-recipient').attr('class', '');
        $('#ds-quickadd-form, #ds-recipient-signer-name-div').hide();
        $('.ds-recipient-name-error-label, .ds-recipient-email-error-label, .ds-recipient-signature-dropdown-error-label').hide();
        $('#ds-recipient-search-form').show();
        $('#ds-add-new-contact-link, #ds-add-new-contact-form').hide();
        if(type === 'add-contact') {
            $('#ds-search-recipient-modal-title').text(dsGlobal.addContactLabel);
            $('#ds-recipient-search-text').attr("placeholder", dsGlobal.searchContactsLabel);
            $('#ds-add-new-contact-link').show();
            dsGlobal.action = dsGlobal.searchContacts;
        } else if(type === 'add-lead') {
            $('#ds-search-recipient-modal-title').text(dsGlobal.addLeadLabel);
            $('#ds-recipient-search-text').attr("placeholder", dsGlobal.searchLeadsLabel);
            dsGlobal.action = dsGlobal.searchLeads;
        } else if(type === 'add-user') {
            $('#ds-search-recipient-modal-title').text(dsGlobal.addUserLabel);
            $('#ds-recipient-search-text').attr("placeholder", dsGlobal.searchUsersLabel);
            dsGlobal.action = dsGlobal.searchUsers;
        } else if(type === 'add-me') {
            dsGlobal.newRecipientName = dsGlobal.currentUserName;
            dsGlobal.newRecipientEmail = dsGlobal.currentUserEmail;
             $('#ds-recipient-modal-title').text(dsGlobal.addMeLabel);
            showEditRecipientModal();
        } else if(type === 'add-quick') {
            showEditRecipientModal();
            $('#ds-recipient-modal-title').text(dsGlobal.addRecipientLabel);
            $('#quick-add-name').val('').removeClass('error');
            $('#quick-add-email').val('').removeClass('error');
            $('#ds-quickadd-form').show();
            $('#ds-recipient-info').hide();
            $('#ds-edit-recipient-btn').hide();
        	$('#ds-recipient-name').attr('class', '');
        	$('#ds-change-recipient').attr('class', '');
        }
    }
    
    /*
     * Hide Edit Recipient Modal
     */
    function hideEditRecipientModal() {
        $(".ds-edit-recipient-modal").hide();
    }

    /*
     * Show Edit Recipient Modal
     */
    function showEditRecipientModal(recipientId) {
        hideAll();
        $("#ds-edit-envelope").show();
        $('.ds-recipient-name-error-label, .ds-recipient-email-error-label').hide();
        showRecipientModalLoading();
        $('.ds-edit-recipient-modal').show();
        $('.self-signer-option, .ds-recipient-signature-dropdown-error-label').hide();
        dsGlobal.isEditing = (typeof(recipientId) !== 'undefined' && recipientId !== null) ? true : false;
        console.log('showEditRecipientModal called, isEditing='+dsGlobal.isEditing);
        var recipient;
        var recipientName = '';
        var recipientEmail = '';
        var recipientIsCurrentUser;
    	dsGlobal.currentEditingRecipientName = '';
    	dsGlobal.currentEditingRecipient = null;
        if(dsGlobal.isEditing) {
            // Info from saved recipient
            recipient = getRecipientById(recipientId);
            console.log(recipient);
            $('#ds-recipient-modal-title').text(dsGlobal.editRecipientLabel);
            if(!dsGlobal.isChangingRecipient) {
            	recipientName = unescapeHTMLSpecialCharacters(recipient.name);
            	recipientEmail = recipient.email;
            } else {
            	recipient.signatureName = null;
            	recipientName = unescapeHTMLSpecialCharacters(dsGlobal.newRecipientName);
            	recipientEmail = dsGlobal.newRecipientEmail;
            	dsGlobal.isChangingRecipient = false;
            }
            recipientIsCurrentUser = isCurrentUser(recipientName, recipientEmail);
            $('#ds-recipient-signer-role').val(recipient.signerRole);
            $('#ds-recipient-access-code').val(recipient.accessCode);
            $('#ds-recipient-note').val(recipient.note);
            $("#ds-recipient-signertype-select").val(recipient.signerType);
            $('#ds-recipient-signer-name').val('');
            $('#ds-recipient-signer-name-div').hide();
            var signerType = (recipient.signerType) ? recipient.signerType.toLowerCase() : '';
            var recipientType = (recipient.recipientType) ? recipient.recipientType.toLowerCase() : '';
            if(signerType === 'sign in person') {
                    if(recipient.signNow !== 'true') {
                        $('#ds-recipient-signertype-select').val('Host in person');
                    } else {
                        $('#ds-recipient-signertype-select').val('Host in person - sign now');
                    }
                    $('#ds-recipient-signer-name').val(recipient.signInPersonName);
                    $('#ds-recipient-signer-name-div, .self-signer-option').show();
            } else if(recipientType === 'custom') {
                if(signerType === 'signer' && recipient.signNow === 'true') {
                    $('.self-signer-option').show();
                    $('#ds-recipient-signertype-select').val('Signer Now');
                }
            } else {
                if(recipientIsCurrentUser === true) {
                    $('.self-signer-option').show();
                    if(signerType === 'host in person' || signerType === 'host in person - sign now' || signerType === 'sign now') {
                        $('#ds-recipient-signer-name').val(recipient.signInPersonName);
                        $('#ds-recipient-signer-name-div').show();
                    }
                }
            }
            $('#ds-recipient-info').show();
            $('#ds-edit-recipient-btn').show();
        	$('#ds-recipient-name').attr('class', 'ten col no-padding');
        	$('#ds-change-recipient').attr('class', 'two col no-padding');
            $('#ds-quickadd-form').hide();
            $('#ds-recipient-signertype-select').change();
            //$('#quick-add-name').val('').removeClass('error');
            //$('#quick-add-email').val('').removeClass('error');
            //$('#ds-quickadd-form').show();
        } else {
            // Info from new recipient (contact/lead/user search results, Add Me or Quick Add)
            recipientName = unescapeHTMLSpecialCharacters(dsGlobal.newRecipientName);
            recipientEmail = dsGlobal.newRecipientEmail;
            recipientIsCurrentUser = isCurrentUser(recipientName, recipientEmail);
            $('#ds-recipient-signer-role, #ds-recipient-access-code, #ds-recipient-note').val('');
            if(recipientIsCurrentUser === true) {
                $('.self-signer-option').show();
            }
            // Just Select First value from 'Signer Type' dropdown
            $("#ds-recipient-signertype-select").val($("#ds-recipient-signertype-select option:first").val());
            // Auto assign next available signer role
            $('#ds-recipient-signer-role').val(getNextAvailableSignerRole());
        }
        var recipientInfo = recipientName + ' - ' + recipientEmail;
        if(recipientInfo.length > 70) {
            recipientInfo = recipientInfo.substring(0, 70) + '..';
        }
        $('#ds-recipient-info').text(unescapeHTMLSpecialCharacters(recipientInfo));
        $("#quick-add-name").val(recipientName);
        $("#quick-add-email").val(recipientEmail);
        
        // Only show language drop-down if multiple languages are selected
        if(dsGlobal.envelope.enableRecipientLanguageSelection === true) {
            $('#ds-recipient-language-setting').show();
            $('#ds-recipient-language-select option:selected').attr('selected', null);
            if(dsGlobal.isEditing) {
                $('#ds-recipient-language-select').val(recipient.languageCode);
                $('#ds-recipient-message-subject').val(recipient.emailSubject);
                $('#ds-recipient-message-body').val(recipient.emailMessage);
            } else {
                $('#ds-recipient-language-select').val(dsGlobal.envelope.languageSettings[0].LanguageCode);
                $('#ds-recipient-language-select').change();
            }
        } else {
            $('#ds-recipient-language-setting').hide();
        }
        // Hide Signature drop-down if 'Quick Add' is selected
        if(dsGlobal.recipientType === 'add-quick') {
            $('#ds-recipient-signature-dropdown').hide();
            hideRecipientModalLoading();
            return;
        }
        // Get Recipient Names
        try {
            dsGlobal.currentEditingRecipient = recipient;
            dsGlobal.currentEditingRecipientName = unescapeHTMLSpecialCharacters(recipientName);
            console.log('getRecipientNames remote action called, recipientEmail='+recipientEmail);
            Visualforce.remoting.Manager.invokeAction(dsGlobal.getRecipientNames, recipientEmail, recipientRemoteActionHandler);
        } catch (err) {
            console.log(err);
        }        
    }
    
    /*
     * Shortens document name
     */
    function shortenDocumentName(/*string*/ filename) {
    	if (filename === null || filename === undefined) {
    		return filename;
    	}
    	var length = filename.length;
    	if (length < 50) {
    		return filename;
    	} else {
    		return filename.substring(0, 25) + '...' + filename.substring(length-25, length);
    	}
    }
    
    /*
     * Creates HTML layout for a document and returns HTML
     */
    function createDocumentHtml(doc) {
    	var documentOrder = doc.documentOrder;
    	var documentName = doc.name;
    	var documentSize = doc.size;
    	var html = '<div class="document" id="' + doc.id + '">';
        html += '<img class="delete" src="' + ((Modernizr.svg) ? dsGlobal.deleteIcon : dsGlobal.deleteIconPNG) + '"></img>';
        html += '<img class="move" src="' + ((Modernizr.svg) ? dsGlobal.grabberIcon : dsGlobal.grabberPNG) + '"></img>';
    	html += '<input type="text" class="number" readonly="readonly" disabled value="' + documentOrder+ '" />';
        html += '<p class="name" title="' + documentName + '">' + shortenDocumentName(documentName) + '<span class="sub-text">' + documentSize + '</span></p>';
        html += '</div>';
        return html;
    }
    
    /*
     * Parse the envelope dto and add documents to UI
     * @docs - list of all documents from corresponding dto object
     */
    function populateAllDocumentHTML(docs) {
    	 // sort documents using document order
    	 docs.sort(function (a, b) {
            if (parseInt(a.documentOrder) > parseInt(b.documentOrder)) {
                return 1;
            }
            if (parseInt(a.documentOrder) < parseInt(b.documentOrder)) {
                return -1;
            }
            return 0;
        });
        
        // iterate over all the documents and create final HTML layout
        var documentsHtml = '';
        if (docs !== null) {  
    		for(var i = 0; i < docs.length; i++) {
    			documentsHtml += createDocumentHtml(docs[i]);
    		}
    	}
    	
    	// delete all HTML and event handlers
    	$('#dsDocumentListContainer .document .delete').unbind();
    	$("#dsDocumentListContainer").html('');
    	
    	// add new HTML and event handlers
    	// add HTML
    	$("#dsDocumentListContainer").html(documentsHtml);
    	// add remove click handlers
    	$('#dsDocumentListContainer .document .delete').bind('click', function(){
        	var documentId = this.parentNode.id;
        	console.log('delete document clicked id=' + documentId);
        	$("#" + documentId).css('opacity', '0.5');
        	deleteDocument(documentId);
        });
        // add sortable feature
        if (docs !== null && docs.length > 1) {
	        $('#dsDocumentListContainer').sortable({
		        axis: 'y',
		        opacity: 0.6,
		        items: '> div.document',
		        containment: 'document',
		        placeholder: 'ui-placeholder',
		        forcePlaceholderSize: true,
		        stop: function (event, ui) {
		            var reorderedDocuments = $('#dsDocumentListContainer').sortable('toArray');
		            var newOrders = {};
		            for(var index = 0; index < reorderedDocuments.length; index++) {
		            	var currentItemId = reorderedDocuments[index];
		            	var currentOrder = index + 1;
		            	newOrders[currentItemId] = currentOrder;
		            }
		            reorderDocuments(newOrders);
	 			}
	    	});
    	}
    }

    /*
     * initialize the recipient section
     */
    function initRecipient() {
        // Enable sorting for recipient list
        $('#dsRecipientsList').sortable({
            axis: 'y',
            opacity: 0.6,
            items: '> div.recipient',
            containment: 'document',
            placeholder: 'ui-placeholder',
            forcePlaceholderSize: true,
            stop: function (event, ui) {
                console.log(ui);
                console.log($('#dsRecipientsList').sortable('toArray'));
                var recipientId = ui.item[0].id;
                var recipient = getRecipientById(recipientId);
                var lastRoutingOrder = getLastRoutingOrder();
                var recipientsList = $('#dsRecipientsList').sortable('toArray');
                var topToBottom = ((ui.position.top > ui.originalPosition.top) > 0) ? true : false;
                var newRoutingOrder = 0;
                if(recipientsList[0] === recipientId) {
                    // recipient is dragged to top of list
                    newRoutingOrder = 1;
                } else if(recipientsList[recipientsList.length-1] === recipientId) {
                    // recipient is dragged to bottom of list 
                    if(lastRoutingOrder === 1) {
                        newRoutingOrder = 1;
                    } else {
                        newRoutingOrder = lastRoutingOrder + 1;
                    }                    
                } else {
                    // recipient is dragged to middle of list
                    var newRecipintIndex = 0;
                    for(var i = 0; i < recipientsList.length; i++) {
                        if(recipientsList[i] === recipientId) {
                            newRecipintIndex = i;
                            break;
                        }
                    }
                    if(topToBottom === true) {
                        newRoutingOrder = getRecipientById(recipientsList[newRecipintIndex+1]).routingOrder;
                    } else {
                        newRoutingOrder = getRecipientById(recipientsList[newRecipintIndex-1]).routingOrder;
                    }
                }
                updateRecipientsRoutingOrder(recipient, newRoutingOrder);
            }
        });
        $('#dsRecipientsList').sortable('disable');

        // Hide the Add Document, Add Recipient, Edit Recipient and Signer Role drop down
        $('.ds-add-recipient-dropdown, .ds-add-document-dropdown, .ds-edit-recipient-dropdown, #ds-recipient-signer-role-dropdown').hide();

        populateAllRecipientHTML();
    } 

    /*
    * Parse the envelope dto and add recipients to UI
    */
    function populateAllRecipientHTML() {
        populateLanguageSettingsHTML();
        populateSignerRoleHTML();
        populateRecipientHTML();
    }

    /*
    * Populate the language html based on language settings
    */
    function populateLanguageSettingsHTML() {
        if(dsGlobal.envelope.enableRecipientLanguageSelection !== true) {
            $('.language-label').hide();
        } else {
            $('#ds-recipient-language-select').html('');
            var languageSettings = dsGlobal.envelope.languageSettings;
            for(var i = 0; i < languageSettings.length; i++) {       
                $('#ds-recipient-language-select').append('<option value="'+languageSettings[i].LanguageCode+'">'+toCamcelCase(languageSettings[i].Language)+'</option>');
            }
        }
        if (dsGlobal.enableEmailSubjectEditingOverride !== '0') {
            if(dsGlobal.envelope.enableEmailSubjectEditing !== true)
                $('#ds-recipient-message-subject').attr('disabled','disabled');
        } else {
            $('#ds-recipient-message-subject').attr('disabled','disabled');
        }
        if (dsGlobal.enableEmailMessageEditingOverride !== '0') {
            if(dsGlobal.envelope.enableEmailMessageEditing !== true)
                $('#ds-recipient-message-body').attr('disabled','disabled');
        } else {
            $('#ds-recipient-message-body').attr('disabled','disabled');
        }
    }

    /*
    * Populate the signer role html based of the signer role settings
    */
    function populateSignerRoleHTML() {
        var defaultRoleNames = dsGlobal.envelope.defaultRoleNames;
        var defaultRoleValues = dsGlobal.envelope.defaultRoleValues;
        if(!defaultRoleNames || defaultRoleNames.length === 0) {
            $('#ds-recipient-signer-role-selection').hide();
        } else {
            for(var i = 0; i < defaultRoleNames.length; i++) {
                $('#ds-recipient-signer-role-dropdown').append('<li class="ds-recipient-signer-role-li" value="'+i+'"><a href="javascript:void(0);">'+defaultRoleNames[i]+'</a></li>');
            }
        }
    }

    /*
    * Parse the envelope dto and add recipients to UI
    */
    function populateRecipientHTML() {
        console.log('populateRecipientHTML called.');
        $('#dsRecipientsList .recipient').remove();
        var recipients = dsGlobal.envelope.recipients;
        recipients.sort(function (a, b) {
            if (parseInt(a.routingOrder) > parseInt(b.routingOrder)) {
                return 1;
            }
            if (parseInt(a.routingOrder) < parseInt(b.routingOrder)) {
                return -1;
            }
            return 0;
        });
        if(recipients !== null) {
            for(var i = 0; i < recipients.length; i++) {
                addRecipient(recipients[i]);
            }
        }
    }

    /*
    * Add recipient to the page
    * @param recipient the recipient of the envelope
    */
    function addRecipient(recipient) {
        var recipientName = (recipient && recipient.name && recipient.name.length > 26) ? unescapeHTMLSpecialCharacters(recipient.name).substring(0, 26) + '..' : unescapeHTMLSpecialCharacters(recipient.name);
        var recipientEmail = (recipient && recipient.email && recipient.email.length > 26) ? recipient.email.substring(0, 26) + '..' : recipient.email;
        var signerRole = (recipient.signerRole) ? recipient.signerRole : '';
        if(signerRole.length > 10) {
            signerRole = signerRole.substring(0, 10) + '..';
        }
        var signerType = recipient.signerType;
        var signerTypeFull = signerType;
        if(signerType) {
            if(signerType.toLowerCase().indexOf('sign in person') !== -1 || signerType.toLowerCase().indexOf('host in person') !== -1) {
                signerTypeFull = dsGlobal.signInPersonLabel + '(' + recipient.signInPersonName + ')';
            } else if ((signerType.toLowerCase().indexOf('signer now') !== -1)
                        || (recipient.recipientType && recipient.recipientType.toLowerCase() === 'custom' 
                            && signerType.toLowerCase() === 'signer' && recipient.signNow === 'true') ) {
                signerTypeFull = dsGlobal.signerDashSignNowLabel;
            } else if(signerType.toLowerCase() === 'signer') {
            	signerTypeFull = dsGlobal.signerLabel;
            } else if(signerType.toLowerCase() === 'carbon copy'){
            	signerTypeFull = dsGlobal.carbonCopyLabel;
            } else if(signerType.toLowerCase() === 'certified delivery'){
            	signerTypeFull = dsGlobal.certifiedDeliveryLabel;
            } else if(signerType.toLowerCase() === 'carbon copy'){
            	signerTypeFull = dsGlobal.carbonCopyLabel;
            } else if(signerType.toLowerCase() === 'address recipients'){
            	signerTypeFull = dsGlobal.addressRecipientsLabel;
            } else if(signerType.toLowerCase() === 'manage envelope'){
            	signerTypeFull = dsGlobal.manageEnvelopeLabel;
            }
            signerType = (signerTypeFull.length > 16) ? signerTypeFull.substring(0, 16) + '...' : signerTypeFull;
        } else {
            signerType = '';
            signerTypeFull = '';
        }
        var newRecipient = '<div class="recipient" id="'+recipient.id+'">'
                            + '<img class="move recipient-move-icon" src="'+((Modernizr.svg) ? dsGlobal.grabberIcon : dsGlobal.grabberPNG)+'"></img>'
                            + '<input type="text" class="number" maxlength="3" value="'+((recipient.routingOrder === null) ? '1' : recipient.routingOrder)+'" />'
                            + '<p class="name" title="'+unescapeHTMLSpecialCharacters(recipient.name)+'">'+unescapeHTMLSpecialCharacters(recipientName)
                            + '<span class="sub-text" title="'+unescapeHTMLSpecialCharacters(recipient.email)+'">'+unescapeHTMLSpecialCharacters(recipientEmail)+'</span></p>'
                            + '<p class="action" title="'+encodeSpecialCharacters(signerTypeFull)+'">'+encodeSpecialCharacters(signerType)+'</p>';
        // Show Language info only if User has enabled multi languages
        if(dsGlobal.envelope.enableRecipientLanguageSelection === true) {
            newRecipient += '<p class="language">';
            if(typeof(recipient.languageCode) !== 'undefined' && recipient.languageCode !== null) {
                var languageSettings = dsGlobal.envelope.languageSettings;
                for(var i = 0; i < languageSettings.length; i++) {
                    if(recipient.languageCode === languageSettings[i].LanguageCode) {
                        //Only show the first word from the language label
                        var arr = languageSettings[i].Language.split(' ');
                        var language = (arr.length > 1) ? arr[0] : languageSettings[i].Language;
                        newRecipient += toCamcelCase(language);
                    }
                }
            }
            newRecipient += '</p>';
        }
        newRecipient += '<p class="role">'+signerRole+'</p>';
        newRecipient += '<img class="delete" src="'+((Modernizr.svg) ? dsGlobal.deleteIcon : dsGlobal.deleteIconPNG)+'"></img>'
                        + '<a href="#" class="edit">'+dsGlobal.editLabel+'</a>'
                        + '</div>';
        $('#dsRecipientsList').append(newRecipient);
        toggleRecipientSorting();
    }

    /*
    * Find recipient by Id
    * @param recipientId the id of the recipient
    */
    function getRecipientById(recipientId) {
        console.log('getRecipientById called, recipientId='+recipientId);
        var result;
        var recipients = dsGlobal.envelope.recipients;
        if(typeof(recipients) !== 'undefined' && recipients !== null) {
            for(var i = 0; i < recipients.length; i++) {
                if(recipients[i].id === recipientId) {
                    result = recipients[i];
                }
            }
        }
        return result;
    }

    /*
    * Update recipient dto
    * @param recipient the recipient dto
    */
    function updateRecipientDto(recipient) {
        console.log('updateRecipientDto called, recipientId='+recipient.id);
        if(recipient !== null && dsGlobal.envelope.recipients !== null) {
            for(var i = 0; i < dsGlobal.envelope.recipients.length; i++) {
                if(dsGlobal.envelope.recipients[i].id === recipient.id) {
                    dsGlobal.envelope.recipients[i] = recipient;
                	console.log(dsGlobal.envelope.recipients);
                    return;
                }
            }
        }
        dsGlobal.envelope.recipients.push(recipient);
    }

    /*
    * Remove recipient dto
    * @param recipientId the id of the recipient dto
    */
    function deleteRecipientDto(recipientId) {
        console.log('deleteRecipientDto called, recipientId='+recipientId);
        if(recipientId !== null && dsGlobal.envelope.recipients !== null) {
            var recipients = [];
            for(var i = 0; i < dsGlobal.envelope.recipients.length; i++) {
                if(dsGlobal.envelope.recipients[i].id !== recipientId) {
                    recipients.push(dsGlobal.envelope.recipients[i]);
                }
            }
            dsGlobal.envelope.recipients = recipients;
        }
    }

    /**
    * enable/disable sorting for recipient(s) list
    */
    function toggleRecipientSorting() {
        var recipients = dsGlobal.envelope.recipients;
        if(recipients && recipients.length > 1) {
            $('#dsRecipientsList').sortable('enable');
            $('.recipient-move-icon').show();
            console.log('toggleRecipientSorting called, change=enabled.');
        } else {
            $('#dsRecipientsList').sortable('disable');
            $('.recipient-move-icon').hide();
            console.log('toggleRecipientSorting called, change=disabled.');
        }
    }

    /**
     * Return the next available signer role
     */
    function getNextAvailableSignerRole() {
        for(var i = 0; i < dsGlobal.envelope.defaultRoleNames.length; i++) {
            var isUsed = false;
            for(var j = 0; j < dsGlobal.envelope.recipients.length; j++) {
                var recipient = dsGlobal.envelope.recipients[j];
                if(recipient.signerRole === dsGlobal.envelope.defaultRoleNames[i]) {
                    isUsed = true;
                    break;
                }
            }
            if(!isUsed)
                return dsGlobal.envelope.defaultRoleNames[i];
        }
        return '';
    }

    /**
     * This function updates the user's password.
     */
    function deleteEnvelope() {
        console.log('deleteEnvelope called.');
        try {
            Visualforce.remoting.Manager.invokeAction(
                dsGlobal.deleteEnvelope, dsGlobal.sourceId, dsGlobal.envelopeId,
                function(result, event) { 
                    remoteActionHandler(result, event);
                }
            );
        } catch (err) {
            console.log(err);
        }
    }

    /**
     * This function sends the envelope to DocuSign and renders the Success or Tagger page.
     * @param sendMethod is either sendNow or tagEnvelope, depending on the button pressed
     */
    function sendEnvelope(sendNow) {
        console.log('sendEnvelope called with sendNow='+sendNow);
        console.log(dsGlobal.envelope);
        try {
            Visualforce.remoting.Manager.invokeAction(
                dsGlobal.sendEnvelope, dsGlobal.sourceId, dsGlobal.envelopeId, sendNow, dsGlobal.newWindow,
                $('#emailSubject').val(), $('#emailMessage').val(), $('#remindSigners').prop('checked'),
                $('#sendReminderDays').val(), $('#sendReminderRepeatDays').val(), $('#expireEnvelope').prop('checked'),
                $('#expireEnvelopeDays').val(), $('#warnExpireDays').val(), $('#enableChatterUpdates').prop('checked'),
                function(result, event) {
                    remoteActionHandler(result, event);
                }
            );
        } catch (err) {
            console.log(err);
        }
    }

    /**
     * This function handles the result from Salesforce Remote Action call.
     * @param result the result of the Salesforce Remote Action call
     * @param event the event of the Salesforce Remote Action call
     */
    function remoteActionHandler(result, event) {
        console.log('remoteActionHandler called');
        if (event.status) {
            if (!result || !result.action) {
                // Back-end returns unknown error
                showErrors(result.messages, false);
                hideFullScreenLoading();
            } else if (result.action === 'ShowError') {
                showErrors(result.messages, false);
                hideFullScreenLoading();
            } else if (result.action === 'ShowTagger'       || result.action === 'ShowSuccess' ||
                       result.action === 'ShowSourceObject' || result.action === 'ShowSignNow') {
                window.location.href = unescapeHTMLSpecialCharacters(result.url);
            }
        } else {
            showErrors(result.messages, false);
            hideFullScreenLoading();
        }
    }

    /*
     * This function to unescape all html special characters
     * @param str  the string to be modified
     */
    function unescapeHTMLSpecialCharacters(str) {
        if(!str) {
            return '';
        }        
        return str.replace(/&quot;/g,'"').replace(/&amp;/g,"&").replace(/&lt;/g,"<").replace(/&gt;/g,">").replace(/&#39;/g,"'");
    }

    /*
     * This function to encode special characters to html
     * @param str  the string to be modified
     */
    function encodeSpecialCharacters(str) {
        if(!str) {
            return '';
        }        
        return str.replace(/&/g, "&amp;").replace(/>/g, "&gt;").replace(/</g, "&lt;").replace(/"/g, "&quot;").replace(/'/g, "&lsquo;");       
    }

    /*
     * This function convert string to camel case
     * str the string to be converted
     */
    function toCamcelCase(str) {
       return str.charAt(0).toUpperCase() + str.toLowerCase().slice(1);
    }

    function showError(errorCode, errorDescription) {
        $('#dsAlert ul').append('<li><p>'+errorDescription+'</p></li>');
        $('#dsAlert').show();
        $("html, body").animate({ scrollTop: 0 }, "fast");
    }

    function showErrors(messages, showBackButton) {
        $('#dsAlert ul').empty();
        for (var m = 0; m < messages.length; m++) {
            showError(messages[m].code, messages[m].description);
        }
        if (showBackButton) {
            $('#backButton').show();
        }
    }
    
    function hideErrors() {
    	$('#dsAlert').hide();
    	$('#backButton').hide();
    }

    /*
     * This function validate the quick add form
     * return true if form has no error, otherwise return false
     */
    function validateAddQuickForm() {
        console.log('validateAddQuickForm called, name='+$('#quick-add-name').val()+', email='+$('#quick-add-email').val());
        var hasNoError = true;
        $('#quick-add-name, #quick-add-email').removeClass('error');
        $('.ds-recipient-name-error-label, .ds-recipient-email-error-label').hide();
        if(!$('#quick-add-name').val()) { 
            $('#quick-add-name').addClass('error');
            $('.ds-recipient-name-error-label').show();
            hasNoError = false;
        }
        if(!$('#quick-add-email').val()) {          
            $('#quick-add-email').addClass('error');
            $('.ds-recipient-email-error-label').text(dsGlobal.fieldRequiredLabel).show();
            hasNoError = false;
        } else if(!/^([\w-\.+-]+@([\w-]+\.)+[\w-]{2,4})?$/.test($('#quick-add-email').val())) {          
            $('#quick-add-email').addClass('error');
            $('.ds-recipient-email-error-label').text(dsGlobal.invalidEmailLabel).show();
            hasNoError = false;
        }
        console.log('validateAddQuickForm result=' + hasNoError);
        return hasNoError;
    }

    /*
     * This function validate the add new contact form
     * return true if form has no error, otherwise return false
     */
    function validateAddNewContactForm() {
        console.log('validateAddNewContactForm called');
        var hasNoError = true;
        $('#add-new-contact-lname, #add-new-contact-email').removeClass('error');
        $('.add-new-contact-lname-error, .add-new-contact-email-error').hide();
        if(!$('#add-new-contact-lname').val()) { 
            $('#add-new-contact-lname').addClass('error');
            $('.add-new-contact-lname-error').show();
            hasNoError = false;
        }
        if(!$('#add-new-contact-email').val()) {          
            $('#add-new-contact-email').addClass('error');
            $('.add-new-contact-email-error').text(dsGlobal.fieldRequiredLabel).show();
            hasNoError = false;    
        } else if(!/^([\w-\.+-]+@([\w-]+\.)+[\w-]{2,4})?$/.test($('#add-new-contact-email').val())) {          
            $('#add-new-contact-email').addClass('error');
            $('.add-new-contact-email-error').text(dsGlobal.invalidEmailLabel).show();
            hasNoError = false;
        }
        console.log('validateAddNewContactForm result=' + hasNoError);
        return hasNoError;
    }

    /*
     * This function checks if the recipient is current user
     * name the name of the recipient
     * email the email of the recipient
     * return true if the recipient is the current user, otherwise return false
     */
    function isCurrentUser(name, email) {
        console.log('isCurrentUser called, name='+name+' ,email='+email);
        if (typeof(name) === 'undefined' || name === null || typeof(email) === 'undefined' || email === null) {
            return false;
        }
        return ((name === dsGlobal.currentUserName) && (email === dsGlobal.currentUserEmail));
    }

    /*
     * This function to show the add recipient drop down menu
     */
    $('#ds-add-recipient-btn').mouseover(function(){
        $('.ds-add-recipient-dropdown').show();
     });

    /*
     * This function to hide the add recipient drop down menu
     */
    $('#ds-add-recipient-btn').mouseout(function(){    
        $('.ds-add-recipient-dropdown').hide();
    });

    /*
     * This function to show the add document drop down menu
     */
    $('#ds-add-document-btn').mouseover(function(){
        $('.ds-add-document-dropdown').show();
     });

    /*
     * This function to hide the add document drop down menu
     */
    $('#ds-add-document-btn').mouseout(function(){    
        $('.ds-add-document-dropdown').hide();
    });

    /*
     * This function to show the signer role drop down menu
     */
    $('#ds-recipient-signer-role-btn').mouseover(function(){
        $('#ds-recipient-signer-role-dropdown').show();
    });

    /*
     * This function to hide the signer role drop down menu
     */
    $('#ds-recipient-signer-role-btn').mouseout(function(){
        $('#ds-recipient-signer-role-dropdown').hide();
    });
    
    /*
     * This function is to show the edit recipient drop down menu
     */
    $('#ds-edit-recipient-btn').mouseover(function(){
        $('.ds-edit-recipient-dropdown').show();
    });

    /*
     * This function is to show the edit recipient  drop down menu
     */
    $('#ds-edit-recipient-btn').mouseout(function(){
        $('.ds-edit-recipient-dropdown').hide();
    });

    $("#cancelButton").click(function(){
    	disableButtons();
        showFullScreenLoading();
        deleteEnvelope();
        enableButtons();
        if(dsGlobal.newWindow == '1'){
        	window.close();
        }
    });
    

    $("#sendNowButton").click(function(){
    	disableButtons();
        showFullScreenLoading();
        sendEnvelope(true);
        enableButtons();
    });

    $("#nextButton").click(function(){
    	disableButtons();
        showFullScreenLoading();
        sendEnvelope(false);
        enableButtons();
    });

	function disableButtons() {
		$("#cancelButton").removeAttr("href");
		$("#sendNowButton").removeAttr("href");
		$("#nextButton").removeAttr("href");
	}

	function enableButtons() {
		$("#cancelButton").attr("href", "javascript:void(0);");
		$("#sendNowButton").attr("href", "javascript:void(0);");
		$("#nextButton").attr("href", "javascript:void(0);");
	}

    // Click handler for hidding add recipient modal
    $('.ds-recipient-cancel-btn, .ds-recipient-close-icon, #ds-cancel-new-contact-btn').click(function(){
        hideAll();
        $("#ds-edit-envelope").show();
    });
    
    // function for deleting document
    function deleteDocument(/*string*/ docId) {
    	hideErrors();
    	try {
 			Visualforce.remoting.Manager.invokeAction(
 				dsGlobal.deleteDocument,	// action name
 				dsGlobal.envelopeId, docId, // parameters
 				function(result, event) {   // handler
 					 console.log('delete document, result='+result+' event.status='+event.status);
 					 if (event.status) {
                        if(!result) {
                            // Back-end returns unknown error..
                            return;
                        }
                        populateAllDocumentHTML(result.documents);
                        dsGlobal.envelope.documents = result.documents;
                    } else {
                        showErrors(result.messages, false);
                    }
 				}
 			);
    	} catch (err) {
            console.log(err);
        }
    }
    
    // function for reordering documents
    function reorderDocuments(/*map<string documentId,int newOrder>*/ newOrders) {
    	try {
    		Visualforce.remoting.Manager.invokeAction(
    			dsGlobal.reorderDocuments,
    			dsGlobal.envelopeId, newOrders,
    			function(result, event) {   // handler
 					 console.log('reorder documents, result='+result+' event.status='+event.status);
 					 if (event.status) {
                        if(!result) {
                            // Back-end returns unknown error..
                            return;
                        }
                        populateAllDocumentHTML(result.documents);
                        dsGlobal.envelope.documents = result.documents;
                    } else {
                        showErrors(result.messages, false);
                    }
 				}
    		);
    	} catch(err) {
    		console.log(err);
    	}
    }
    
    // creates html layout for attachment
    function createAvailableDocument(doc) {
    	var name = doc.name;
    	var docType = doc.documentType;
    	var id = doc.relatedObjectId;
    	var templateId = doc.externalDocumentId;
    	var html = '<label class="option">';
    	html += '<input type="checkbox" id="' + id + '" name="' + name + '" docType="' + docType + '"/>';
    	html += name;
    	html += ' </label>';
    	return html;
    }
    
    // creates html layout for folder
    function createFolder(folder, selected) {
    	var id = folder.id;
    	var name = folder.name;
    	var html = '<option';
    	if (selected) {
    		html += ' selected="selected"';
    	} 
    	html += ' value="' + id + '"';
    	html += ' id="' + id + '" >';
    	html += name;
    	html += '</option>'
    	return html;
    }
    
    // loads documents from folder
    function loadDocumentsFromFolder(remoteActionName, folderId, headerName) {
    	try {
			Visualforce.remoting.Manager.invokeAction(
				remoteActionName , 				  	// action	
				dsGlobal.envelopeId, folderId,			  // parameters
				function(result, event) {						  // handler
					hideDocumentsModalLoading();
					console.log('attachments loaded, result='+result+' event.status='+event.status);
 					 if (event.status) {
                        if(!result) {
                            // Back-end returns unknown error..
                            return;
                        }
                		showAvailableDocuments(result.documents, result.folders, headerName);      	
                    } else {
                        showErrors(result.messages, false);
                    }
				}
			);
		} catch(err) {
    		console.log(err);
    	}	
    }
    
    // shows obtained documents from back end
    function showAvailableDocuments(/*list<document>*/ docs, /*list<folder>*/ folders, /*string*/ header) {
    	// header and folders
    	$("#ds_docmodal_header").html(header);
    	if ((header === dsGlobal.documentsLabel) || (header === dsGlobal.libraryLabel)) {
    		$("#ds_docmodal_folder").show();
    	} else {
    		$("#ds_docmodal_folder").hide();
    	}
    	
    	
    	// delete all HTML and event handlers
    	$("#ds_docmodal_add_attachment").unbind();
    	$('.ds-add-document-modal-content .content input').unbind();
    	$(".ds-add-document-modal-content .content ").html('');
    	
    	// add new layout (folders)
    	if (folders !== null && folders.length > 0) {
    		var foldersHtml = '';
    		$("#ds_docmodal_folder_select").unbind();
    		$("#ds_docmodal_folder_select").html('');
    		for(var i = 0; i < folders.length; i++) {
    			var selected = (i == 0);
				foldersHtml += createFolder(folders[i], selected);
			}
			$("#ds_docmodal_folder_select").html(foldersHtml);
			$("#ds_docmodal_folder_select").change(function() {
				var folderId = $("#ds_docmodal_folder_select").val();
				var header = $("#ds_docmodal_header").html();
				if (header == 'Documents') {
					loadDocumentsFromFolder(dsGlobal.getAvailableDocumentForFolder, folderId, dsGlobal.documentsLabel);
				} else {
					loadDocumentsFromFolder(dsGlobal.getAvailableContentDocumentForFolder, folderId, dsGlobal.libraryLabel);
				}
			});
    	}

    	// add new document/attachment handler
    	if (header === dsGlobal.attachmentsLabel) {
    		$("#ds_docmodal_add_attachment").show();
    		$("#ds_docmodal_add_attachment").click(function() {
    			Visualforce.remoting.Manager.invokeAction(
	                dsGlobal.updateEnvelope, // action 
	                dsGlobal.sourceId, dsGlobal.envelopeId, false, // parameters
	                $('#emailSubject').val(), $('#emailMessage').val(), $('#remindSigners').prop('checked'),
	                $('#sendReminderDays').val(), $('#sendReminderRepeatDays').val(), $('#expireEnvelope').prop('checked'),
	                $('#expireEnvelopeDays').val(), $('#warnExpireDays').val(), $('#enableChatterUpdates').prop('checked'),
	                function(result, event) { // callback
	                	if (event.status) {
	                        if(!result) {
	                            return;
	                        }
	                		var currentPageAddress = window.location.href;
			    			if (currentPageAddress[currentPageAddress.length-1] == '#') {
			    				currentPageAddress = currentPageAddress.substring(0, currentPageAddress.length-1);
			    			}
			    			currentPageAddress += '&SAA=1';
			    			var returnUrl = encodeURIComponent(currentPageAddress);
			    			var addAttachmentUrl = dsGlobal.pathPrefix + '/p/attach/NoteAttach?pid=';
			    			addAttachmentUrl += dsGlobal.envelopeId;
			    			addAttachmentUrl += '&retURL=';
			    			addAttachmentUrl += returnUrl;
			    			window.location.href = addAttachmentUrl;     	
	                    } else {
	                    	$(".ds-document-cancel-btn").click();
	                        showErrors(result.messages, false);
	                    }            	
				    }
            	);
    		});
    	} else if (header === dsGlobal.documentsLabel) {
    		$("#ds_docmodal_add_attachment").show();
    		$("#ds_docmodal_add_attachment").click(function() {
    			window.open(dsGlobal.pathPrefix + '/p/doc/DocumentUploadUi','_blank','width=900,height=700,scrollbars=1,resizable=1');
    		});
    	} else {
    		$("#ds_docmodal_add_attachment").hide();
    	}
    	
    	// add new layout (documents)
    	var documentsHtml = '';
		if (docs !== null) {
			for(var i = 0; i < docs.length; i++) {
				documentsHtml += createAvailableDocument(docs[i]);
			}
		}
		$(".ds-add-document-modal-content .content ").html(documentsHtml);
    }
    
    /*
     * Loads available documents and shows the dialog
     */
    function loadAvailableDocuments(/*string*/ remoteActionName, /*string*/ modalHeader) {
    	hideErrors();
    	try {
			Visualforce.remoting.Manager.invokeAction(
				remoteActionName, 				  				   // action	
				dsGlobal.envelopeId, dsGlobal.sourceId,			  // parameters
				function(result, event) {						  // handler
					hideDocumentsModalLoading();
					console.log('attachments loaded, result='+result+' event.status='+event.status);
 					 if (event.status) {
                        if(!result) {
                            // Back-end returns unknown error..
                            return;
                        }
                		showAvailableDocuments(result.documents, result.folders, modalHeader);      	
                    } else {
                        showErrors(result.messages, false);
                    }
            
				}
			);
			showDocumentsModalLoadind();
		} catch(err) {
    		console.log(err);
    	} finally {
    		hideDocumentsModalLoading();
    	}
    }
    
    /*
     * Loads available documents (with folders) and shows the dialog
     */
    function loadAvailableDocumentsWithFolders(/*string*/ remoteActionName, /*string*/ modalHeader) {
    	hideErrors();
    	try {
			Visualforce.remoting.Manager.invokeAction(
				remoteActionName, 	// action	
				dsGlobal.envelopeId,            // parameters
				function(result, event) {		// handler
					hideDocumentsModalLoading();
					console.log('attachments loaded, result='+result+' event.status='+event.status);
 					if (event.status) {
                        if(!result) {
                            // Back-end returns unknown error..
                            return;
                        }
                		showAvailableDocuments(result.documents, result.folders, modalHeader);      	
                    } else {
                        showErrors(result.messages, false);
                    }
            
				}
			);
			showDocumentsModalLoadind();
			$("#ds_docmodal_folder").hide();
    		$("#ds_docmodal_add_attachment").hide();
		} catch(err) {
    		console.log(err);
    	} finally {
    		hideDocumentsModalLoading();
    	}
    }
    
    // Click handler for hidding add recipient modal
    $('.ds-document-close-icon, .ds-document-cancel-btn').click(function(){
    	hideDocumentsModal();
        showEditEnvelope();
    })
    
    // click handler for add attachment
    $('#add-attachment').click(function(){
    	loadAvailableDocuments(dsGlobal.getAvailableAttachments, dsGlobal.attachmentsLabel);
    });
    
    // click handler for add new feed item
    $('#add-feed-items').click(function(){
    	loadAvailableDocuments(dsGlobal.getAvailableFeedItems, dsGlobal.feeditemsLabel);
    });
    
    // click handler for add new docusign template
    $('#add-docusign-template').click(function(){
    	loadAvailableDocuments(dsGlobal.getAvailableDocusignTemplates, dsGlobal.templatesLabel);
    });
    
    // click handler for add new docusign template
    $('#add-libraries').click(function(){
    	loadAvailableDocumentsWithFolders(dsGlobal.getAvailableContentFolders, dsGlobal.libraryLabel);
    });
    
    // click handler for add new docuemnt
    $('#add-document').click(function(){
    	loadAvailableDocumentsWithFolders(dsGlobal.getAvailableFolders, dsGlobal.documentsLabel);
    });
    
    
    // Click handler on next button for attachments
    $('#ds-document-next-btn').click(function(){
    	hideErrors();
    	var newDocuments = [];		
    	$(".ds-add-document-modal-content .content input:checked").each(function(index, item) {
    		var newDocument = {};
    		var $item = $(item);
    		newDocument.relatedObjectId = $item.attr('id');
    		newDocument.name = $item.attr('name');
    		newDocument.documentType = $item.attr('docType');
    		docType = newDocument.documentType;
    		newDocuments.push(newDocument);
    	});
    	try {
            Visualforce.remoting.Manager.invokeAction(
                dsGlobal.addDocuments, // method 
                dsGlobal.envelopeId, newDocuments,	// parameters
                function(result, event) {	// handler
                    console.log('add documents, result='+result+' event.status='+event.status);
 					if (event.status) {
                        if(!result) {
                            // Back-end returns unknown error..
                            return;
                        }
                        if (result.messages.length > 0) {
                        	showErrors([{code:"Unknown", description:"Unknown server error"}], false);
                        } else {
                        	populateAllDocumentHTML(result.documents);
                        	dsGlobal.envelope.documents = result.documents;
                        }
                    } else {
                        showErrors([{code:"Unknown", description:"Unknown server error"}], false);
                    }
                }
            );
        } catch (err) {
            console.log(err);
        } finally {
        	showEditEnvelope();
        }
    });

    /*
     * This function return a map with key = recipient id, value = new routing order
     * @param recipient the modified recipient
     * @param newRoutingOrder the new routing order of the modified recipient
     * return a map of recipients need to be updated
     */
    function updateRecipientsRoutingOrder(recipient, newRoutingOrder) {
        console.log('updateRecipientsRoutingOrder called, newRoutingOrder='+newRoutingOrder);
        console.log(recipient);
        var lastRoutingOrder = getLastRoutingOrder();
        var updatedRecipients = new Object();
        // Update the modified recipient
        if(newRoutingOrder > (lastRoutingOrder+1)) {
            newRoutingOrder = lastRoutingOrder + 1;
        }
        recipient.routingOrder = newRoutingOrder.toString();
        updateRecipientDto(recipient);
        updatedRecipients[recipient.id] = newRoutingOrder.toString();
        // Find if there is missing routing order
        var recipients = dsGlobal.envelope.recipients;
        var assignedOrder = new Object();
        for(var i = 0; i < recipients.length; i++) {
            var r = recipients[i];
            if(!assignedOrder[parseInt(r.routingOrder)]) {
                assignedOrder[parseInt(r.routingOrder)] = r.routingOrder;
            }
        }
        var missingOrder = 0;
        for(var j = 1; j <= lastRoutingOrder; j++) {
            if(!assignedOrder[j]) {
                missingOrder = j;
                console.log('updateRecipientsRoutingOrder, missing order=' + missingOrder);
                break;
            }
        }
        if(missingOrder !== 0) {
            // Missing Order found, shift recipients
            for(var i = 0; i < recipients.length; i++) {
                var r = recipients[i];
                var orderNum = parseInt(r.routingOrder);
                if(orderNum > missingOrder) {
                    r.routingOrder = (orderNum - 1).toString();
                    updateRecipientDto(r);
                    updatedRecipients[r.id] = (orderNum - 1).toString();
                }
            }
        }
        try {
            console.log('reorderRecipients remote action called, envelope id='+dsGlobal.envelopeId);
            console.log(updatedRecipients);
            Visualforce.remoting.Manager.invokeAction(
                dsGlobal.reorderRecipients, dsGlobal.envelopeId, updatedRecipients, recipientRemoteActionHandler
            );
        } catch (err) {
            console.log(err);
        }
    }


    /*
     * This function return the routing order of the last recipient in the list
     * return the routing order of the last recipient in the list
     */
    function getLastRoutingOrder() {
        var recipients = dsGlobal.envelope.recipients;
        return parseInt(recipients[recipients.length-1].routingOrder);    
    }

    /*
     * This function handle the results returned from recipient remote action
     * @param result the result of the Salesforce Remote Action call
     * @param event the event of the Salesforce Remote Action call
     */
    function recipientRemoteActionHandler(result, event) {
        console.log('recipientRemoteActionHandler called');
        console.log(result);
        console.log(event);
        if(event.status) {
            if(!result) {
                return; // Back-end returns unknown error..
            }
            if(result.action === 'ShowError') {
                hideRecipientModalLoading();
                showErrors(result.messages, false);
                if(event.method === 'deleteRecipient') {
                    var recipientId = result.envelope.recipients[0].id;
                    $('#'+recipientId).css('opacity', '1.0');
                }
            } else if(result.action === 'ShowSuccess') {
                if(event.method === 'reorderRecipients') {
                    dsGlobal.envelope.recipients = result.envelope.recipients;
                    populateRecipientHTML();
                } else if(event.method === 'deleteRecipient') {
                    var recipientId = result.envelope.recipients[0].id;
                    $('#'+recipientId).remove();
                    deleteRecipientDto(recipientId);
                    toggleRecipientSorting();
                } else if(event.method === 'saveRecipient') {
                    hideRecipientModalLoading();
                    updateRecipientDto(result.envelope.recipients[0]);
                    populateRecipientHTML();
                    hideAll();
                    $("#ds-edit-envelope").show();
                } else if(event.method === 'searchContacts' || event.method === 'searchLeads' || event.method === 'searchUsers') {
                    var content = '';
                    var recipients = result.envelope.recipients;
                    if(!recipients || recipients.length === 0) {
                        content = '<br/>&nbsp;&nbsp;' + dsGlobal.noMatchFoundLabel;
                    } else {
                        recipients.sort(function (a, b) {
                            var x = a.name.toLowerCase();
                            var y = b.name.toLowerCase();
                            if (x > y) return 1;
                            if (x < y) return -1;
                            return 0;
                        });                        
                        for(var i = 0; i < recipients.length; i++) {
                            content += '<li value="' + unescapeHTMLSpecialCharacters(recipients[i].name) + '|' + recipients[i].email + '|';
                            if(dsGlobal.recipientType === 'add-contact') {
                                content += recipients[i].contactId;
                            } else if(dsGlobal.recipientType === 'add-lead') {
                                content += recipients[i].leadId;
                            } else if(dsGlobal.recipientType === 'add-user') {
                                content += recipients[i].userId;
                            }
                            content += '">';
                            if (dsGlobal.recipientType === 'add-contact' || dsGlobal.recipientType === 'edit-contact' ||
                            dsGlobal.recipientType === 'add-lead' || dsGlobal.recipientType === 'edit-lead' || 
                            dsGlobal.recipientType === 'add-user' || dsGlobal.recipientType === 'edit-user') {
                            	content += '<span class="account-name">';
                            	var accountName = recipients[i].accountName;
                            	if (accountName !== undefined && accountName !== null && accountName.length > 0) { 
                            		content += accountName;
                            	}
                            	content += '</span><span class="contact-name">';
                            	content += recipients[i].name;
                            	content += '</span><span class="contact-email">';
                            	var contactEmail = recipients[i].email;
                            	if (contactEmail !== undefined && contactEmail !== null && contactEmail.length > 0) { 
                            		content += contactEmail;
                            	}
                            	content += '</span>';
                            } else {
                            	content += recipients[i].name;
                            }
                            content += '</li>';
                        }
                    }
                    $('#ds-recipient-search-result ul').html(content);
                    hideRecipientModalLoading();     
                } else if(event.method === 'getRecipientNames') {
                    var recipientName = unescapeHTMLSpecialCharacters(dsGlobal.currentEditingRecipientName);
                    var recipient = dsGlobal.currentEditingRecipient;
                    if(result.envelope.recipients[0].recipientNames.length === 0) {
                    	$('#ds-recipient-signature-dropdown select').append($("<option></option>").attr("value", unescapeHTMLSpecialCharacters(recipientName)).text(unescapeHTMLSpecialCharacters(recipientName)));
                    	$('#ds-recipient-signature-dropdown select').val(unescapeHTMLSpecialCharacters(recipientName));
                        $('#ds-recipient-signature-dropdown').hide();
                    } else {
                        $('#ds-recipient-signature-dropdown').show();
                        $('#ds-recipient-signature-dropdown select').html('');
                        var recipientNames = result.envelope.recipients[0].recipientNames;
                        var hasCurRecipientName = false;
                        for(var i = 0; i < recipientNames.length; i++) {
                            $('#ds-recipient-signature-dropdown select').append($("<option></option>").attr("value", unescapeHTMLSpecialCharacters(recipientNames[i])).text(unescapeHTMLSpecialCharacters(recipientNames[i]))); 
                            if(recipientNames[i] === recipientName) {
                                hasCurRecipientName = true;
                            }
                        }
                        if(!hasCurRecipientName) {
                            $('#ds-recipient-signature-dropdown select').append($("<option></option>").attr("value", unescapeHTMLSpecialCharacters(recipientName)).text(unescapeHTMLSpecialCharacters(recipientName)));
                        }
                        if(recipient && recipient.signatureName) {
                            $('#ds-recipient-signature-dropdown select').val(unescapeHTMLSpecialCharacters(recipient.signatureName)); 
                        } else {
                            $('#ds-recipient-signature-dropdown select').val(unescapeHTMLSpecialCharacters(recipientName));
                        }
                    }
                    hideRecipientModalLoading();                
                } else if(event.method === 'saveContact') {
                    dsGlobal.newRecipientName = result.contact.FirstName + ' ' + result.contact.LastName;
                    dsGlobal.newRecipientEmail = result.contact.Email;
                    dsGlobal.newRecipientId = result.contact.Id;
                    dsGlobal.isChangingRecipient = true;
                    showEditRecipientModal(dsGlobal.currentEditingRecipientId);
                }
                console.log(dsGlobal.envelope.recipients);
            }
        } else {
            hideRecipientModalLoading();
            showErrors(result.messages, false);
        }
    }

    // Click handler for deleting recipient
    $('#recipients section').on('click', '.recipient .delete', function(){
    	hideErrors();
        var recipientId = this.parentNode.id;
        console.log('delete recipient called, id='+recipientId);
        $('#'+recipientId).css('opacity', '0.5');
        try {
            Visualforce.remoting.Manager.invokeAction(dsGlobal.deleteRecipient, recipientId, recipientRemoteActionHandler);
        } catch (err) {
            console.log(err);
        }
    });

    // Click handler for editing recipient
    $('#recipients section').on('click', '.recipient .edit', function(){
        var recipientId = this.parentNode.id;
        console.log('edit recipient called, id='+recipientId);
        dsGlobal.currentEditingRecipientId = recipientId;
        showEditRecipientModal(recipientId);
    });

    //  Click handler for saving (new or edited) recipient
    $('#ds-recipient-save-btn').click(function(){
    	hideErrors();
        console.log('save recipient btn clicked, currentEditingRecipientId='+dsGlobal.currentEditingRecipientId);
        console.log('recipientType=' + dsGlobal.recipientType);
        if(dsGlobal.recipientType === 'add-quick') {
            if(!validateAddQuickForm())
                return; // stop if quick add form has invalid data
        }
        if(($('#ds-recipient-signertype-select').val() === 'Signer Now' 
            || $('#ds-recipient-signertype-select').val() === 'Host in person'  
            || $('#ds-recipient-signertype-select').val() === 'Host in person - sign now') 
            && ($('#ds-recipient-signature-dropdown select').val() !== dsGlobal.currentUserName)) {
                $('.ds-recipient-signature-dropdown-error-label').show();
                return; // stop if signature name does not match current user name
        }        
        showRecipientModalLoading();
        var recipient = {};
        var envelopeId = '';
        //If we are editing a recipient
        if(typeof(dsGlobal.currentEditingRecipientId) !== 'undefined' && dsGlobal.currentEditingRecipientId !== null) {
            // For saving edited recipient
            console.log('Entered edition of recipient');
            recipient = getRecipientById(dsGlobal.currentEditingRecipientId);
            //Line added to make sure names are enconded correctly
            recipient.name = unescapeHTMLSpecialCharacters($('#quick-add-name').val());
            recipient.email = $('#quick-add-email').val();
        } else {
            // For saving new recipient
            envelopeId = dsGlobal.envelope.envelopeId;
            recipient.id = '';
            var recipients = dsGlobal.envelope.recipients;
            if(recipients.length === 0){
                recipient.routingOrder = '1';
            } else {
                var lastRoutingOrder = getLastRoutingOrder();
                if(lastRoutingOrder === 1) {
                    recipient.routingOrder = '1';
                } else {
                    recipient.routingOrder = (lastRoutingOrder + 1).toString();
                }
            }
            console.log('Getting recipient values from dsGlobal');
            recipient.name = unescapeHTMLSpecialCharacters(dsGlobal.newRecipientName);
            recipient.email = dsGlobal.newRecipientEmail;
            if(dsGlobal.recipientType === 'add-contact') {
                recipient.recipientType = "Contact";
                recipient.contactId = dsGlobal.newRecipientId;
            } else if(dsGlobal.recipientType === 'add-lead') {
                recipient.recipientType = "Lead";
                recipient.leadId = dsGlobal.newRecipientId;
            } else if(dsGlobal.recipientType === 'add-user') {
                recipient.recipientType = "User";
                recipient.userId = dsGlobal.newRecipientId;
            } else if(dsGlobal.recipientType === 'add-me') {
                recipient.name = unescapeHTMLSpecialCharacters(dsGlobal.currentUserName);
                recipient.email = dsGlobal.currentUserEmail;
                recipient.userId = dsGlobal.currentUserId;
                recipient.recipientType = "User";
            } else if(dsGlobal.recipientType === 'add-quick') {
                recipient.name = unescapeHTMLSpecialCharacters($('#quick-add-name').val());
                recipient.email = $('#quick-add-email').val();
            }
        }
        recipient.accessCode = $('#ds-recipient-access-code').val();
        recipient.note = $('#ds-recipient-note').val();
        recipient.signerType = $('#ds-recipient-signertype-select').val();
        if(recipient.signerType === 'Host in person' || recipient.signerType === 'Host in person - sign now' 
            || recipient.signerType === 'Sign in person') {
            recipient.signInPersonName = $('#ds-recipient-signer-name').val();
        }
        if(recipient.signerType === 'Carbon Copy' || recipient.signerType === 'Certified Delivery' 
            || recipient.signerType === 'Address recipients' || recipient.signerType === 'Manage envelope') {
            recipient.signerRole = '';
            recipient.roleValue = '';
        } else { 
            recipient.signerRole = $('#ds-recipient-signer-role').val().trim();
            recipient.roleValue = '';
            var defaultRoleNames = dsGlobal.envelope.defaultRoleNames;
            var defaultRoleValues = dsGlobal.envelope.defaultRoleValues;
            for(var i = 0; i < defaultRoleNames.length; i++) {
                if(defaultRoleNames[i].trim() == recipient.signerRole) {
                    recipient.roleValue = defaultRoleValues[i];
                }
            }
        }        
        if($('#ds-recipient-signature-dropdown select').is(":visible")) {
            recipient.signatureName = unescapeHTMLSpecialCharacters($('#ds-recipient-signature-dropdown select').val());
        }
        if(dsGlobal.envelope.enableRecipientLanguageSelection === true) {
            recipient.languageCode = $('#ds-recipient-language-select').val();
            var languageSettings = dsGlobal.envelope.languageSettings;
            for(var i = 0; i < languageSettings.length; i++) {
                if(languageSettings[i].LanguageCode === $('#ds-recipient-language-select').val()) {
                    recipient.language = languageSettings[i].Language;
                }
            }
            recipient.emailSubject = $('#ds-recipient-message-subject').val();
            recipient.emailMessage = $('#ds-recipient-message-body').val();
        }        
        try {
            console.log('saveRecipient remote action called, envelopeId='+envelopeId);
            console.log(recipient);
            Visualforce.remoting.Manager.invokeAction(dsGlobal.saveRecipient, envelopeId, recipient, recipientRemoteActionHandler);
        } catch (err) {
            console.log(err);
        }
    });

    //  Click handler for adding recipient
    $('.ds-add-recipient-dropdown').click(function(event){
        console.log('add recipient called, type='+event.target.id);
        showAddRecipientModal(event.target.id);
    });
    
    //  Click handler for adding recipient
    $('.ds-edit-recipient-dropdown').click(function(event){
        var type = event.target.id;
        console.log('edit recipient called, type='+type);
        
        hideErrors();
        hideAll();
        $("#ds-edit-envelope").show();
        $(".ds-add-recipient-modal").show();
        dsGlobal.recipientType = type;
        //dsGlobal.newRecipientName = '';
        //dsGlobal.newRecipientEmail = '';
        // Reset input fields
        $('#ds-recipient-search-text, #ds-recipient-signer-name').val('');
        $('#ds-recipient-search-result ul, #ds-recipient-info').html('');
        $('#ds-recipient-modal-title').text(dsGlobal.editRecipientLabel);
        $('#ds-recipient-info').show();
        $('#ds-edit-recipient-btn').hide();
        $('#ds-recipient-name').attr('class', '');
        $('#ds-change-recipient').attr('class', '');
        $('#ds-quickadd-form, #ds-recipient-signer-name-div').hide();
        $('.ds-recipient-name-error-label, .ds-recipient-email-error-label, .ds-recipient-signature-dropdown-error-label').hide();
        $('#ds-recipient-search-form').show();
        $('#ds-add-new-contact-link, #ds-add-new-contact-form').hide();
        
        if(type === 'edit-contact') {
            $('#ds-search-recipient-modal-title').text(dsGlobal.selectContactLabel);
            $('#ds-recipient-search-text').attr("placeholder", dsGlobal.searchContactsLabel);
            $('#ds-add-new-contact-link').show();
            dsGlobal.action = dsGlobal.searchContacts;
        } else if(type === 'edit-lead') {
            $('#ds-search-recipient-modal-title').text(dsGlobal.selectLeadLabel);
            $('#ds-recipient-search-text').attr("placeholder", dsGlobal.searchLeadsLabel);
            dsGlobal.action = dsGlobal.searchLeads;
        } else if(type === 'edit-user') {
            $('#ds-search-recipient-modal-title').text(dsGlobal.selectUserLabel);
            $('#ds-recipient-search-text').attr("placeholder", dsGlobal.searchUsersLabel);
            dsGlobal.action = dsGlobal.searchUsers;
        } else if(type === 'edit-me') {
            dsGlobal.newRecipientName = dsGlobal.currentUserName;
            dsGlobal.newRecipientEmail = dsGlobal.currentUserEmail;
             $('#ds-recipient-modal-title').text(dsGlobal.addMeLabel);
             dsGlobal.isChangingRecipient = true;
            showEditRecipientModal(dsGlobal.currentEditingRecipientId);
        } 
    });
    
    // Click handler for searching contact/user/lead
    $('#ds-recipient-search-btn').click(function(){
        $('#ds-add-new-contact-form').hide();
        $('#ds-recipient-search-form').show();
        showRecipientModalLoading();
        var keyword = $('#ds-recipient-search-text').val();
        $('#ds-recipient-search-result ul').html('');
        if(keyword === '') {
            $('#ds-recipient-search-result ul').html(dsGlobal.pleaseEnterSearchKeywordLabel);
            hideRecipientModalLoading();
            return;
        }
        console.log('search recipient called, keyword='+keyword+', action='+dsGlobal.action);
        try {
            Visualforce.remoting.Manager.invokeAction(dsGlobal.action, keyword, recipientRemoteActionHandler);
        } catch (err) {
            console.log(err);
        }
    });

    // Click handler for saving new contact
    $('#ds-save-new-contact-btn').click(function() {
        hideErrors();
        if(!validateAddNewContactForm()) {
            return; // stop if add new contact form has invalid data
        }
        showRecipientModalLoading();
        try {
            console.log('saveContact remote action called');
            Visualforce.remoting.Manager.invokeAction(dsGlobal.saveContact, 
                $('#add-new-contact-fname').val(), 
                $('#add-new-contact-lname').val(), 
                $('#add-new-contact-email').val(), 
                $('#add-new-contact-street').val(), 
                $('#add-new-contact-city').val(), 
                $('#add-new-contact-state').val(), 
                $('#add-new-contact-zipcode').val(), 
                $('#add-new-contact-country').val(), 
                $('#add-new-contact-phone').val(), 
                $('#add-new-contact-fax').val(),
                recipientRemoteActionHandler);
        } catch (err) {
            console.log(err);
        }
    });

    // Click handler for changing recipient order number
    $('#recipients section').on('change', '.recipient .number', function(){
        var recipientId = this.parentNode.id;
        var recipient = getRecipientById(recipientId);
        var newRoutingOrder = parseInt(this.value);
        var lastRoutingOrder = getLastRoutingOrder();
        var currentRoutingOrder = parseInt(recipient.routingOrder);
        console.log('change recipient routing order called, id='+recipientId+', currentRoutingOrder='+currentRoutingOrder
                    +', newRoutingOrder='+newRoutingOrder+', lastRoutingOrder='+lastRoutingOrder);

        // Validate Input
        if( isNaN(this.value) 
            || this.value <= 0 
            || (this.value % 1) !== 0 
            || this.value.slice(-1) === '.'
            || parseInt(this.value) === parseInt(recipient.routingOrder) ) {
            console.log('invalid routing order, no change is necessary');
            this.value = recipient.routingOrder;
            return;
        }

        updateRecipientsRoutingOrder(recipient, newRoutingOrder);
    });

    // Click handler for handling contact/user/lead search result selection
    $('#ds-recipient-next-btn').click(function(){
        var selectedValue = $('#ds-recipient-search-result li.selected').attr('value');
        console.log('save search result called, selectedValue='+selectedValue);
        var recipientInfo = selectedValue.split('|');
        if(recipientInfo && recipientInfo.length > 2) {
            dsGlobal.newRecipientName = recipientInfo[0];
            dsGlobal.newRecipientEmail = recipientInfo[1];
            dsGlobal.newRecipientId = recipientInfo[2];
	        if(!dsGlobal.isEditing) {
	            showEditRecipientModal();
	        } else {
	            dsGlobal.isChangingRecipient = true;
	            showEditRecipientModal(dsGlobal.currentEditingRecipientId);
	        }
        }
    });

    // Click handler for the "New Recipient" link
    $('#ds-add-new-contact-link').click(function(){
        $('#ds-recipient-search-form').hide();
        // Reset/empty the form
        $('.add-new-contact-lname-error, .add-new-contact-email-error').hide();
        $('#add-new-contact-lname, #add-new-contact-email').removeClass('error');
        $(  '#add-new-contact-fname,'+
            '#add-new-contact-lname,'+
            '#add-new-contact-email,'+
            '#add-new-contact-street,'+
            '#add-new-contact-city,'+
            '#add-new-contact-state,'+
            '#add-new-contact-zipcode,'+
            '#add-new-contact-country,'+
            '#add-new-contact-phone,'+
            '#add-new-contact-fax').val('');
        $('#ds-add-new-contact-form').show();
    });

    // Click handler for changing language settings
    $('#ds-recipient-language-select').on('change', function () {
        if($('#ds-recipient-language-select').val() !== '') {
            var languageSettings = dsGlobal.envelope.languageSettings;
            for(var i = 0; i < languageSettings.length; i++) {
                if(languageSettings[i].LanguageCode === $('#ds-recipient-language-select').val()) {
                    $('#ds-recipient-message-subject').val(languageSettings[i].DefaultEmailSubject);
                    $('#ds-recipient-message-body').val(languageSettings[i].DefaultEmailBody);
                }
            }
        }
    });

    // Click handler for changing signature name
    $('#ds-recipient-signature-dropdown select').on('change', function () {
         $('.ds-recipient-signature-dropdown-error-label').hide();
    });

    // Click handler for selecting search result
    $('#ds-recipient-search-result ul').on('click', 'li', function() {
        $('#ds-recipient-search-result li.selected').removeClass('selected');
        $(this).addClass('selected');
    });

    // Click handler for seleting signer role
    $('.ds-recipient-signer-role-li').click(function() {
        var signerRole = dsGlobal.envelope.defaultRoleNames[parseInt($(this).val())];
        $('#ds-recipient-signer-role').val(signerRole);
        $('#ds-recipient-signer-role-dropdown').hide();
    });

    // Change handler for the recipient signer type dropdown
    $('#ds-recipient-signertype-select').change(function() {
        console.log('signer type drop-down changed, new value='+$(this).val());
        // Handle special case for 'Host in person' type
        if($(this).val() === 'Host in person' || $(this).val() === 'Host in person - sign now' || $(this).val() === 'Sign in person') {
            $('#ds-recipient-signer-name-div').show();
        } else {
            $('#ds-recipient-signer-name-div').hide();
        }
        // Handle special case for non signer type
        if($(this).val() === 'Carbon Copy' || $(this).val() === 'Certified Delivery' 
            || $(this).val() === 'Address recipients' || $(this).val() === 'Manage envelope') {
            $('.ds-recipient-signer-role-div').hide();
        } else {
            $('.ds-recipient-signer-role-div').show();
            var recipient = getRecipientById(dsGlobal.currentEditingRecipientId);
            if(typeof(recipient) !== 'undefined' &&  recipient !== null) {
                if(typeof(recipient.signerRole) !== 'undefined' && recipient.signerRole !== null && recipient.signerRole !== '') {
                    $('#ds-recipient-signer-role').val(recipient.signerRole);
                } else {
                    $('#ds-recipient-signer-role').val(getNextAvailableSignerRole());
                }
            }
        }
    });

    // Change handler for entering Last Name in the New Contact form
    $('#add-new-contact-lname').keyup(function() {
        if($(this).val()) {
            $('#add-new-contact-lname').removeClass('error');
            $('.add-new-contact-lname-error').hide();
        } else {
            $('#add-new-contact-lname').addClass('error');
            $('.add-new-contact-lname-error').show();
        }
    });

    // Change handler for entering Email in the New Contact form
    $('#add-new-contact-email').keyup(function() {
        if($(this).val()) {
            $('#add-new-contact-email').removeClass('error');
            $('.add-new-contact-email-error').hide();
        } else {
            $('#add-new-contact-email').addClass('error');
            $('.add-new-contact-email-error').text(dsGlobal.fieldRequiredLabel).show();
        }
    });

    // Change handler for entering Name in the Quick Add form
    $('#quick-add-name').keyup(function() {
        if($(this).val()) {
            $('#quick-add-name').removeClass('error');
            $('.ds-recipient-name-error-label').hide();
        } else {
            $('#quick-add-name').addClass('error');
            $('.ds-recipient-name-error-label').show();
        }
    });

    // Change handler for entering Email in the Quick Add form
    $('#quick-add-email').keyup(function() {
        if($(this).val()) {
            $('#quick-add-email').removeClass('error');
            $('.ds-recipient-email-error-label').hide();
        } else {
            $('#quick-add-email').addClass('error');
            $('.ds-recipient-email-error-label').text(dsGlobal.fieldRequiredLabel).show();
        }
    });

    $('#message-document-title').click(function() {
        if ($('#message').hasClass('expanded')) {
            $('#message').removeClass('expanded');
            $('#message').addClass('collapsed');
        } else {
            $('#message').removeClass('collapsed');
            $('#message').addClass('expanded');
        }
    });
    
    $('#settings-document-title').click(function() {
        if ($('#settings').hasClass('expanded')) {
            $('#settings').removeClass('expanded');
            $('#settings').addClass('collapsed');
        } else {
            $('#settings').removeClass('collapsed');
            $('#settings').addClass('expanded');
        }
    });
    
    $('#sendReminderDays').change(function(){
        var days = this.value;
        if(isNaN(days) || days < 0 || (days % 1) !== 0 || days.slice(-1) === '.') {
            this.value = dsGlobal.envelope.sendReminderDays;
            return;
        }
    });
    
    $('#sendReminderRepeatDays').change(function(){
        var days = this.value;
        if(isNaN(days) || days < 0 || (days % 1) !== 0 || days.slice(-1) === '.') {
            this.value = dsGlobal.envelope.sendReminderRepeatDays;
            return;
        }
    });
    
    $('#expireEnvelopeDays').change(function(){
        var days = this.value;
        if(isNaN(days) || days < 0 || (days % 1) !== 0 || days.slice(-1) === '.') {
            this.value = dsGlobal.envelope.expireEnvelopeDays;
            return;
        }
    });
    
    $('#warnExpireDays').change(function(){
        var days = this.value;
        if(isNaN(days) || days < 0 || (days % 1) !== 0 || days.slice(-1) === '.') {
            this.value = dsGlobal.envelope.warnExpireDays;
            return;
        }
    });
    
    if (dsGlobal.showAddAttachmentWindow === '1') {
    	$('#add-attachment').click();
    }
});
