//
//  CCConstants.m
//  Demo
//
//  Created by Wei Kong on 12/20/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCConstants.h"

// backend url
NSString * const CC_BACKEND_URL = @"http://api.cocoafish.com:8000/v1";

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
NSString * const CC_JSON_META_METHOD_SHOW_PLACE = @"showPlace";
NSString * const CC_JSON_META_METHOD_REGISTER_USER = @"createUser";
NSString * const CC_JSON_META_METHOD_LOGIN = @"loginUser";
NSString * const CC_JSON_META_METHOD_LOGOUT = @"logoutUser";
NSString * const CC_JSON_META_METHOD_DELETE_USER = @"deleteUser";
NSString * const CC_JSON_META_METHOD_SHOW_USER = @"showUser";
NSString * const CC_JSON_META_METHOD_SHOW_CURRENT_USER = @"showCurrentUser";
NSString * const CC_JSON_META_METHOD_SHOW_CHECKINS_ME = @"showCheckinsMe";
NSString * const CC_JSON_META_METHOD_SHOW_CHECKINS = @"searchCheckins";
NSString * const CC_JSON_META_METHOD_CHECKIN_PLACE = @"createCheckin";
NSString * const CC_JSON_META_METHOD_CREATE_STATUS = @"createStatus";
NSString * const CC_JSON_META_METHOD_SHOW_STATUSES_ME = @"showStatuesesMe";
NSString * const CC_JSON_META_METHOD_SHOW_STATUSES = @"searchStatuses";
NSString * const CC_JSON_META_METHOD_UPLOAD_PHOTO = @"uploadPhoto";
NSString * const CC_JSON_META_METHOD_SHOW_PHOTOS = @"showPhotos";
NSString * const CC_JSON_META_METHOD_SHOW_PHOTO = @"showPhoto";
NSString * const CC_JSON_META_METHOD_STORE_VALUE = @"storeValue";

// response
NSString * const CC_JSON_RESPONSE = @"response";
NSString * const CC_JSON_RESPONSES = @"responses";

// pagination
NSString * const CC_JSON_PAGINATION = @"pagination";
NSString * const CC_JSON_TOTAL_PAGE = @"total_pages";
NSString * const CC_JSON_TOTAL_COUNT = @"total_results";
NSString * const CC_JSON_PER_PAGE_COUNT = @"page";
NSString * const CC_JSON_CUR_PAGE = @"cur_page";

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

// CCPlace
NSString * const CC_JSON_PLACE = @"place";
NSString * const CC_JSON_PLACES = @"places";
NSString * const CC_JSON_PLACE_NAME = @"name";
NSString * const CC_JSON_PLACE_ADDRESS_1 = @"address_1";
NSString * const CC_JSON_PLACE_ADDRESS_2 = @"address_2";
NSString * const CC_JSON_PLACE_CROSS_STREET = @"cross_street";
NSString * const CC_JSON_PLACE_CITY = @"city";
NSString * const CC_JSON_PLACE_STATE = @"state";
NSString * const CC_JSON_PLACE_COUNTRY = @"country";
NSString * const CC_JSON_PHONE = @"phone";
NSString * const CC_JSON_LATITUDE = @"lat";
NSString * const CC_JSON_LONGITUDE = @"lng";

// CCCheckin
NSString * const CC_JSON_CHECKINS = @"checkins";
NSString * const CC_JSON_MESSAGE = @"message";

// CCStatus
NSString * const CC_JSON_STATUSES = @"statuses";
NSString * const CC_JSON_STATUS = @"status";

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
