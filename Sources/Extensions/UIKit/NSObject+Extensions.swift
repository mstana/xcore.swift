//
// NSObject+Extensions.swift
//
// Copyright © 2018 Zeeshan Mian
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

extension NSObject {
    /// Returns the value for the property identified by a given key.
    ///
    /// The search pattern that `valueForKey:` uses to find the correct value
    /// to return is described in **Accessor Search Patterns** in **Key-Value Coding Programming Guide**.
    ///
    /// - parameter key: The name of one of the receiver's properties.
    /// - returns: The value for the property identified by key.
    open func safeValue(forKey key: String) -> Any? {
        let mirror = Mirror(reflecting: self)

        for child in mirror.children.makeIterator() where child.label == key {
            return child.value
        }

        return nil
    }

    /// Return `true` if the `self` has the property of given `name`; otherwise, `false`.
    open func hasProperty(withName name: String) -> Bool {
        return safeValue(forKey: name) != nil
    }
}