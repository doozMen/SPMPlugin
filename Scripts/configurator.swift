#!/usr/bin/env swift
// https://rderik.com/blog/using-swift-for-scripting/
import Foundation

print("hello, world! \(ProcessInfo().arguments.last ?? "no brand")")
