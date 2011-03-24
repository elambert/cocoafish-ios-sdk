//
//  CCConstants.h
//  Demo
//
//  Created by Wei Kong on 12/20/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

// Backend URL
extern NSString * const CC_BACKEND_URL;

// Server related
extern NSString * const CC_DOMAIN;
extern const NSInteger CC_SERVER_ERROR;
extern const NSInteger CC_TIMEOUT;

// meta tags
extern NSString * const CC_STATUS_OK;
extern NSString * const CC_JSON_META;
extern NSString * const CC_JSON_META_CODE;
extern NSString * const CC_JSON_META_STATUS;
extern NSString * const CC_JSON_META_MESSAGE;

// meta method tags
extern NSString * const CC_JSON_META_METHOD;
extern NSString * const CC_JSON_META_METHOD_COMPOUND;
extern NSString * const CC_JSON_META_METHOD_CREATE_PLACE;
extern NSString * const CC_JSON_META_METHOD_DELETE_PLACE;
extern NSString * const CC_JSON_META_METHOD_GET_PLACES;
extern NSString * const CC_JSON_META_METHOD_SHOW_PLACES;
extern NSString * const CC_JSON_META_METHOD_REGISTER_USER;
extern NSString * const CC_JSON_META_METHOD_LOGIN;
extern NSString * const CC_JSON_META_METHOD_LOGOUT;
extern NSString * const CC_JSON_META_METHOD_DELETE_USER;
extern NSString * const CC_JSON_META_METHOD_SHOW_USERS;
extern NSString * const CC_JSON_META_METHOD_SHOW_CURRENT_USER;
extern NSString * const CC_JSON_META_METHOD_SHOW_CHECKINS_ME;
extern NSString * const CC_JSON_META_METHOD_SHOW_CHECKINS;
extern NSString * const CC_JSON_META_METHOD_CHECKIN_PLACE;
extern NSString * const CC_JSON_META_METHOD_CREATE_STATUS;
extern NSString * const CC_JSON_META_METHOD_SHOW_STATUSES_ME;
extern NSString * const CC_JSON_META_METHOD_SHOW_STATUSES;
extern NSString * const CC_JSON_META_METHOD_CREATE_PHOTO;
extern NSString * const CC_JSON_META_METHOD_SEARCH_PHOTOS;
extern NSString * const CC_JSON_META_METHOD_SHOW_PHOTOS;
extern NSString * const CC_JSON_META_METHOD_DELETE_PHOTO;
extern NSString * const CC_JSON_META_METHOD_SET_KEY_VALUE;
extern NSString * const CC_JSON_META_METHOD_GET_KEY_VALUE;
extern NSString * const CC_JSON_META_METHOD_APPEND_KEY_VALUE;
extern NSString * const CC_JSON_META_METHOD_DELETE_KEY_VALUE;

// response
extern NSString * const CC_JSON_RESPONSE;
extern NSString * const CC_JSON_RESPONSES;

// pagination
extern NSString * const CC_JSON_PAGINATION;
extern NSString * const CC_JSON_TOTAL_PAGE;
extern NSString * const CC_JSON_TOTAL_COUNT;
extern NSString * const CC_JSON_PER_PAGE_COUNT;
extern NSString * const CC_JSON_CUR_PAGE;

// CCObject
extern NSString * const CC_JSON_OBJECT_ID;
extern NSString * const CC_JSON_CREATED_AT;
extern NSString * const CC_JSON_UPDATED_AT;

// CCUser
extern NSString * const CC_JSON_USER;
extern NSString * const CC_JSON_USERS;
extern NSString * const CC_JSON_USER_EMAIL;
extern NSString * const CC_JSON_USERNAME;
extern NSString * const CC_JSON_USER_FIRST;
extern NSString * const CC_JSON_USER_LAST;
extern NSString * const CC_JSON_USER_FACEBOOK_AUTHORIZED;
extern NSString * const CC_JSON_USER_FACEBOOK_ACCESS_TOKEN;

// CCPlace
extern NSString * const CC_JSON_PLACE;
extern NSString * const CC_JSON_PLACES;
extern NSString * const CC_JSON_PLACE_NAME;
extern NSString * const CC_JSON_PLACE_ADDRESS;
extern NSString * const CC_JSON_PLACE_CROSS_STREET;
extern NSString * const CC_JSON_PLACE_CITY;
extern NSString * const CC_JSON_PLACE_STATE;
extern NSString * const CC_JSON_PLACE_POSTAL_CODE;
extern NSString * const CC_JSON_PLACE_COUNTRY;
extern NSString * const CC_JSON_PHONE;
extern NSString * const CC_JSON_WEBSITE;
extern NSString * const CC_JSON_TWITTER;
extern NSString * const CC_JSON_LATITUDE;
extern NSString * const CC_JSON_LONGITUDE;

// CCCheckin
extern NSString * const CC_JSON_CHECKINS;
extern NSString * const CC_JSON_MESSAGE;

// CCPhoto
extern NSString * const CC_JSON_PHOTO;
extern NSString * const CC_JSON_PHOTOS;
extern NSString * const CC_JSON_FILENAME;
extern NSString * const CC_JSON_SIZE;
extern NSString * const CC_JSON_COLLECTION_NAME;
extern NSString * const CC_JSON_MD5;
extern NSString * const CC_JSON_PROCESSED;
extern NSString * const CC_JSON_CONTENT_TYPE;
extern NSString * const CC_JSON_URLS;
extern NSString * const CC_JSON_TAKEN_AT;

// CCStatus
extern NSString * const CC_JSON_STATUSES;

// CCNameValuePair
extern NSString * const CC_JSON_KEY_VALUES;
extern NSString * const CC_JSON_KEY;
extern NSString * const CC_JSON_VALUE;
