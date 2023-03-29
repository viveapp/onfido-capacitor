//
//  Response.swift
//  Plugin
//
//  Created by Polo Swelsen on 28/03/2023.
//  Copyright © 2023 ilionx B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(OnfidoPlugin, "OnfidoPlugin",
           CAP_PLUGIN_METHOD(start, CAPPluginReturnPromise);
)
