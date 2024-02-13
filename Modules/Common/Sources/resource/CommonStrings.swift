//
//  Strings.swift
//  ShopliveCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
public enum Strings_SL {
    public enum Error {
        public enum Msg {
            /// Please try again later.
            public static let base = "Please try again later."
            /// Please try again later.
            public static let empty = "Please try again later."
            /// Login failure
            public static let login = "Login failure"
            /// No internet connection.
            public static let noInternet = "No internet connection."
            public enum Server {
                /// Network response timed out.
                /// Please try again.
                public static let timeout = "Network response timed out. \nPlease try again."
                /// A server error has occurred.
                public static let unknown = "A server error has occurred."
            }
        }
    }
}
