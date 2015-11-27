//
//  Shabal.swift
//  Showdown
//
//  Created by Steven Harvath on 11/24/15.
//  Copyright © 2015 harvathian. All rights reserved.
//

import Foundation

public func shabal(msg: String) -> (String) -> String {
    var B = [Int]()
    var M = [Int]()
    var A = [Int]()
    var C = [Int]()
    
    let circ = { (x: Int, n: Int) -> Int in
        return (x << n) + (x >> (32 - n))
    }
    
    let hex = { (n: Int) -> String in
        let stringify: String = "00" + String(n, radix: 16)
        let slice = stringify.endIndex.advancedBy(-2)
        let finalHex = stringify.substringToIndex(slice)
        return finalHex
    }
    
    let output_fn = { (n: Int) -> String in
        return hex(n & 255) + hex(n >> 8) + hex(n >> 16) + hex(n >> 24)
    }
    
    let shabal_f = { (start: Int, w0: Int, w1: Int) -> Void in
        var i: Int
        var j: Int
        var k: Int
        for (i = 0; i < 16; i += 1) {
           B[i] = circ(B[i] + M[start + i], 17)
        }
        
        A[0] ^= w0
        A[1] ^= w1
        
        for (j = 0; j < 3; j += 1) {
            for (i = 0; i < 16; i += 1) {
                k = (i + 16 * j) % 12;
                A[k] = 3 * (A[k] ^ 5 * circ(A[(k + 11) % 12], 15) ^ C[(24 - i) % 16]) ^
                    B[(i + 13) % 16] ^ (B[(i + 9) % 16] & ~B[(i + 6) % 16]) ^ M[start + i];
                B[i] = circ(B[i], 1) ^ ~A[k];
            }
        }
        for (j = 0; j < 36; j += 1) {
            A[j % 12] += C[(j + 3) % 16];
        }
        for (i = 0; i < 16; i += 1) {
            C[i] -= M[start + i];
        }
    }
}

























