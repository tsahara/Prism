//
//  Helper.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 2016/11/02.
//  Copyright © 2016 Tomoyuki Sahara. All rights reserved.
//

import Foundation
//import Security
import ServiceManagement

@objc protocol PrismHelperProtocol {
    func getVersion(_ withReply: (NSString) -> Void)
    //func openBpf(withReply: (Int, Int) -> Void)
}

class Helper {
    let HelperVersion = "1.0.0"
    let ServiceName   = "net.caddr.PrismHelper"

    func connect(callback: @escaping (Bool) -> Void) {
        let xpc = NSXPCConnection(machServiceName: ServiceName, options: .privileged)
        xpc.remoteObjectInterface = NSXPCInterface(with: PrismHelperProtocol.self)
        xpc.resume()
        
        let helper = xpc.remoteObjectProxyWithErrorHandler({
            err in
            print("xpc error =>\(err)")
            callback(false)
        }) as! PrismHelperProtocol
        
        helper.getVersion({
            version in
            print("get version => \(version), pid=\(xpc.processIdentifier)")
            callback(version as String == self.HelperVersion)
        })
    }

    func install() {
        var authref: AuthorizationRef? = nil

        var status = AuthorizationCreate(nil, nil, AuthorizationFlags(), &authref)
        if (status != OSStatus(errAuthorizationSuccess)) {
            print("AuthorizationCreate failed.")
            return;
        }
        
        var item = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value: nil, flags: 0)
        var rights = AuthorizationRights(count: 1, items: &item)
        let flags = AuthorizationFlags([.interactionAllowed, .extendRights])
        
        status = AuthorizationCopyRights(authref!, &rights, nil, flags, nil)
        if (status != OSStatus(errAuthorizationSuccess)) {
            print("AuthorizationCopyRights failed.")
            return;
        }
        
        var cfError: Unmanaged<CFError>?
        let success = SMJobBless(kSMDomainSystemLaunchd, ServiceName as CFString, authref, &cfError)
        if success {
            print("SMJobBless suceeded")
        } else {
            print("SMJobBless failed: \(cfError!)")
        }
        
        //getversion()
    }
    

}
