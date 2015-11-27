//
//  Cubehash.swift
//  Showdown
//
//  Created by Steven Harvath on 11/22/15.
//  Copyright © 2015 harvathian. All rights reserved.
//

import Foundation

public func cubeHash(str: String) -> (String) -> String {
    let out_length = 256
    var state = [out_length / 8, 32, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    var i: Int = 0
    var j: Int = 0
    var tmp: Int = 0
    
    let plus_rotate = { ( r: Int, s: Int) -> Void in
        for (i = 0; i < 16; i += 1) {
            state[16 + i] += state[i]
            state[i] = (state[i] << r) ^ (state[i] >> s)
        }
    }
    
    let swap_xor_swap = { (mask1: Int, mask2: Int) -> Void in
        for (i = 0; i < 16; i += 1) {
            if (i & mask1 != 0) {
                j = i ^ mask1
                tmp = state[i] ^ state[j + 16]
                state[i] = state[j] ^ state[i + 16]
                state[j] = tmp
            }
        }
        
        for (i = 16; i < 32; i += 1) {
            if (i & mask2 != 0) {
                j = i ^ mask2
                tmp = state[i]
                state[i] = state[j]
                state[j] = tmp
            }
        }
    }
    
    var r: Int = 0
    
    let round = { (var n: Int) -> Void in
        n *= 16
        for (r = 0; r < n; r += 1) {
            plus_rotate(7, 25)
            swap_xor_swap(8, 2)
            plus_rotate(11, 21)
            swap_xor_swap(4, 1)
        }
    }
    
    round(10)
    
    let initial_state = state.slice(0)
    
    let hex = { (n: Int) -> String in
        let stringify: String = "00" + String(n, radix: 16)
        let slice = stringify.endIndex.advancedBy(-2)
        let finalHex = stringify.substringToIndex(slice)
        return finalHex
    }
    
    let output_fn = { (n: Int) -> String in
        return hex(n & 255) + hex(n >> 8)  + hex(n >> 16) + hex(n >> 24)
    }
    
    let hash = { (var str: String) -> String in
        state = initial_state.slice(0)
        str += "\u{0080}"
        var block: Int = 0
        var i: Int = 0
        
        while (str.characters.count % 16 > 0) {
            str += "\u{0000}"
        }
        
        var input = [Int]()
        
        for (i = 0; i < str.characters.count; i += 2) {
            input.append(str.characters.count.advancedBy(i) + str.characters.count.advancedBy(i + 1) * 0x10000)
        }
        
        for (block = 0; block < input.count; block += 8) {
            for (i = 0; i < 8; i += 1) {
                state[i] ^= input[block + i]
            }
            round(1)
        }
        state[31] ^= 1
        round(10)
        let statefulMap = state.map(output_fn).joinWithSeparator("")
        return statefulMap.substringWithRange(Range<String.Index>(start: str.startIndex, end: str.endIndex.advancedBy(out_length / 4)))
    }
 
    return hash
}



























