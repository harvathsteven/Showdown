//
//  BLAKE32.swift
//  Showdown
//
//  Created by Steven Harvath on 11/21/15.
//  Copyright © 2015 harvathian. All rights reserved.
//

import Foundation

public func blake32(msg: String, salt: [Int]) -> ((String, [Int]) -> String) {
    
    let two32: Int = 4 * (1 << 30)
    let iv = [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5becd19]
    var constants = [0x243F6A88, 0x85A308D3, 0x13198A2E, 0x03707344, 0xA4093822, 0x299F31D0, 0x082EFA98, 0xEC4E6C89, 0x452821E6, 0x38D01377, 0xBE5466CF, 0x34E90C6C, 0xC0AC29B7, 0xC97C50DD, 0x3F84D5B5, 0xB5470917]
    
    let output = { (var i: Int) -> String in
        if (i < 0) {
            i += two32
        }
        
        let stringify: String = "00000000" + String(i, radix: 16)
        let slice = stringify.endIndex.advancedBy(-8)
        let finalHex = stringify.substringToIndex(slice)
        return finalHex
    }
    
    var sigma = [[16, 50, 84, 118, 152, 186, 220, 254], [174, 132, 249, 109, 193, 32, 123, 53], [139, 12, 37, 223, 234, 99, 23, 73], [151, 19, 205, 235, 98, 165, 4, 143], [9, 117, 66, 250, 30, 203, 134, 211], [194, 166, 176, 56, 212, 87, 239, 145], [92, 241, 222, 164, 112, 54, 41, 184], [189, 231, 28, 147, 5, 79, 104, 162], [246, 158, 59, 128, 44, 125, 65, 90], [42, 72, 103, 81, 191, 233, 195, 13]]
    
    var state = [Int]()
    var message = [Int]()
    var block: Int = 0
    var r: Int = 0
    
    let circ = { (a: Int, b: Int, n: Int) -> Void in
        let s = state[a] ^ state[b]
        state[a] = (s >> n) | (s << (32 - n))
    }
    
    let g = { (i: Int, var a: Int, var b: Int, var c: Int, var d: Int) -> Void in
        let u = block + sigma[r][i] % 16
        let v = block + (sigma[r][i] >> 4)
        a %= 4
        b = 4 + b % 4
        c = 8 + c % 4
        d = 12 + d % 4
        state[a] += state[b] + (message[u] ^ constants[v % 16])
        circ(d, a, 16)
        state[c] += state[d]
        circ(b, c, 12)
        state[a] += state[b] + (message[v] ^ constants[u % 16])
        circ(d, a, 8)
        state[c] += state[d]
        circ(b, c, 7)
    }
    
    let hash = { (var msg: String, var salt: [Int]) -> String in
        if(!(salt.count == 4)) {
            salt = [0, 0, 0, 0]
        }
        
        var chain = [Int]()
        var pad = [Int]()
        var len: Int
        var last_L: Int
        
        chain = iv.slice(0)
        pad = constants.slice(0, 8)
        
        for (r = 0; r < 4; r += 1) {
            pad[r] ^= salt[r]
        }
        
        len = msg.characters.count * 16
        last_L = (len % 512 > 446 || len % 512 == 0) ? 0 : len
        
        if(len % 512 == 432) {
            msg += "\u{8001}"
        } else {
            msg += "\u{8000}"
            while (msg.characters.count % 32 != 27) {
                msg += "\u{0000}"
            }
            msg += "\u{0001}"
        }
        
        var message = [Int]()
        var i: Int
        
        for (i = 0; i < msg.characters.count; i += 2) {
            message.append((msg.characters.count.advancedBy(i)) + 65536 * (msg.characters.count.advancedBy(i + 1)))
        }
        
        message.append(0)
        message.append(len)
        
        var last: Int
        var L: Int
        
        last = message.count - 16
        
        var total = 0
        
        for (block = 0; block < message.count; block += 16) {
            total += 512
            L = (block == last) ? last_L : min(len, total)
            state = chain + pad
            state[12] ^= L
            state[13] ^= L
            for (r = 0; r < 10; r += 1) {
                for (i = 0; i < 8; i += 1) {
                    if (i < 4) {
                        g(i, i, i, i, i)
                    } else {
                        g (i, i, i + 1, i + 2, i + 3)
                    }
                }
            }
            for (i = 0; i < 8; i += 1) {
                chain[i] ^= salt[i % 4] ^ state[i] ^ state[i + 8]
            }
        }
        return chain.map(output).joinWithSeparator("")
    }
    
    return hash
    
}
































