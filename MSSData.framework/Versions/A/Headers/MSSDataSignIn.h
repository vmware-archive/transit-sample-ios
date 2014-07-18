//
//  MSSDataSignIn.h
//  
//
//  Created by DX123-XL on 2014-05-20.
//
//

#import <Foundation/Foundation.h>

@class AFOAuthCredential, AFOAuth2Client;

/**
 The 'MSSSignInDelegate' protocol is adopted by an object that manages the OpenID Connect authorization process.
 */
@protocol MSSSignInDelegate <NSObject>

/**
 The authorization has finished and is successful if 'error' is 'nil'.
 */
- (void)finishedWithAuth:(AFOAuthCredential *)auth
                   error:(NSError *)error;

/**
 Finished disconnecting user from the app.
 The operation was successful if 'error' is 'nil'.
 */
@optional
- (void)didDisconnectWithError:(NSError *)error;

@end

@interface MSSDataSignIn : NSObject

///----------------------------------------
/// @name Getting Locally Stored Credential
///----------------------------------------

/**
 The credential object for the current user.
 */
@property(nonatomic, strong, readonly) AFOAuthCredential *credential;

///----------------------------------------------
/// @name Managing OpenID Connect Server Settings
///----------------------------------------------

/**
 The client ID of the app from the Open ID Connection console.
 Must set for sign-in to work.
 */
@property(nonatomic, copy) NSString *clientID;

/**
 The client secret of the app from the Open ID Connection console.
 Must be set for sign-in to work.
 */
@property(nonatomic, copy) NSString *clientSecret;

/**
 The OpenID Connect Authentication UI URL endpoint
 Must be set for sign-in to work.
 */
@property(nonatomic, copy) NSString *openIDConnectURL;

/**
 The MSS Data Service URL endpoint
 Must be set for MSSDataObject fetch/save/delete to work.
 */
@property(nonatomic, copy) NSString *dataServiceURL;

/**
 The API scopes requested by the app in an array of NSStrings.
 The default value is @[ @"openid", @"offline_access" ].
 */
@property(nonatomic, copy) NSArray *scopes;

///----------------------------------------------
/// @name Managing OpenID Connect Server Settings
///----------------------------------------------

/**
 The object to be notified when authentication is finished.
 */
@property(nonatomic, weak) id<MSSSignInDelegate> delegate;

/**
 Returns a shared MSSDataSignIn instance.
 
 @return The MSSDataSignIn shared instance
 */
+ (MSSDataSignIn *)sharedInstance;

/**
 Checks whether the user has either currently signed in or has previous
 authentication saved in keychain.
 
 @return A BOOL representing whether Authentication credentials have been saved in the Keychain
 */
- (BOOL)hasAuthInKeychain;

///-----------------------------------------------------
/// @name Authenticating User with OpenID Connect Server
///-----------------------------------------------------

/**
 Attempts to authenticate silently without user interaction.
 Returns 'YES' and calls the delegate if the user has either currently signed
 in or has previous authentication saved in keychain.
 Note that if the previous authentication was revoked by the user, this method
 still returns 'YES' but 'finishedWithAuth:error:' callback will indicate
 that authentication has failed.
 
 @return A BOOL representing whether authentication can be attempted without user interaction

 */
- (BOOL)trySilentAuthentication;

/**
 Starts the authentication process. Use Mobile Safari for
 authentication. The delegate will be called at the end of this process.
 Note that this method should not be called when the app is starting up,
 (e.g in application:didFinishLaunchingWithOptions:). Instead use the
 'trySilentAuthentication' method.
 */
- (void)authenticate;

///-----------------------------------------------------
/// @name Handle Redirect URI from OpenID Connect Server
///-----------------------------------------------------

/**
 This method should be called from the 'UIApplicationDelegate's
 'application:openURL:sourceApplication:annotation'. Returns 'YES' if
 'MSSDataSignIn' handled this URL.
 
 @param url The redirect URI defined on the OpenID Connect server to return to the application from the Safari Browser
 @param sourceApplication  The bundle ID of the app that is requesting your app to open the URL (url).
 @param A property-list object supplied by the source app to communicate information to the receiving app.
 
 @return YES if the delegate successfully handled the request or NO if the attempt to open the URL resource failed.
 */
- (BOOL)handleURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
       annotation:(id)annotation;


///-------------------------------------
/// @name Revoking Client Authentication
///-------------------------------------

/**
 Removes the OAuth 2.0 token from the keychain.
 */
- (void)signOut;

/**
 Disconnects the user from the app and revokes previous authentication.
 If the operation succeeds, the OAuth 2.0 token is also removed from keychain.
 The token is needed to disconnect so do not call 'signOut' if 'disconnect' is
 to be called.
 */
- (void)disconnect;

@end
