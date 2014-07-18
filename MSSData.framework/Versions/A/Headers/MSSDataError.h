//
//  MSSDataError.h
//  
//
//  Created by Elliott Garcea on 2014-06-04.
//
//

#ifndef _MSSDataError_h
#define _MSSDataError_h

OBJC_EXTERN NSString *const kMSSOAuthCredentialID;
OBJC_EXTERN NSString *const kMSSDataErrorDomain;

typedef NS_ENUM(NSInteger, MSSDataErrorCode) {
    MSSDataNoClientIDError,
    MSSDataNoClientSecretError,
    MSSDataNoOpenIDConnectURLError,
    MSSDataFailedAuthenticationError,
    MSSDataMalformedURLError,
    MSSDataEmptyResponseData,
    MSSDataMissingAccessToken,
    MSSDataAuthorizationRequired,
    MSSDataObjectIDRequired,
};

#endif
