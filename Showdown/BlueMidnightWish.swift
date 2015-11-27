//
//  BlueMidnightWish.swift
//  Showdown
//
//  Created by Steven Harvath on 11/8/15.
//  Copyright © 2015 harvathian. All rights reserved.
//

import Foundation

public func bmw(var msg: String) -> String {
    
    let hex = { (n: Int) -> String in
        let stringify: String = "00" + String(n, radix: 16)
        let slice = stringify.endIndex.advancedBy(-2)
        let finalHex = stringify.substringToIndex(slice)
        return finalHex
    }
    
    let output_fn = { (n: Int) -> String in
        return hex(n & 255) + hex(n >> 8)  + hex(n >> 16) + hex(n >> 24)
    }
    
    var u: Int
    var iv = [Int]()
    var final = [Int]()
    var add_const = [Int]()
    
    for (u = 0; u < 16; u += 1) {
        final[u] = 0xaaaaaaa0 + u
        iv[u] = 0x40414243 + u * 0x04040404
        add_const[u] = (u + 16) * 0x5555555
    }
    
    let rot = { (x: Int, n: Int) -> Int in
        return (x << n) + (x >> (32 - n))
    }
    
    var sc = [19, 23, 25, 29, 4, 8, 12, 15, 3, 2, 1, 2, 1, 1, 2, 2]
    
    let s = { (x: Int, n: Int) -> Int in
        return (n < 4) ? rot(x, sc[n]) ^ rot(x, sc[n + 4]) ^ (x << sc[n + 8]) ^ (x >> sc[n + 12]) : x ^ (x >> n - 3)
    }
    
    var fc = [21, 7, 5, 1, 3, 22, 4, 11, 24, 6, 22, 20, 3, 4, 7, 2, 5, 24, 21, 21, 16, 6, 22, 18]
    
    let fold = { (x: Int, var n: Int) -> Int in
        n = fc[n]
        return (n < 16) ? x >> n : x << (n - 16)
    }
    
    var ec_s = [29, 13, 27, 13, 25, 21, 18, 4, 5, 11, 17, 24, 19, 31, 5, 24]
    var ec_n = [5, 7, 10, 13, 14]
    var ec2_rot = [0, 3, 7, 13, 16, 19, 23, 27]
    
    let compress = { (m: [Int], var H: [Int]) -> [Int] in
        var i: Int
        var lo: Int
        var hi: Int
        var j: Int
        var k: Int
        var a: Int
        var b: Int
        var Q = [Int]()
        
        for(i = 0; i < 16; i += 1) {
            a = 0
            for(j = 0; j < 5; j += 1) {
                k = (i + ec_n[j]) % 16
                b = H[k] ^ m[k]
                a += (ec_s[i] >> j)
                if (a % 2 == 0) {
                
                } else {
                    b = -b
                }
            }
            
            Q[i] = H[(i + 1) % 16] + s(a, i % 5)
        }
        
        for (i = 0; i < 16; i += 1) {
            a = (i + 3) % 16
            b = (i + 10) % 16
            Q[i + 16] = H[(i + 7) % 16] ^ (add_const[i] + rot(m[i], 1 + i) + rot(m[a], 1 + a) - rot(m[b], 1 + b))
            
            for (k = 1; k < 17; k += 1) {
                a = Q[i + k - 1]
                Q[i + 16] += (i < 2) ? s(a, k % 4) : (k > 14) ? s(a, k - 11) : (k / 2 == 0) ? a : rot(a, ec2_rot[k / 2])
            }
        }
        
        lo = 0
        hi = 0
        
        for (i = 16; i < 24; i += 1) {
            lo ^= Q[i]
            hi ^= Q[i + 8]
        }
        
        hi ^= lo
        
        for (i = 0; i < 16; i += 1) {
            let foldTrue: Int = (lo ^ Q[i] ^ Q[i + 24]) + (m[i] ^ fold(hi, i) ^ fold(Q[i + 16], i + 16))
            let foldFalse: Int = (hi ^ m[i] ^ Q[i + 16]) + (Q[i] ^ fold(lo, i) ^ Q[16 + (i - 1) % 8]) + rot(H[(i - 4) % 8], i + 1)
            H[i] = (i < 8) ? foldTrue : foldFalse
        }
        
        return H
    }
    
    let len: Int = 16 * msg.characters.count
    var i: Int
    var H = [Int]()
    
    msg += "\u{0080}"
    
    while (msg.characters.count % 32 != 28) {
        msg += "\u{0000}"
    }
        
    var data = [Int]()
    for (i = 0; i < msg.characters.count; i += 2) {
        data.append((msg.characters.count.advancedBy(i)) + 65536 * (msg.characters.count.advancedBy(i + 1)))
    }
        
    data.append(len)
    data.append(0)
        
    H = iv.slice(0)
        
    for (i = 0; i < data.count; i += 16) {
        compress(data.slice(i, i + 16), H)
    }
        
    return compress(H, final.slice(0)).slice(8, 16).map(output_fn).joinWithSeparator("")
}

extension Array {
    func slice(args: Int...) -> Array {
        var s = args[0]
        var e = self.count - 1
        if args.count > 1 { e = args[1] }
        
        if e < 0 {
            e += self.count
        }
        
        if s < 0 {
            s += self.count
        }
        
        let count = (s < e ? e - s : s - e) + 1
        let inc = s < e ? 1 : -1
        var ret = Array()
        
        var idx = s
        for var i = 0; i < count; i++ {
            ret.append(self[idx])
            idx += inc
        }
        return ret
    }
}



























