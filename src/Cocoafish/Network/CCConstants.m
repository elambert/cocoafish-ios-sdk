//
//  CCConstants.m
//  Demo
//
//  Created by Wei Kong on 12/20/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCConstants.h"

// backend url
NSString * const CC_BACKEND_URL = @"http://api.cocoafish.com/v1";

// server related
NSString * const CC_DOMAIN = @"Cocoafish";
const NSInteger CC_SERVER_ERROR = -1;
const NSInteger CC_TIMEOUT = 30;

// meta 
NSString * const CC_STATUS_OK = @"ok";
NSString * const CC_JSON_META = @"meta";
NSString * const CC_JSON_META_CODE = @"code";
NSString * const CC_JSON_META_STATUS = @"stat";
NSString * const CC_JSON_META_MESSAGE = @"message";

// meta methods
NSString * const CC_JSON_META_METHOD = @"method";
NSString * const CC_JSON_META_METHOD_COMPOUND = @"compound";
NSString * const CC_JSON_META_METHOD_GET_PLACES = @"searchPlaces";
NSString * const CC_JSON_META_METHOD_SHOW_PLACES = @"showPlaces";
NSString * const CC_JSON_META_METHOD_CREATE_PLACE = @"createPlace";
NSString * const CC_JSON_META_METHOD_DELETE_PLACE = @"deletePlace";
NSString * const CC_JSON_META_METHOD_REGISTER_USER = @"createUser";
NSString * const CC_JSON_META_METHOD_LOGIN = @"loginUser";
NSString * const CC_JSON_META_METHOD_LOGOUT = @"logoutUser";
NSString * const CC_JSON_META_METHOD_DELETE_USER = @"deleteUser";
NSString * const CC_JSON_META_METHOD_SHOW_USERS = @"showUsers";
NSString * const CC_JSON_META_METHOD_SHOW_CURRENT_USER = @"showMe";
NSString * const CC_JSON_META_METHOD_SHOW_CHECKINS_ME = @"showCheckinsMe";
NSString * const CC_JSON_META_METHOD_SHOW_CHECKINS = @"searchCheckins";
NSString * const CC_JSON_META_METHOD_CHECKIN_PLACE = @"createCheckin";
NSString * const CC_JSON_META_METHOD_CREATE_STATUS = @"createStatus";
NSString * const CC_JSON_META_METHOD_SHOW_STATUSES_ME = @"showStatusesMe";
NSString * const CC_JSON_META_METHOD_SHOW_STATUSES = @"searchStatuses";
NSString * const CC_JSON_META_METHOD_CREATE_PHOTO = @"createPhoto";
NSString * const CC_JSON_META_METHOD_SEARCH_PHOTOS = @"searchPhotos";
NSString * const CC_JSON_META_METHOD_DELETE_PHOTO = @"deletePhoto";
NSString * const CC_JSON_META_METHOD_SHOW_PHOTOS = @"showPhotos";
NSString * const CC_JSON_META_METHOD_SET_KEY_VALUE = @"setKeyvalue";
NSString * const CC_JSON_META_METHOD_GET_KEY_VALUE = @"getKeyvalue";
NSString * const CC_JSON_META_METHOD_APPEND_KEY_VALUE = @"appendKeyvalue";
NSString * const CC_JSON_META_METHOD_DELETE_KEY_VALUE = @"deleteKeyvalue";

// response
NSString * const CC_JSON_RESPONSE = @"response";
NSString * const CC_JSON_RESPONSES = @"responses";

// pagination
NSString * const CC_JSON_PAGINATION = @"pagination";
NSString * const CC_JSON_TOTAL_PAGE = @"total_pages";
NSString * const CC_JSON_TOTAL_COUNT = @"total_results";
NSString * const CC_JSON_PER_PAGE_COUNT = @"per_page";
NSString * const CC_JSON_CUR_PAGE = @"page";

// CCObject
NSString * const CC_JSON_OBJECT_ID = @"id";
NSString * const CC_JSON_CREATED_AT = @"created_at";
NSString * const CC_JSON_UPDATED_AT = @"updated_at";

// CCUser
NSString * const CC_JSON_USER = @"user";
NSString * const CC_JSON_USERS = @"users";
NSString * const CC_JSON_USER_EMAIL = @"email";
NSString * const CC_JSON_USERNAME = @"username";
NSString * const CC_JSON_USER_FIRST = @"first_name";
NSString * const CC_JSON_USER_LAST = @"last_name";
NSString * const CC_JSON_USER_FACEBOOK_AUTHORIZED = @"facebook_authorized";
NSString * const CC_JSON_USER_FACEBOOK_ACCESS_TOKEN = @"facebook_access_token";

// CCPlace
NSString * const CC_JSON_PLACE = @"place";
NSString * const CC_JSON_PLACES = @"places";
NSString * const CC_JSON_PLACE_NAME = @"name";
NSString * const CC_JSON_PLACE_ADDRESS = @"address";
NSString * const CC_JSON_PLACE_CROSS_STREET = @"cross_street";
NSString * const CC_JSON_PLACE_CITY = @"city";
NSString * const CC_JSON_PLACE_STATE = @"state";
NSString * const CC_JSON_PLACE_POSTAL_CODE = @"postal_code";
NSString * const CC_JSON_PLACE_COUNTRY = @"country";
NSString * const CC_JSON_PHONE = @"phone";
NSString * const CC_JSON_WEBSITE = @"website";
NSString * const CC_JSON_TWITTER = @"twitter";
NSString * const CC_JSON_LATITUDE = @"latitude";
NSString * const CC_JSON_LONGITUDE = @"longitude";

// CCCheckin
NSString * const CC_JSON_CHECKINS = @"checkins";
NSString * const CC_JSON_MESSAGE = @"message";

// CCStatus
NSString * const CC_JSON_STATUSES = @"statuses";

// CCPhoto
NSString * const CC_JSON_PHOTO = @"photo";
NSString * const CC_JSON_PHOTOS = @"photos";
NSString * const CC_JSON_FILENAME = @"filename";
NSString * const CC_JSON_SIZE = @"size";
NSString * const CC_JSON_COLLECTION_NAME = @"collection_name";
NSString * const CC_JSON_MD5 = @"md5";
NSString * const CC_JSON_PROCESSED = @"processed";
NSString * const CC_JSON_CONTENT_TYPE = @"content_type";
NSString * const CC_JSON_URLS = @"urls";
NSString * const CC_JSON_TAKEN_AT = @"taken_at";

// CCNameValuePair
NSString * const CC_JSON_KEY_VALUES = @"keyvalues";
NSString * const CC_JSON_KEY = @"name";
NSString * const CC_JSON_VALUE = @"value";
