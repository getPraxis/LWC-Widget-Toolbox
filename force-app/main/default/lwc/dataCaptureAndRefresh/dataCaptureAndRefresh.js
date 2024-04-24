import { LightningElement, api, wire } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { publish, MessageContext } from 'lightning/messageService';
import { RefreshEvent } from "lightning/refresh";
import userId from '@salesforce/user/Id';
import LightningConfirm from 'lightning/confirm';


export default class DataCaptureAndRefresh extends LightningElement {

    @api objectApiName          = undefined;    
    @api recordId               = undefined;
    @api notificationType       = undefined;
    @api refreshType            = undefined;
    @api fieldToMonitor         = undefined;
    @api fieldToMonitorValue    = undefined;
    @api validatePublishedUser  = false; 
    @wire(MessageContext)       messageContext;
    channelName                 = undefined;

    dataCaptureSubscribed = false;
    stringedMessage = '';
    isPlatformNotification = false;
    dataCaptureSubscription = undefined;
    refreshContainerID;



    renderedCallback() {
        if(!this.dataCaptureSubscribed) {
            this.channelName = this.buildChannelName(this.objectApiName);
            this.dataCaptureSubscribed = !this.dataCaptureSubscribed;
            this.handleSubscribe();
        }
    }

    connectedCallback() {
        if(this.notificationType === "Platform Event") {
            this.isPlatformNotification = true;
        };
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    buildChannelName(objectName) {
        return  '/data/' + objectName + 'ChangeEvent';
    }

    handleSubscribe() {

        const messageCallback = (response) => {
            this.handleMessage(response);
        };

        const channelName = this.isPlatformNotification ? "/event/Object_Refresh_Notification__e" : this.channelName;
        subscribe(channelName, -1, messageCallback).then(response => {
            this.dataCaptureSubscription = response;
        });
    }

    handleUnsubscribe() {
        unsubscribe(this.dataCaptureSubscription, (response) => {
        });
    }

    publishRefresh() {
        if(this.refreshType === "Browser refresh") {
            this.performBrowserRefresh()
        } else if(this.refreshType === "LWC refresh") {
            console.log('Preform dispatch');
            this.performLWCRefresh()
        }
    }

    performBrowserRefresh() {
        location.reload();
    }

    performLWCRefresh() {
        console.log('Firing event');
        this.dispatchEvent(new RefreshEvent());
    }

    async handleMessage(response) {
        if (response) {
            console.log('UserId: ', userId);
            console.log('Response: ', JSON.stringify(response));
            if(this.isPlatformNotification) {
                if(response.data.payload.sObjectName__c === this.objectApiName && response.data.payload.Record_ID__c === this.recordId) {
                    if(this.validatePublishedUser) {
                        if(response.data.payload.CreatedById !== userId) {
                            const result = await LightningConfirm.open({
                                message: '',
                                variant: 'header',
                                label: 'The record you are viewing has been updated by a different user, would you like to refresh the page to see the latest data?', 
                                theme: 'shade'

                            });
                            if(!result) {
                                return;
                            }
                        }
                    }   
                    this.publishRefresh();
                }
            } else if (response.hasOwnProperty('data')) { /*This else is for Data Capture */
                const responsePayload = response.data.payload;
                console.log('Payload: ', JSON.stringify(responsePayload));
                console.log('Response: ', JSON.stringify(responsePayload.ChangeEventHeader.changeType));
                const changedFields = responsePayload.ChangeEventHeader.changedFields;
                if(responsePayload.hasOwnProperty(this.fieldToMonitor)) { 
                    const fieldValue = responsePayload[this.fieldToMonitor];
                    if(fieldValue === this.fieldToMonitorValue) {
                        console.log('fieldValue: ', fieldValue);
                        this.publishRefresh();
                    }
                }
            }
        }
    }
}